#if !defined(CORE_STATE_HPP)
#define CORE_STATE_HPP

#include <stddef.h>
#include <stdint.h>

/** @brief Select CPU backend: 0 , Select GPU backend: 1. */
#ifndef CPU_GPU
#define CPU_GPU 0
#endif

namespace CORE
{
  /** @brief Supported byte alignment constants. */
  enum Aligne
  {
    ALIGNE_TO_32  = 32,
    ALIGNE_TO_64  = 64,
    ALIGNE_TO_128 = 128,
    ALIGNE_TO_256 = 256,
  };

  /** @brief Common arena sizes used by handlers and workspace. */
  enum MemorySize
  {
    memorySize32MB  = 32 * 1024 * 1024,
    memorySize64MB  = 2 * memorySize32MB,
    memorySize128MB = 2 * memorySize64MB,
    memorySize256MB = 2 * memorySize128MB,
    memorySize512MB = 2 * memorySize32MB,
    memorySize1GB   = 2 * memorySize512MB,
  };

  enum MemoryType
  {
    memoryTypeCpu = 0,
#if CPU_GPU == 1
    memoryTypeGpu = 1,
    memoryTypeBoth = 2,
#endif
  };

  enum MemoryErr
  {
    memorySucess      = 0,
    memoryErrNull     = 1 << 1,
    memoryErrOOM      = 1 << 2,
    memoryErrOOB      = 1 << 3,
    memoryErrInvalid = 1 << 4,
    memoryErrState    = 1 << 5,
    memoryErrFree     = 1 << 6,
    memoryErrDestroy  = 1 << 7,
  };

  /** @brief Log severity. */
  enum State
  {
    INFO = 0,
    WARN,
    FATAL,
  };

  #define logInfo(file, line, x, ...) printState(CORE::INFO, file, line, x, ##__VA_ARGS__);
  #define logWarn(file, line, x, ...) printState(CORE::WARN, file, line, x, ##__VA_ARGS__);
  #define logFatal(file, line, x, ...) printState(CORE::FATAL, file, line, x, ##__VA_ARGS__);
  
  /** @brief Print a formatted project log message. @param level Log severity. @param file Source file name. @param line Source line. @param fmt printf-style format string. */
  void printState(State level, const char *file, int line, const char *fmt, ...);

  /** @brief Align a byte count upward. @param x Input byte count. @param aligneTo Alignment boundary. @return Aligned byte count. */
  inline size_t aligne(size_t x, CORE::Aligne aligneTo) 
  {return (x + uintptr_t(aligneTo - 1)) & ~uintptr_t(aligneTo - 1);}

  #define ALIGNE(x, aligneTo) aligne(x, aligneTo)
}

#endif /* CORE_STATE_HPP */
