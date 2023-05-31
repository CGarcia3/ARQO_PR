CC = gcc
LIBS = -lgomp -lm
LIB_DIR =  
FLAGS = -g -Wall -D_GNU_SOURCE -fopenmp

.PHONY: clean all

all: edgeDetector edgeDetectorLoopOrder edgeDetectorLoopOrderPragma edgeDetectorOpt edgeDetectorLoopOrderOpt edgeDetectorLoopOrderPragmaOpt clear

edgeDetector: edgeDetector.c stb_image_write.h stb_image.h
	$(CC) $(FLAGS) -std=gnu99 $(LIB_DIR) -o $@ edgeDetector.c $(LIBS)

edgeDetectorLoopOrder: edgeDetectorLoopOrder.c stb_image_write.h stb_image.h
	$(CC) $(FLAGS) -std=gnu99 $(LIB_DIR) -o $@ edgeDetectorLoopOrder.c $(LIBS)

edgeDetectorLoopOrderPragma: edgeDetectorLoopOrderPragma.c stb_image_write.h stb_image.h
	$(CC) $(FLAGS) -std=gnu99 $(LIB_DIR) -o $@ edgeDetectorLoopOrderPragma.c $(LIBS)

edgeDetectorOpt: edgeDetector.c stb_image_write.h stb_image.h
	$(CC) $(FLAGS) -O3 -std=gnu99 $(LIB_DIR) -o $@ edgeDetector.c $(LIBS)

edgeDetectorLoopOrderOpt: edgeDetectorLoopOrder.c stb_image_write.h stb_image.h
	$(CC) $(FLAGS) -O3 -std=gnu99 $(LIB_DIR) -o $@ edgeDetectorLoopOrder.c $(LIBS)

edgeDetectorLoopOrderPragmaOpt: edgeDetectorLoopOrderPragma.c stb_image_write.h stb_image.h
	$(CC) $(FLAGS) -O3 -std=gnu99 $(LIB_DIR) -o $@ edgeDetectorLoopOrderPragma.c $(LIBS)

stb_image.h:
	@echo "Los ficheros de cabecera de stb se deberían descarga automáticamente"
	@echo "En caso de fallo, descargadlo de https://raw.githubusercontent.com/nothings/stb/master/stb_image.h"
	wget --no-check-certificate https://raw.githubusercontent.com/nothings/stb/master/stb_image.h

stb_image_write.h:
	@echo "Los ficheros de cabecera de stb se deberían descarga automáticamente"
	@echo "En caso de fallo, descargadlo de https://raw.githubusercontent.com/nothings/stb/master/stb_image_write.h"
	wget --no-check-certificate https://raw.githubusercontent.com/nothings/stb/master/stb_image_write.h

clean:
	rm -f *.o *~ edgeDetector edgeDetectorLoopOrder edgeDetectorLoopOrderPragma edgeDetectorOpt edgeDetectorLoopOrderOpt edgeDetectorLoopOrderPragmaOpt
	 
clear:
	rm -f *.o *~
