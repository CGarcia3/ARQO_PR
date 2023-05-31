# Ejemplo script, para P3 arq 2019-2020

#!/bin/bash

# inicializar variables
P=5
Ninicio=512+$P
Npaso=64
Nfinal=1024+512+$P
fDAT=matrix_mul_times.dat
fPNG=matrix_mul_times.png
fPNG2=matrix_mul_speedup.png
iter=10


# borrar el fichero DAT y el fichero PNG
rm -rf $fDAT fPNG

# generar el fichero DAT vacío
touch $fDAT

for ((i = Ninicio; i <= Nfinal; i = i+Npaso)) do
    echo $i
    total_serie=0
    for ((j=0; j<iter; j = j+1)){
        val_serie=$(./matrix_mul_serie $i | grep "Execution time" | awk '{print $3}')
        total_serie=$(echo "scale=6; $val_serie+$total_serie" | bc)
    }
    avg_serie=$(echo "scale=6; $total_serie/$iter" | bc)
    
    total_p1=0
    total_p2=0
    total_p3=0
    
    for ((j=0; j<iter; j = j+1)){
        make > /dev/null

        val_par3=$(./matrix_mul_par3 $i 6 | grep "Execution time" | awk '{print $3}')
        total_p3=$(echo "scale=6; $val_par3+$total_p3" | bc)
    }
    avg_p3=$(echo "scale=6; $total_p3/$iter" | bc)
    speedup3=$(echo "scale=6; $avg_serie/$avg_p3" | bc)
    printf "$i	$avg_serie $avg_p3 $speedup3\n" >> $fDAT
    #bash plot.sh plot_$i.png
done
