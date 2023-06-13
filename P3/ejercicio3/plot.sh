#!/bin/bash

fPNG1=comp_cache.png
fPNG2=comp_tiempos.png

fDAT1=matrix_trans.dat

echo Generating plot...
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Cache Misses Normal vs Transpose matrix multiplication"
set ylabel "# misses"
set xlabel "Matrix Size"
set key left top
set grid
set term png
set output "$fPNG1"
plot "$fDAT1" using 1:3 with lines lw 2 lc rgb "violet" title "Read misses normal mul", \
     "$fDAT1" using 1:4 with lines lw 2 lc rgb "red" title "Write misses normal mul", \
     "$fDAT1" using 1:6 with lines lw 2 lc rgb "green" title "Read misses transpose mul", \
     "$fDAT1" using 1:7 with lines lw 2 lc rgb "blue" title "Write misses transpose mul"

set title "Normal vs transpose matrix multiplication times"
set output "$fPNG2"
plot "$fDAT1" using 1:2 with lines lw 2 lc rgb "blue" title "Normal multiplication", \
     "$fDAT1" using 1:5 with lines lw 2 lc rgb "red" title "Transpose multiplication"
quit
END_GNUPLOT
