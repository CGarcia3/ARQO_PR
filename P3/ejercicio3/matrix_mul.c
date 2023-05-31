//P3 arq 2019-2020
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>

#include "arqo3.h"

tipo compute(tipo **matrix,int n);
tipo **multiply(tipo **M1, tipo **M2, int n);

int main( int argc, char *argv[])
{
	int n;
	tipo **M1=NULL,**M2=NULL;
	struct timeval fin,ini;
	tipo **res=NULL;


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
	
	gettimeofday(&ini,NULL);

	/* Main computation */
	res = multiply(M1, M2, n);
	/* End of computation */

	gettimeofday(&fin,NULL);
	printf("Execution time: %f\n", ((fin.tv_sec*1000000+fin.tv_usec)-(ini.tv_sec*1000000+ini.tv_usec))*1.0/1000000.0);
	//printf("Total: %lf\n",res);
	


	freeMatrix(M1);
	freeMatrix(M2);
	freeMatrix(res);
	return 0;
}


tipo **multiply(tipo **M1, tipo **M2, int n){

	tipo sum=0;
	tipo **res=NULL;
	int i, j, k;

	res=generateEmptyMatrix(n);
	if(!res){
		return NULL;
	}	

	for(i=0; i<n; i++){
		for(j=0; j<n; j++){

			sum = 0;
			for (k=0; k<n; k++){
				sum += M1[i][k] * M2[k][j];
			}
			res[i][j] = sum;
		}
	}
	return res;
}

tipo compute(tipo **matrix,int n)
{
	tipo sum=0;
	int i,j;
	
	for(i=0;i<n;i++)
	{
		for(j=0;j<n;j++)
		{
			sum += matrix[i][j];
		}
	}
	return sum;
}