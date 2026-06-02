#include "VIEW/Tensor.hpp"

static void extRankShapeStride(int& rank, int shape[4], int stride[4])
{
  int tmpShape[4] = {0}, baseShape = 0; rank = 0;
  while (baseShape < MAX_RANK)
  { 
    stride[baseShape] = 0;
    if(shape[baseShape] != 0) tmpShape[rank++] = shape[baseShape];
    baseShape++;
  }

  #pragma unroll
  for (size_t i = 0; i < MAX_RANK; i++) shape[i] = tmpShape[i];

  int tmpStride = 1, len = rank - 1;

  #pragma unroll
  for (int i = 0; i < rank; i++)
  {
    stride[len - i] = tmpStride;
    tmpStride *=  shape[len - i];
  }
}

VIEW::Tensor::Tensor(int i, int j, int k, int l)
{
  this->shape[0] = i;
  this->shape[1] = j;
  this->shape[2] = k;
  this->shape[3] = l;
  extRankShapeStride(this->rank, this->shape, this->stride);
}

VIEW::Tensor::~Tensor()
{}

VIEW::Buffer& VIEW::Tensor::getBuffer()
{
  return this->buff;
}

int VIEW::Tensor::getRank() const
{
  return this->rank;
}

int *VIEW::Tensor::getShape()
{
  return this->shape;
}

int *VIEW::Tensor::getStride()
{
  return this->stride;
}

float VIEW::Tensor::getDataAt(int i, int j, int k, int l) const
{
  int offset = (i * this->stride[0] + j * this->stride[1] + k * this->stride[2] + l * this->stride[3]) * sizeof(float);
  if(offset > this->buff.bytes) return 0;
  return (float) *((float *)this->buff.data + offset);
}

void VIEW::Tensor::setDataAt(float value, int i, int j, int k, int l)
{
  int offset = (i * this->stride[0] + j * this->stride[1] + k * this->stride[2] + l * this->stride[3]) * sizeof(float);
  ((float *)this->buff.data)[offset] = value;
}

void VIEW::Tensor::setShape(int i, int j, int k, int l)
{
  this->shape[0] = i;
  this->shape[1] = j;
  this->shape[2] = k;
  this->shape[3] = l;
  extRankShapeStride(this->rank, this->shape, this->stride);
}