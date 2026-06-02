#include "HANDLER/Memory.hpp"
#include <stdio.h>


int main()
{
  HANDLER::Memory mem(637820123);
  VIEW::Buffer buff;
  mem.allocateCpu(buff, 6732);
  printf("data: %p\n", buff.data);
  printf("bytes: %zu\n", buff.bytes);
  printf("type of memory (0: cpu, 1: gpu, 2: both): %d\n", buff.mType);
  
  return 0;
}