#include "HANDLER/Memory.hpp"

#include <cuda_runtime_api.h>
#include <stdio.h>
#include <stdlib.h>

static const char *memoryErrSring(CORE::MemoryErr err)
{
  switch (err)
  {
    case CORE::memorySucess      : return "OK";

    case CORE::memoryErrOOM      : return "(MEMORY) out of memory";
    case CORE::memoryErrOOB      : return "(MEMORY) out of bound";
    case CORE::memoryErrInvalid  : return "(MEMORY) invalid value";
    case CORE::memoryErrState    : return "(MEMORY) invalid state";
    case CORE::memoryErrFree     : return "(MEMORY) can't free";
    case CORE::memoryErrDestroy  : return "(MEMORY) can't destroy";

    default: return "Undefined Error";
  }
}

static const char *memoryTypeSring(CORE::MemoryType mType)
{
  switch (mType)
  {
    case CORE::memoryTypeCpu : return "Cpu Only";
#if CPU_GPU == 1
    case CORE::memoryTypeGpu : return "Gpu Only";
    case CORE::memoryTypeBoth: return "Cpu And Gpu";
#endif
    default: return "Uknown Device";
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

static void destroyCpuMemory(void *cpuPtr)
{
#if CPU_GPU == 1
  if(cudaFreeHost(cpuPtr) != cudaSuccess) CORE::logWarn(__FILE__, __LINE__, "(MEMORY) can't free");
#else
  free(cpuPtr);
#endif
}

#if CPU_GPU == 1
static void destroyGpuMemory(void *gpuPtr)
{
  if(cudaFree(gpuPtr) != cudaSuccess) CORE::logWarn(__FILE__, __LINE__, "(MEMORY) can't free");
}

static void destroyBothMemory(void *cpuPtr, void *gpuPtr)
{
  destroyCpuMemory(cpuPtr);
  destroyGpuMemory(gpuPtr);
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
    case CORE::memoryTypeCpu: destroyCpuMemory(this->cpuPtr); break;
#if CPU_GPU == 1
    case CORE::memoryTypeGpu: destroyGpuMemory(this->gpuPtr); break;
    case CORE::memoryTypeBoth: destroyBothMemory(this->cpuPtr, this->gpuPtr); break;
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

void HANDLER::Memory::allocateCpu(void **ptr, size_t size, CORE::Aligne aligneTo)
{
  this->err = CORE::memorySucess;

  if(ptr == NULL)
  {
    this->err = CORE::memoryErrNull;
    return;
  }
#if CPU_GPU == 1
  if(this->mType == CORE::memoryTypeGpu)
  {
    this->err = CORE::memoryErrInvalid;
    return;
  }
#endif
  size_t alignedSize = CORE::ALIGNE(size, aligneTo);

  if(this->cpuCapacity - this->cpuOffset < alignedSize)
  {
    this->err = CORE::memoryErrOOM;
    return;
  }

  *ptr = (uint8_t *) this->cpuPtr + this->cpuOffset;
  this->cpuOffset += alignedSize;
}

void HANDLER::Memory::allocateCpu(VIEW::Buffer& buff, size_t size, CORE::Aligne aligneTo)
{
  this->allocateCpu(&buff.data, size, aligneTo);
  if(this->err != CORE::memorySucess) return;
  buff.bytes = CORE::ALIGNE(size, aligneTo);
  buff.mType = CORE::memoryTypeCpu;
}

void HANDLER::Memory::resetCpu()
{
  this->err = CORE::memorySucess;
#if CPU_GPU == 1
  if(this->mType == CORE::memoryTypeGpu)
  {
    this->err = CORE::memoryErrInvalid;
    return;
  }
#endif  
  this->cpuOffset = 0;
}

#if CPU_GPU == 1
size_t HANDLER::Memory::getMemoryGpuCapacity() const
{
  return this->gpuCapacity;
}

void HANDLER::Memory::allocateGpu(void **ptr, size_t size, CORE::Aligne aligneTo)
{
  this->err = CORE::memorySucess;

  if(ptr == NULL)
  {
    this->err = CORE::memoryErrNull;
    return;
  }

  if(this->mType == CORE::memoryTypeCpu)
  {
    this->err = CORE::memoryErrInvalid;
    return;
  }

  size_t alignedSize = CORE::ALIGNE(size, aligneTo);

  if(this->gpuCapacity - this->gpuOffset < alignedSize)
  {
    this->err = CORE::memoryErrOOM;
    return;
  }

  *ptr = (uint8_t *) this->gpuPtr + this->gpuOffset;
  this->gpuOffset += alignedSize;
}

void HANDLER::Memory::allocateGpu(VIEW::Buffer& buff, size_t size, CORE::Aligne aligneTo)
{
  this->allocateGpu(&buff.data, size, aligneTo);
  if(this->err != CORE::memorySucess) return;
  buff.bytes = CORE::ALIGNE(size, aligneTo);
  buff.mType = CORE::memoryTypeGpu;
}

void HANDLER::Memory::resetGpu()
{
  this->err = CORE::memorySucess;

  if(this->mType == CORE::memoryTypeCpu)
  {
    this->err = CORE::memoryErrInvalid;
    return;
  }
  this->gpuOffset = 0;
}
#endif

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

void HANDLER::Memory::log(CORE::State level, const char *file, int line) const
{
  switch (level)
  {
    case CORE::INFO :  CORE::logInfo(file, line, memoryErrSring(this->err));  return;
    case CORE::WARN :  CORE::logWarn(file, line, memoryErrSring(this->err));  return;
    case CORE::FATAL:  CORE::logFatal(file, line, memoryErrSring(this->err)); return;
  }
}

void HANDLER::Memory::info() const
{
  printf
(
"\
=============================================\n\
    Cpu Info:\n\
      pointer  (void): ( %16p  )\n\
      offset   (size): ( %16zu  )\n\
      capacity (size): ( %16zu  )\n\
"
#if CPU_GPU == 1
"\n\
    Gpu Info:\n\
      pointer  (void): ( %16p  )\n\
      offset   (size): ( %16zu  )\n\
      capacity (size): ( %16zu  )\n\
"
#endif
"\n\
  Memory Type  (string):  %s \n\
  Memory State (string):  %s \n\
=============================================\n\
", 
this->cpuPtr, this->cpuOffset, this->cpuCapacity,
#if CPU_GPU == 1
this->gpuPtr, this->gpuOffset, this->gpuCapacity,
#endif
memoryTypeSring(this->mType), memoryErrSring(this->err));
}