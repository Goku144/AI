#include "HANDLER/Memory.hpp"
#include "VIEW/Tensor.hpp"

#include <stdio.h>

int main()
{
  HANDLER::Memory mem(637820123);
  VIEW::Tensor t(1,2,3);
  mem.allocateCpu(t.getBuffer(), 6732);
  t.setDataAt(2.645f,0,1,1);
  t.setShape(3,0,3,8);
  printf("data: %.3f\n", t.getDataAt(0,0,4));
  printf("rank: %d\n", t.getRank());
  printf("shape: %d %d %d %d\n", t.getShape()[0], t.getShape()[1], t.getShape()[2], t.getShape()[3]);
  printf("stride: %d %d %d %d\n", t.getStride()[0], t.getStride()[1], t.getStride()[2], t.getStride()[3]);
  return 0;
}