# ARQO_PR
Practicas de Arquitectura de ordenadores curso 22/23 para la UAM.

## Practica 1
---
### Ejercicio 1 (2 puntos)  
Se  pide  completar el microprocesador RISC V  en  su  versión uniciclo. El diseño entregado como punto de partida, no soporta el set de instrucciones descripto (add, addi, and, andi, auipc, beq, bne, j, jal, 
li, lw, lui, sw, xor). 
### Ejercicio 2 (1 puntos)  
Se pide  realizar  un  programa  en  ensamblador  simple  que  sea  capaz  de  probar  las  instrucciones  que puedan haber quedado sin probar en el programa provisto como punto de partida. ¿cuales no se prueban en el programa de partida? 
### Ejercicio 3 (7 puntos)  
Se  pide  implementar e l   microprocesador RISC V  en  su  versión segmentada. 

El  resultado debe  ser un micro capaz de realizar  en el caso ideal (sin riesgos)  una instrucción  por ciclo de reloj. Para el ejercicio 
básico,  no  es  necesario  que  el  modelo  soporte  riesgos  (salvo  el  estructural de  acceso  a  memorias separadas  de instrucciones  y datos).  Todos los registros utilizados para la segmentación han de cumplir las siguientes características: 
1. Funcionar  por flanco  de subida  del reloj (rising_edge(clk) ). 
2. Resetearse asíncronamente utilizando la señal “Reset” de la entidad 
“processor_core”.  
## Practica 2
---