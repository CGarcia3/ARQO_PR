//P3 arq 2019-2020
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>

#include "arqo3.h"

tipo** transpose_matrix(tipo **M1, int n);
tipo **multiply_transposed(tipo **M1, tipo **M2, tipo **res, int n);

int main( int argc, char *argv[])
{
	int n;
	tipo **M1=NULL,**M2=NULL, **MTrans=NULL;
	struct timeval fin,ini;
	tipo **res2=NULL;


	if( argc!=2 )
	{
		printf("Error: ./%s <matrix size>\n", argv[0]);
		return -1;
	}
	n=atoi(argv[1]);
	M1=generateMatrix(n);
	M2=generateMatrix(n);
	if( !M1 || !M2 )
	{
		return -1;
	}

	printf("Word size: %ld bits\n",8*sizeof(tipo));
	
	res2=generateEmptyMatrix(n);
	
	if(!res2){
		return -1;
	}
	gettimeofday(&ini,NULL);
	MTrans=transpose_matrix(M2, n);
	if(!MTrans){
		return -1;
	}
	res2 = multiply_transposed(M1, MTrans, res2, n);
	/* End of computation */

	gettimeofday(&fin,NULL);
	printf("Execution time mul |trans: %f\n", ((fin.tv_sec*1000000+fin.tv_usec)-(ini.tv_sec*1000000+ini.tv_usec))*1.0/1000000.0);
	

	freeMatrix(M1);
	freeMatrix(M2);
	freeMatrix(MTrans);
	freeMatrix(res2);
	return 0;
}


tipo** transpose_matrix(tipo **M1, int n){
	tipo **res=NULL;
	int i=0, j=0;

	res=generateEmptyMatrix(n);

	for(j=0; j<n; j++){
		for(i=0; i<n; i++){
			res[j][i] = M1[i][j];
		}
	}
	return res;

}


tipo **multiply_transposed(tipo **M1, tipo **M2, tipo **res, int n){

	tipo sum=0;
	int i, j, k;

	for(i=0; i<n; i++){
		for(j=0; j<n; j++){

			sum = 0;
			for (k=0; k<n; k++){
				sum += M1[i][k] * M2[j][k];
			}
			res[i][j] = sum;
		}
	}
	return res;
}
