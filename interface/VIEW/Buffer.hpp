#if !defined(VIEW_BUFFER_HPP)
#define VIEW_BUFFER_HPP

#include "CORE/State.hpp"

namespace VIEW
{

  struct __align__(CORE::ALIGNE_TO_256) Buffer
  {
    void *data;
    size_t bytes;
    CORE::MemoryType mType = CORE::memoryTypeCpu;
  };
  
} 

#endif /* VIEW_BUFFER_HPP */
