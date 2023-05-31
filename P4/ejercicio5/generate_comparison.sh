# Ejemplo script, para P3 arq 2019-2020

#!/bin/bash

# inicializar variables
P=5
Nfiles=5
files=("480p.jpg" "720p.jpg" "1080.jpg" "4k.jpg" "8k.jpg")
fDAT=table_times_images.dat
iter=4


# borrar el fichero DAT y el fichero PNG
rm -rf $fDAT

# generar el fichero DAT vacío
touch $fDAT

make > /dev/null

for ((i = 0; i < Nfiles; i = i=i+1)) do
    echo Processing file ${files[$i]}

    total_base=0
    total_loop=0
    total_pragma=0
    
    for ((j=0; j<iter; j = j+1)){
        val_base=$(./edgeDetector imgs/${files[$i]} | grep Tiempo | awk '{print $2}')
        val_loop=$(./edgeDetectorLoopOrder imgs/${files[$i]} | grep Tiempo | awk '{print $2}')
        val_pragma=$(./edgeDetectorLoopOrderPragma imgs/${files[$i]} | grep Tiempo | awk '{print $2}')
        total_base=$(echo "scale=6; $val_base+$total_base" | bc)
        total_loop=$(echo "scale=6; $val_loop+$total_loop" | bc)
        total_pragma=$(echo "scale=6; $val_pragma+$total_pragma" | bc)
    }

    avg_base=$(echo "scale=6; $total_base/$iter" | bc)
    avg_loop=$(echo "scale=6; $total_loop/$iter" | bc)
    avg_pragma=$(echo "scale=6; $total_pragma/$iter" | bc)
    speedup_loop=$(echo "scale=6; $avg_base/$avg_loop" | bc)
    speedup_pragma=$(echo "scale=6; $avg_base/$avg_pragma" | bc)
    fps=$(echo "scale=6; 1/$avg_pragma" | bc)
    printf "${files[$i]} \t$avg_base\t$avg_loop\t$speedup_loop\t$avg_pragma\t$speedup_pragma\t$fps\n" >> $fDAT
done

make clean