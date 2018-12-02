/* Compute the sum of two vectors using CUDA
 * Vishwas S
*/

#include <stdio.h>
#include <stdlib.h>
__global__ void add(int *a, int *b, int *c, int n)
{
	int id = blockIdx.x*blockDim.x + threadIdx.x;
	if(id<n)
		c[id] = a[id] + b[id];
}

int main()
{
	int N;
	int *a, *b, *c, *da, *db, *dc;
	
	scanf("%d",&N);
	
	
	cudaEvent_t start, stop;
	
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	
	a = (int *)calloc(N,sizeof(int));
	b = (int *)calloc(N,sizeof(int));
	c = (int *)calloc(N,sizeof(int));
	
	for(int i = 0; i < N; i++)
	{
		a[i] = rand()%48;
		b[i] = rand()%50;
	}
	
	int size = N*sizeof(int);

	cudaMalloc(&da,size);
	cudaMalloc(&db,size);
	cudaMalloc(&dc,size);
	
	cudaMemcpy(da,a,size,cudaMemcpyHostToDevice);
	cudaMemcpy(db,b,size,cudaMemcpyHostToDevice);
	
	
	cudaEventRecord(start);
	add<<<(N+511)/512,512>>>(da,db,dc,N); //block count, threads per block
	cudaEventRecord(stop);
	
	cudaMemcpy(c,dc,size,cudaMemcpyDeviceToHost);
	cudaEventSynchronize(stop);
	float ms;
	
	cudaEventElapsedTime(&ms,start,stop);
	printf("%f\n",ms);
}