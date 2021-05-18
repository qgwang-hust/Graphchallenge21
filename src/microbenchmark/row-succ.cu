#include <cuda.h>
#include "../gpu_lib/header.h"
#include "../utils/header.h"
namespace ftxj {
__device__ float __ReLU(float x){
   return x<0.0?0.0:x>32.0?32.0:x;
};

__global__ void __launch_bounds__(1024,1) dummy_kernel(
  float *nextfeat, float *currfeat, 
  int buffsize, int *buffdispl, int *mapdispl, unsigned short *map, 
  int *displ, unsigned short *index, float *value, 
  float bias, int neuron
){
  extern __shared__ float shared[];
  int wind = threadIdx.x % WARPSIZE;
  float reduce[MINIBATCH] = {0.0};
  for(int buff = buffdispl[blockIdx.x]; buff < buffdispl[blockIdx.x+1]; buff++){
    int mapnz = mapdispl[buff+1]-mapdispl[buff];
    for(int n = threadIdx.x; n < mapnz; n += blockDim.x){
      int ind = map[mapdispl[buff]+n];
      for(unsigned int f = 0; f < MINIBATCH; f++)
        shared[f*buffsize+n] = currfeat[(blockIdx.y * MINIBATCH+f) * (unsigned int) neuron+ind];
    }
    __syncthreads();
    int warp = (buff*blockDim.x+threadIdx.x)/WARPSIZE;
    for(int m = displ[warp]; m < displ[warp+1]; m++){
      int ind = index[m*WARPSIZE+wind];
      float val = value[m*WARPSIZE+wind];
      for(int f = 0; f < MINIBATCH; f++)
        reduce[f] += shared[f*buffsize+ind]*val;
    }
    __syncthreads();
  }
  int m = blockIdx.x*blockDim.x+threadIdx.x;
  for(int f = 0; f < MINIBATCH; f++)
    nextfeat[(blockIdx.y*MINIBATCH+f) * neuron + m] = __ReLU(reduce[f]+bias);
    
};

};