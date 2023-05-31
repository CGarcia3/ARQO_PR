# Ejemplo script, para P3 arq 2019-2020

#!/bin/bash

# inicializar variables
P=5
Ninicio=100000
Npaso=100000
Nfinal=10000000
fDAT=vector_mul_N.dat
fPNG=vector_mul_N.png
iter=20


# borrar el fichero DAT y el fichero PNG
rm -rf $fDAT fPNG

# generar el fichero DAT vacío
touch $fDAT

for ((i = Ninicio; i <= Nfinal+1; i = i+Npaso)) do
    total_serie=0
    total_parallel=0
    for ((j=0; j<iter; j+=1)){
        echo $i
        make > /dev/null
        val_serie=$(./pescalar_serie $i | grep "Tiempo" | awk '{print $2}')
        total_serie=$(echo "scale=6; $val_serie+$total_serie" | bc)
        
        val_par=$(./pescalar_par3 $i | grep "Tiempo" | awk '{print $2}')
        total_parallel=$(echo "scale=6; $val_par+$total_parallel" | bc)
    }
    avg_parallel=$(echo "scale=6; $total_parallel/$iter" | bc)
    avg_serie=$(echo "scale=6; $total_serie/$iter" | bc)
	printf "$i	$avg_serie	$avg_parallel\n" >> $fDAT
done

make clean
echo "Generating plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Serie-Parallel Execution Time"
set ylabel "Execution time (s)"
set xlabel "Matrix Size"
set logscale x 10
set key right bottom
set grid
set term png
set output "$fPNG"
plot "$fDAT" using 1:2 with lines lw 2 title "serie", \
     "$fDAT" using 1:3 with lines lw 2 title "parallel (3 cores)"
replot
quit
END_GNUPLOT
