#!/bin/bash

fPNG1=cache_lectura.png
fPNG2=cache_escritura.png

fDAT1=cache_1024.dat
fDAT2=cache_2048.dat
fDAT3=cache_4096.dat
fDAT4=cache_8192.dat

echo Generating plot...
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Data Read Misses With Different Cache Sizes"
set ylabel "# misses in millions"
set xlabel "Matrix Size"
set key left top
set grid
set term png
set output "$fPNG1"
plot "$fDAT1" using 1:2 with lines lw 1 lc rgb "violet" title "slow 1024", \
     "$fDAT2" using 1:2 with lines lw 1 lc rgb "red" title "slow 2048", \
     "$fDAT3" using 1:2 with lines lw 1 lc rgb "green" title "slow 4096", \
     "$fDAT4" using 1:2 with lines lw 1 lc rgb "blue" title "slow 8182", \
     "$fDAT1" using 1:4 with lines lw 3 lc rgb "violet" title "fast 1024", \
     "$fDAT2" using 1:4 with lines lw 3 lc rgb "red" title "fast 2048", \
     "$fDAT3" using 1:4 with lines lw 3 lc rgb "green" title "fast 4096", \
     "$fDAT4" using 1:4 with lines lw 3 lc rgb "blue" title "fast 8182"

set title "Data Write Misses With Different Cache Sizes"
set output "$fPNG2"
plot "$fDAT1" using 1:3 with lines lw 1 lc rgb "violet" title "slow 1024", \
     "$fDAT2" using 1:3 with lines lw 1 lc rgb "red" title "slow 2048", \
     "$fDAT3" using 1:3 with lines lw 1 lc rgb "green" title "slow 4096", \
     "$fDAT4" using 1:3 with lines lw 1 lc rgb "blue" title "slow 8182", \
     "$fDAT1" using 1:5 with lines lw 3 lc rgb "violet" title "fast 1024", \
     "$fDAT2" using 1:5 with lines lw 3 lc rgb "red" title "fast 2048", \
     "$fDAT3" using 1:5 with lines lw 3 lc rgb "green" title "fast 4096", \
     "$fDAT4" using 1:5 with lines lw 3 lc rgb "blue" title "fast 8182"
quit
END_GNUPLOT
