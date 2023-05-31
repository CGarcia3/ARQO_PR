# Ejemplo script, para P3 arq 2019-2020

#!/bin/bash

# inicializar variables
P=5
Ninicio=1
Npaso=1
Nfinal=7
fDAT=table_versions.dat
iter=10


# borrar el fichero DAT y el fichero PNG
rm -rf $fDAT fPNG

# generar el fichero DAT vacío
touch $fDAT

make > /dev/null

tot_serie=0
for ((j=0; j<iter; j = j+1)){
    out_serie=$(./pi_serie)
    val_serie=$(echo $out_serie | awk '{print $5}')
    pi=$(echo $out_serie | awk '{print $3}')
    tot_serie=$(echo "scale=6; $val_serie+$tot_serie" | bc)
}
avg_serie=$(echo "scale=6; $tot_serie/$iter" | bc)
printf "serial \t$avg_serie\t$pi\t1\n" >> $fDAT

for ((i = Ninicio; i <= Nfinal; i = i+Npaso)) do
    echo $i

    total_p=0
    
    for ((j=0; j<iter; j = j+1)){
        val_p=$(./pi_par$i | grep Tiempo | awk '{print $2}')
        pi=$(./pi_par$i | grep pi | awk '{print $3}')
        total_p=$(echo "scale=6; $val_p+$total_p" | bc)
    }

    avg_p=$(echo "scale=6; $total_p/$iter" | bc)
    speedup=$(echo "scale=6; $avg_serie/$avg_p" | bc)
    printf "par$i \t$avg_p\t$pi\t$speedup\n" >> $fDAT
done

make clean