#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>
#include <thrust/complex.h>
#include <iostream>
#include "defines.h"

static thrust::complex<double>* intensity;
static uint8_t* image;
__global__ void initializeVariables(thrust::complex<double>* intensity, uint8_t* image) {
    int i = blockIdx.y * blockDim.y + threadIdx.y;
    int j = blockIdx.x * blockDim.x + threadIdx.x;
    int idx = i * ny + j;
    intensity[idx] = 0;
    image[idx * 4]=0;
    image[idx * 4+1]=0;
    image[idx * 4+2]=0;
    image[idx * 4+3]=255;
}

void CUDA_INIT() {
	cudaMalloc(&intensity,nx * ny * sizeof(thrust::complex<double>));
    cudaMalloc(&image, 4 * nx * ny * sizeof(uint8_t));
    dim3 dimGrid(nx / BLOCK_SIZE, ny / BLOCK_SIZE, 1);
    dim3 dimBlock(BLOCK_SIZE, BLOCK_SIZE, 1);
    initializeVariables << <dimGrid, dimBlock >> > (intensity, image);
}

__global__ void dev_apply_light(double x, double y,thrust::complex<double>* intensity){
    int i = blockIdx.y * blockDim.y + threadIdx.y;
    int j = blockIdx.x * blockDim.x + threadIdx.x;
    const thrust::complex<double> k(0.0, 1.0);
    double d = std::pow(((double)y)-((double)i * outscale ), 2) + std::pow(((double)x)-((double)j * outscale), 2);
    double theta = std::atan(std::sqrt(d) / L);
    double skew = (1 + std::cos(theta)) / 2;
    double r = std::sqrt(d + std::pow(L, 2));
    double phase = 2.0 * 3.14159265 * std::sqrt(d+std::pow(L,2)) / wavelenght;
    thrust::complex<double> res = (I_0 * thrust::exp(k * phase)) * skew * L / (d + std::pow(L, 2));
    intensity[i * ny + j] += (I_0 * thrust::exp(k * phase)) * skew *  L / (d + std::pow(L, 2));
}

void apply_light(double x, double y) {
    dim3 dimGrid(nx / BLOCK_SIZE, ny / BLOCK_SIZE, 1);
    dim3 dimBlock(BLOCK_SIZE, BLOCK_SIZE, 1);
    dev_apply_light<<<dimGrid,dimBlock>>>(x, y, intensity);
}
__device__ uint8_t dev_get_colour(int i, int j, thrust::complex<double>* intensity) {
    int idx = i * ny + j;
    double val = thrust::norm(intensity[idx]);
    if (val > 255) {
        return 255;
    }
    else {
        
        return (uint8_t)(val);
    }
}
__global__ void kernel_create_color(thrust::complex<double>* intensity, uint8_t* image) {
    int i = blockIdx.y * blockDim.y + threadIdx.y;
    int j = blockIdx.x * blockDim.x + threadIdx.x;
    image[(i * ny + j) * 4] = dev_get_colour(i,j,intensity);
}
void get_colour(uint8_t* pixel_buffer) {
    dim3 dimGrid(nx / BLOCK_SIZE, ny / BLOCK_SIZE, 1);
    dim3 dimBlock(BLOCK_SIZE, BLOCK_SIZE, 1);
    check_error();
    kernel_create_color << <dimGrid, dimBlock >> > (intensity, image);
    check_error();
    cudaMemcpy(pixel_buffer, image, 4 * ny * nx * sizeof(uint8_t), cudaMemcpyDeviceToHost);
    check_error();
}