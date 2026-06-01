#if !defined(HANDLER_MEMORY_HPP)
#define HANDLER_MEMORY_HPP

#include "CORE/State.hpp"

namespace HANDLER
{
  class __align__(CORE::ALIGNE_TO_256) Memory
  {
    private:
      void *cpuPtr = NULL;
      size_t cpuOffset = 0;
      size_t cpuCapacity = 0;

#if CPU_GPU == 1
      void *gpuPtr = NULL;
      size_t gpuOffset = 0;
      size_t gpuCapacity = 0;
#endif

      CORE::MemoryType mType = CORE::memoryTypeCpu;
      CORE::MemoryErr err = CORE::memorySucess;
    public:
      Memory(size_t capacity = CORE::memorySize32MB, CORE::MemoryType mType = CORE::memoryTypeCpu);
      ~Memory();

      CORE::MemoryType getMemoryType() const;

      size_t getMemoryCpuCapacity() const;

      size_t getMemoryGpuCapacity() const;

      void allocateCpu(void **ptr, size_t size, CORE::Aligne aligneTo = CORE::ALIGNE_TO_256);

      void allocateGpu(void **ptr, size_t size, CORE::Aligne aligneTo = CORE::ALIGNE_TO_256);

      void reset(CORE::MemoryType mType);

      CORE::MemoryErr peekErr() const;

      CORE::MemoryErr getErr();

      void log(CORE::State level = CORE::INFO, const char *file = __FILE__, int line = __LINE__) const;
  };
}

#endif /* HANDLER_MEMORY_HPP */
