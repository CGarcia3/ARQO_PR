LIBS = 
LIB_DIR =  
FLAGS = -O3 -g -Wall -D_GNU_SOURCE

.PHONY: clean all

all: matrix_mul matrix_mul_trans

matrix_mul: matrix_mul.c arqo3.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

matrix_mul_trans: matrix_mul_trans.c arqo3.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)


clean:
	rm -f *.o *~ matrix_mul matrix_mul_trans	
