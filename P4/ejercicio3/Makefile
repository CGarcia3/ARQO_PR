LIBS = -lgomp -lm
LIB_DIR =  
FLAGS = -O3 -g -Wall -D_GNU_SOURCE -fopenmp

.PHONY: clean all

all: matrix_mul_serie matrix_mul_par1 matrix_mul_par2 matrix_mul_par3

matrix_mul_serie: matrix_mul_serie.c arqo3.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

matrix_mul_par1: matrix_mul_par1.c arqo3.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

matrix_mul_par2: matrix_mul_par2.c arqo3.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

matrix_mul_par3: matrix_mul_par3.c arqo3.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)


clean:
	rm -f *.o *~ matrix_mul_serie matrix_mul_par1 matrix_mul_par2 matrix_mul_par3
