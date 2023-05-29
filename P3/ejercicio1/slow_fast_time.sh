# Ejemplo script, para P3 arq 2019-2020

#!/bin/bash

# inicializar variables
Ninicio=1024
Npaso=1024
Nfinal=16384
fDAT=slow_fast_time.dat
fPNG=slow_fast_time.png
iter=10

# borrar el fichero DAT y el fichero PNG
rm -f $fDAT fPNG

# generar el fichero DAT vacío
touch $fDAT

echo "Running slow and fast..."
# bucle para N desde P hasta Q 
#for N in $(seq $Ninicio $Npaso $Nfinal);


for ((N = Ninicio, NN = Ninicio + Npaso; N <= Nfinal ; N += Npaso*2, NN += Npaso*2)); do
	echo "N: $N y $NN"

	total_fast=0
	total_slow=0
	total_fast2=0
	total_slow2=0
	for ((I = 0; I < $iter; I+=1)) do
		echo "Iterartion $I..."

		
		# ejecutar los programas slow y fast consecutivamente con tamaño de matriz N
		# para cada uno, filtrar la línea que contiene el tiempo y seleccionar la
		# tercera columna (el valor del tiempo). Dejar los valores en variables
		# para poder imprimirlos en la misma línea del fichero de datos
		slowTime=$(../_material_P3/slow $N | grep 'time' | awk '{print $3}')
		slowTime2=$(../_material_P3/slow $NN | grep 'time' | awk '{print $3}')
		total_slow=$(echo "scale=6; $slowTime+$total_slow" | bc)
		total_slow2=$(echo "scale=6; $slowTime2+$total_slow" | bc)

		fastTime=$(../_material_P3/fast $N | grep 'time' | awk '{print $3}')
		fastTime2=$(../_material_P3/fast $NN | grep 'time' | awk '{print $3}')
		total_fast=$(echo "scale=6; $fastTime+$total_fast" | bc)
		total_fast2=$(echo "scale=6; $fastTime2+$total_fast" | bc)
		
	done
	avg_slow=$(echo "scale=6; $total_slow/$iter" | bc)
	avg_fast=$(echo "scale=6; $total_fast/$iter" | bc)
	avg_slow2=$(echo "scale=6; $total_slow2/$iter" | bc)
	avg_fast2=$(echo "scale=6; $total_fast2/$iter" | bc)
	printf "$N	$avg_slow	$avg_fast\n$NN	$avg_slow2	$avg_fast2\n" >> $fDAT
done


echo "Generating plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Slow-Fast Execution Time"
set ylabel "Execution time (s)"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "$fPNG"
plot "$fDAT" using 1:2 with lines lw 2 title "slow", \
     "$fDAT" using 1:3 with lines lw 2 title "fast"
replot
quit
END_GNUPLOT
