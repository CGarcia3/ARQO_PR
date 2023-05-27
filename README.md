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
El objetivo de esta práctica es implementar algunas mejoras sobre el microprocesador RISC-V (visto en clase de teoría 
y  desarrollado  en  la  práctica  1).  En  esta  práctica  se  resolverán  los  riesgos  (“hazards”)  generados  al  segmentar  el  
procesador MIPS.   Para realizar esta práctica se recomienda consultar la sección 4.1 (Data Hazards: Forwarding versus Stalling) del libro 
de Patterson & Hennessy y las transparencias de la teoría del Tema 2. 
### Ejercicio 1: Riesgos de datos (7 puntos) 
En este ejercicio se modifica el hardware del microprocesador para lograr una ejecución correcta en situaciones en las 
que la ejecución de una instrucción depende del resultado de otra anterior aún presente en el pipeline, debido al uso 
de un mismo registro (Read After Write –RAW–  data hazard).  Se implementarán 3 mecanismos:  
1. Forwarding de datos hacia la ALU. 
Sobre  el  diseño  de  microprocesador  anterior  se  añadirán  los  caminos  de  adelantamiento  de  datos  (“forwarding”)  
mostrados  en  la  siguiente  figura,  que  adelantarán  el  resultado  de  la  instrucción  anterior  (desde  MEM)  o  desde  dos  
anteriores (desde WR) para su uso en la etapa “EX”.  
 
 En la presentación de Teoría de la asignatura y en el libro pueden encontrarse detalladas las condiciones para activar 
las  nuevas  rutas  en  los  multiplexores  de  “forwarding”  (adelantamiento),  ha  de  suceder  que  en  cualquiera  de  las dos  
siguientes etapas (“MEM” y “WB”) se esté escribiendo el mismo registro que cualquiera de los dos que fueron leídos 
del banco de registros en la etapa anterior para su uso en esta etapa “EX”, dando precedencia a un posible resultado 
presente en “MEM” sobre otro en “WB” (por ser más reciente) y considerando el caso especial del registro 0.  Lo  que  en  el  dibujo  se  muestra  como  “Forwarding  unit”  es  la  generación  de  las  señales  de  selección  de  los  nuevos  
multiplexores (los que están dentro de la línea roja discontinua en la figura anterior), a partir de las condiciones antes 
comentadas. Se deberá implementar esta lógica en la misma arquitectura (esto es, sin crear ningún bloque jerárquico 
adicional; tanto para esta “Forwarding unit” como para los propios multiplexores pueden utilizarse procesos 
combinacionales explícitos o asignaciones concurrentes).  
2. Forwarding interno en el banco de registros. 
Los  adelantamientos  de  datos  implementados  con  el  esquema  anterior  contemplan  la  ejecución  en  la  ALU  de  una  
operación con  un nuevo  valor  de  registro disponible  en  los  registros  de  pipeline EX/MEM  y MEM/WB (realmente en  
este último caso tras un multiplexor adicional), correspondientes a una y dos instrucciones anteriores respectivamente. 
Un caso adicional se da cuando la dependencia es respecto a la instrucción que entró en el pipeline 3 ciclos antes. En 
este caso la solución es crear un adelantamiento de datos dentro del propio banco de registros (es decir en la etapa ID 
en lugar de en la etapa EX). Las relaciones de datos para el esquema anterior y para este caso adicional se muestran en 
la siguiente figura:
Deberá modificarse el banco de registros entregado en el material de partida de la Práctica 1 en una de las dos formas 
posibles: 
• Añadiendo un path combinacional, de forma que, cuando se lea el mismo registro que se esté escribiendo, el 
banco entregue el valor que se está escribiendo en lugar del que había en el registro accedido. Además, habrá 
que tener en cuenta el comportamiento especial del registro 0. 
• Haciendo que el banco de registros funciones en flanco de bajada. En esta alternativa debe ser capaz de explicar 
porque ha de funcionar. 

3. Detección  del  caso  en  que  una  instrucción  LW  carga  un  registro  que  es  utilizado  por  la  instrucción  que  le  
sigue. 
En este caso no es posible adelantar datos. Debe generarse un ciclo de detención (“stall”), repitiendo las etapas IF e ID 
actuales e insertando una “burbuja” (a modo de instrucción nop) en las etapas siguientes. La “Hazard detection unit” 
mostrada en la siguiente figura detectará la condición mencionada, evitando la actualización del contador de programa 
(PC  -  Program  Counter)  y  del  registro  de  pipeline  IF/ID  y  poniendo  a  cero  en  el  registro  ID/EX  las  señales  de  control  
necesarias para crear la “burbuja”:
Nota 0: para determinar la condición de load-use hazard se usará lo visto en Teoría y expuesto en el libro de referencia, es decir, bastará observar los campos rs1 y rs2 de la nueva instrucción respecto al destino rd de una instrucción LW en 
el ciclo anterior. Esta solución no es óptima pues genera burbujas innecesarias para las instrucciones LUI y SW. No es 
necesario considerar esta peculiaridad.  
Nota 1: El procesador debe ser capaz de ejecutar correctamente cualquier instrucción, excepto las instrucciones de tipo branch cuando se vean implicadas en riesgo de datos. 
Nota 2: Es conveniente generar un código que pruebe exhaustivamente los adelantamientos. El código fuente debe ser compilado por el compilador RARS 