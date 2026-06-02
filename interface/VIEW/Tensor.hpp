#if !defined(VIEW_TENSOR_HPP)
#define VIEW_TENSOR_HPP

#include "CORE/State.hpp"

#include "VIEW/Buffer.hpp"

namespace VIEW
{
  #define MAX_RANK 4

  class __align__(CORE::ALIGNE_TO_256) Tensor // is float based
  {
  private:
    VIEW::Buffer buff;
    int rank;
    int shape[MAX_RANK] = {0};
    int stride[MAX_RANK] = {0};
    
  public:
    Tensor(int i = 0, int j = 0, int k = 0, int l = 0);
    ~Tensor();

    VIEW::Buffer& getBuffer();

    int getRank() const;

    int *getShape();

    int *getStride();

    float getDataAt(int i = 0, int j = 0, int k = 0, int l = 0) const;

    void setDataAt(float value, int i = 0, int j = 0, int k = 0, int l = 0);

    void setShape(int i = 0, int j = 0, int k = 0, int l = 0);
  };
} 

#endif /* VIEW_TENSOR_HPP */
