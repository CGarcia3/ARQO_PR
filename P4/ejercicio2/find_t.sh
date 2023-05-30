# Ejemplo script, para P3 arq 2019-2020

#!/bin/bash

# inicializar variables
P=5
Ninicio=1
Npaso=1
Nfinal=100
fDAT=vector_mul_N.dat
fPNG=vector_mul_N.png


# borrar el fichero DAT y el fichero PNG
rm -rf $fDAT fPNG

# generar el fichero DAT vacío
touch $fDAT

for ((i = Ninicio; i <= Nfinal; i += Npaso)) do
    echo $i
    make > /dev/null
    val_serie=$(./pescalar_serie $i | grep "Tiempo" | awk '{print $2}')
    val_par=$(./pescalar_par3 $i | grep "Tiempo" | awk '{print $2}')
	printf "$i	$val_serie	$val_par\n" >> $fDAT
done


echo "Generating plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Serie-Parallel Execution Time"
set ylabel "Execution time (s)"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "$fPNG"
plot "$fDAT" using 1:2 with lines lw 2 title "serie", \
     "$fDAT" using 1:3 with lines lw 2 title "parallel (3 cores)"
replot
quit
END_GNUPLOT
