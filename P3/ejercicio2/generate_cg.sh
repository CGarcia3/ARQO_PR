# Ejemplo script, para P3 arq 2019-2020

#!/bin/bash

# inicializar variables
P=5
Ninicio=1024+1024*$P
Npaso=256
Nfinal=2048+1024*$P
cacheStart=1024
cacheEnd=8192
L3CacheSize=8388608
LineSize=64

# borrar el fichero DAT y el fichero PNG
# rm -f $fDAT fPNG

# generar el fichero DAT vacío
# touch $fDAT

for ((i = cacheStart; i <= cacheEnd; i = i*2)) do
	fDAT=cache_$i.dat
	for ((N = Ninicio; N <= Nfinal ; N += Npaso)) do
		echo "N: $N"
		
		valgrind --tool=cachegrind --I1=$i,1,$LineSize --D1=$i,1,$LineSize --LL=$L3CacheSize,1,$LineSize --cachegrind-out-file=dat.dat ../_material_P3/slow $N
		D1mr_slow=$(cg_annotate dat.dat | grep 'PROGRAM TOTALS' | awk '{print $5}')
		D1mw_slow=$(cg_annotate dat.dat | grep 'PROGRAM TOTALS' | awk '{print $8}')

		valgrind --tool=cachegrind --I1=$i,1,$LineSize --D1=$i,1,$LineSize --LL=$L3CacheSize,1,$LineSize --cachegrind-out-file=dat.dat ../_material_P3/fast $N
		D1mr_fast=$(cg_annotate dat.dat | grep 'PROGRAM TOTALS' | awk '{print $5}')
		D1mw_fast=$(cg_annotate dat.dat | grep 'PROGRAM TOTALS' | awk '{print $8}')

		printf "$N	$D1mr_slow	$D1mw_slow	$D1mr_fast	$D1mw_fast\n" >> $fDAT
	done
	
done

rm -rf dat.dat

