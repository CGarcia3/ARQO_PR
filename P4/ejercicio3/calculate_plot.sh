fPNG=matrix_mul_times.png
fPNG2=matrix_mul_speedup.png
fDAT=matrix_mul_times.dat

echo "Generating plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Speedup of parallelization method 3 against serial"
set ylabel "Speedup"
set xlabel "Matrix Size"
set key left top
set grid
set term png
set output "$fPNG2"
set logscale x 10
plot "$fDAT" using 1:4 with lines lw 2 title "parallel 3 (6 cores)"
replot

quit
END_GNUPLOT