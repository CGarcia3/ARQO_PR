# Ejemplo script, para P3 arq 2019-2020

#!/bin/bash

# inicializar variables
# inicializar variables
P=5
Ninicio=256+256*$P
Npaso=32
Nfinal=512+256*$P #256+256*(p+1)
iter=3
fDAT=matrix_trans.dat
fPNG=matrix_trans.png

cache=8192
L3CacheSize=8388608
LineSize=64

# borrar el fichero DAT y el fichero PNG
rm -f $fDAT fPNG

# generar el fichero DAT vacío
touch $fDAT

echo "Running matrix mul..."
# bucle para N desde P hasta Q 
#for N in $(seq $Ninicio $Npaso $Nfinal);
make

for ((N = Ninicio, NN = Ninicio+Npaso; N <= Nfinal ; N += 2*Npaso, NN += 2*Npaso)); do
	echo "N: $N and $NN"

	total_mul=0
	total_trans=0
	total_mul2=0
	total_trans2=0
	for ((I = 0; I < $iter; I+=1)) do
		echo "Iterartion $I..."

		out=$(./matrix_mul $N)
		norm=$(echo "$out" | tr '|' '\n' | grep 'normal' | awk '{print $2}')
		echo $norm
		
		out=$(./matrix_mul $NN)
		norm2=$(echo "$out" | tr '|' '\n' | grep 'normal' | awk '{print $2}')
		echo $norm2

		out=$(./matrix_mul_trans $N)
		trans=$(echo "$out" | tr '|' '\n' | grep 'trans' | awk '{print $2}')
		echo $trans

		out=$(./matrix_mul_trans $NN)
		trans2=$(echo "$out" | tr '|' '\n' | grep 'trans' | awk '{print $2}')
		echo $trans2

		total_mul=$(echo "scale=6; $norm+$total_mul" | bc)
		total_trans=$(echo "scale=6; $trans+$total_trans" | bc)
		total_mul2=$(echo "scale=6; $norm2+$total_mul2" | bc)
		total_trans2=$(echo "scale=6; $trans2+$total_trans2" | bc)

		
	done
	valgrind --tool=cachegrind --I1=$cache,1,$LineSize --D1=$cache,1,$LineSize --LL=$L3CacheSize,1,$LineSize --cachegrind-out-file=dat.dat ./matrix_mul $N > /dev/null
	out=$(cg_annotate dat.dat)
	D1mr_norm=$(echo "$out" | grep 'PROGRAM TOTALS' | awk '{print $5}')
	D1mw_norm=$(echo "$out" | grep 'PROGRAM TOTALS' | awk '{print $8}')
	valgrind --tool=cachegrind --I1=$cache,1,$LineSize --D1=$cache,1,$LineSize --LL=$L3CacheSize,1,$LineSize --cachegrind-out-file=dat.dat ./matrix_mul $NN > /dev/null
	out=$(cg_annotate dat.dat)
	D1mr_norm2=$(echo "$out" | grep 'PROGRAM TOTALS' | awk '{print $5}')
	D1mw_norm2=$(echo "$out" | grep 'PROGRAM TOTALS' | awk '{print $8}')
	valgrind --tool=cachegrind --I1=$cache,1,$LineSize --D1=$cache,1,$LineSize --LL=$L3CacheSize,1,$LineSize --cachegrind-out-file=dat.dat ./matrix_mul_trans $N > /dev/null
	out=$(cg_annotate dat.dat)
	D1mr_trans=$(echo "$out" | grep 'PROGRAM TOTALS' | awk '{print $5}')
	D1mw_trans=$(echo "$out" | grep 'PROGRAM TOTALS' | awk '{print $8}')
	valgrind --tool=cachegrind --I1=$cache,1,$LineSize --D1=$cache,1,$LineSize --LL=$L3CacheSize,1,$LineSize --cachegrind-out-file=dat.dat ./matrix_mul_trans $NN > /dev/null
	out=$(cg_annotate dat.dat)
	D1mr_trans2=$(echo "$out" | grep 'PROGRAM TOTALS' | awk '{print $5}')
	D1mw_trans2=$(echo "$out" | grep 'PROGRAM TOTALS' | awk '{print $8}')
	
	rm -rf dat.dat

	avg_norm=$(echo "scale=6; $total_mul/$iter" | bc)
	avg_trans=$(echo "scale=6; $total_trans/$iter" | bc)
	avg_norm2=$(echo "scale=6; $total_mul2/$iter" | bc)
	avg_trans2=$(echo "scale=6; $total_trans2/$iter" | bc)
	printf "$N	$avg_norm	$D1mr_norm	$D1mw_norm	$avg_trans	$D1mr_trans	$D1mw_trans\n$NN	$avg_norm2	$D1mr_norm2	$D1mw_norm2	$avg_trans2	$D1mr_trans2	$D1mw_trans2\n" >> $fDAT

done

make clean


