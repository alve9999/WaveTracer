#pragma once

#define print(x) std::cout<<x<<std::endl
#define inscale 0.000001
#define outscale 0.0005
#define nx 500
#define ny 500
#define x_off ((nx*(outscale/inscale)-nx)/2.0)
#define y_off ((ny*(outscale/inscale)-ny)/2.0)
#define L 1.2
#define I_0 0.1
#define wavelenght (632 * std::pow(10.0,-9))
#define BLOCK_SIZE 32

#define check_error() if (cudaGetLastError() != cudaSuccess){std::cout << cudaGetErrorName(cudaGetLastError()) << " " << __FUNCTION__ << " " << __LINE__ << std::endl;exit(1);}

