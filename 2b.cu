
#include<stdio.h>
#include<stdlib.h>

__global__ void mul(int *a, int *b, int *c, int n)
{
	int row = blockIdx.y*blockDim.y + threadIdx.y;
	int col = blockIdx.x*blockDim.x + threadIdx.x;
	int sum = 0;
	int i;
	if(row < n && col < n)
	{
		for(i =0; i<n; i++)
		{
			sum += a[row*n+i]*b[i*n+col];
		}
		c[row*n+col] =  sum;
	}
	
}

int main(int argc, char **argv)
{
	int N;
	int *a, *b, *c, *d, *da, *db, *dc;
	int i,j,k;
	scanf("%d",&N);
	
	
	cudaEvent_t start, stop;
	
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	
	a = (int *)calloc(N*N,sizeof(int));
	b = (int *)calloc(N*N,sizeof(int));
	c = (int *)calloc(N*N,sizeof(int));
	d = (int *)calloc(N*N,sizeof(int));

	for(i = 0; i < N*N; i++)
	{
		a[i] = rand()%48;
		b[i] = rand()%50;
	}
	
	int size = N*N*sizeof(int);

	cudaMalloc(&da,size);
	cudaMalloc(&db,size);
	cudaMalloc(&dc,size);
	
	cudaMemcpy(da,a,size,cudaMemcpyHostToDevice);
	cudaMemcpy(db,b,size,cudaMemcpyHostToDevice);
	
	dim3 grid((N+15)/16,(N+15)/16);
	dim3 block(16,16);
	
	cudaEventRecord(start);
	mul<<<grid,block>>>(da,db,dc,N);
	cudaEventRecord(stop);
	
	cudaMemcpy(c,dc,size,cudaMemcpyDeviceToHost);
	cudaEventSynchronize(stop);
	float ms;
	cudaEventElapsedTime(&ms,start,stop);
	
	for(i = 0; i<N; i++)
		for(j = 0; j<N; j++)
		{
			d[i*N+j] = 0.0;
			for(k = 0; k<N; k++)
			{
							d[i*N+j] += a[i*N+k]*b[k*N+j];
			}
			if(d[i*N+j] != c[i*N+j])
			{
				printf("Inmcoreect\n");
				exit(-2);
			}
		}
		
	printf("%lf\n",ms);	
}