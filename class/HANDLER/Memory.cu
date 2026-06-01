#include "HANDLER/Memory.hpp"

#include <cuda_runtime_api.h>
#include <stdlib.h>

static char *memoryErrSring(CORE::MemoryErr err)
{
  switch (err)
  {
    case CORE::memorySucess      : return "OK";

    case CORE::memoryErrOOM      : return "(MEMORY) out of memory";
    case CORE::memoryErrOOB      : return "(MEMORY) out of bound";
    case CORE::memoryErrInvalide : return "(MEMORY) invalid value";
    case CORE::memoryErrState    : return "(MEMORY) invalid state";
    case CORE::memoryErrFree     : return "(MEMORY) can't free";
    case CORE::memoryErrDestroy  : return "(MEMORY) can't destroy";

    default: return "Undefined Error";
  }
}

static void initCpuMemory(void **cpuPtr, size_t& cpuCapacity, size_t capacity, CORE::MemoryErr& err)
{
  size_t alignedCapacity = CORE::ALIGNE(capacity, CORE::ALIGNE_TO_256);
#if CPU_GPU == 1
  if(cudaMallocHost(cpuPtr, alignedCapacity) != cudaSuccess)
  {
    err = CORE::memoryErrOOM;
    return;
  }
#else
  *cpuPtr = aligned_alloc(CORE::ALIGNE_TO_256, alignedCapacity);
  if(*cpuPtr == NULL)
  {
    err = CORE::memoryErrOOM;
    return;
  }
#endif
  cpuCapacity = alignedCapacity;
}

#if CPU_GPU == 1
static void initGpuMemory(void **gpuPtr, size_t& gpuCapacity, size_t capacity, CORE::MemoryErr& err)
{
  size_t alignedCapacity = CORE::ALIGNE(capacity, CORE::ALIGNE_TO_256);
  if(cudaMalloc(gpuPtr, alignedCapacity) != cudaSuccess)
  {
    err = CORE::memoryErrOOM;
    return;
  }
  gpuCapacity = alignedCapacity;
}

static void initBothMemory(void **cpuPtr, void **gpuPtr, size_t& cpuCapacity, size_t& gpuCapacity, size_t capacity, CORE::MemoryErr& err)
{
  initCpuMemory(cpuPtr, cpuCapacity, capacity, err);
  initGpuMemory(gpuPtr, gpuCapacity, capacity, err);
}
#endif

static void destroyCpuMemory(void *cpuPtr, CORE::MemoryErr& err)
{
#if CPU_GPU == 1
  if(cudaFreeHost(cpuPtr) != cudaSuccess)
  {
    err = CORE::memoryErrDestroy;
    return;
  }
#else
  free(cpuPtr);
#endif
}

#if CPU_GPU == 1
static void destroyGpuMemory(void *gpuPtr, CORE::MemoryErr& err)
{
  if(cudaFree(gpuPtr) != cudaSuccess)
  {
    err = CORE::memoryErrDestroy;
    return;
  }
}

static void destroyBothMemory(void *cpuPtr, void *gpuPtr, CORE::MemoryErr& err)
{
  destroyCpuMemory(cpuPtr, err);
  if(err != CORE::memorySucess) return;
  destroyGpuMemory(gpuPtr, err);
}
#endif

HANDLER::Memory::Memory(size_t capacity, CORE::MemoryType mType)
{
  switch (mType)
  {
    case CORE::memoryTypeCpu: initCpuMemory(&this->cpuPtr, this->cpuCapacity, capacity, this->err); break;
#if CPU_GPU == 1
    case CORE::memoryTypeGpu: initGpuMemory(&this->gpuPtr, this->gpuCapacity, capacity, this->err); break;
    case CORE::memoryTypeBoth: initBothMemory(&this->cpuPtr, &this->gpuPtr, this->cpuCapacity, this->gpuCapacity, capacity, this->err); break;
#endif
  }
  this->mType = mType;
}

HANDLER::Memory::~Memory()
{
  switch (this->mType)
  {
    case CORE::memoryTypeCpu: destroyCpuMemory(this->cpuPtr, this->err); break;
#if CPU_GPU == 1
    case CORE::memoryTypeGpu: destroyGpuMemory(this->gpuPtr, this->err); break;
    case CORE::memoryTypeBoth: destroyBothMemory(this->cpuPtr, this->gpuPtr,this->err); break;
#endif
  }
}

CORE::MemoryType HANDLER::Memory::getMemoryType() const
{
  return this->mType;
}

size_t HANDLER::Memory::getMemoryCpuCapacity() const
{
  return this->cpuCapacity;
}
size_t HANDLER::Memory::getMemoryGpuCapacity() const
{
  return this->gpuCapacity;
}

void HANDLER::Memory::allocateCpu(void **ptr, size_t size, CORE::Aligne aligneTo = CORE::ALIGNE_TO_256)
{

}

void HANDLER::Memory::allocateGpu(void **ptr, size_t size, CORE::Aligne aligneTo = CORE::ALIGNE_TO_256)
{

}

void HANDLER::Memory::reset(CORE::MemoryType mType)
{
  this->cpuOffset = 0;
  this->gpuOffset = 0;
}

CORE::MemoryErr HANDLER::Memory::peekErr() const
{
  return this->err;
}

CORE::MemoryErr HANDLER::Memory::getErr() 
{
  CORE::MemoryErr err = this->err;
  this->err = CORE::memorySucess;
  return err;
}

void HANDLER::Memory::log(CORE::State level = CORE::INFO, const char *file = __FILE__, int line = __LINE__) const
{

}