/*

  void traverse_down_f32_add_mul(float *output, float *input,
                                 ptrdiff_t *source,
                                 ptrdiff_t *target,
                                 ptrdiff_t edge_count)  
 */

#include "matrix.h"
#include "mex.h"
#include "topotoolbox.h"

#include <limits.h>
#include <stddef.h>
#include <stdint.h>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
  // [output] = tt_traverse_down_f32_add_mul(output, input, source, target)

  if (nrhs != 4) {
    mexErrMsgIdAndTxt("tt3:tt_traverse_down_f32_add_mul",
                      "Four inputs required");
  }

  if (!mxIsClass(prhs[0], "single")) {
    mexErrMsgIdAndTxt("tt3:tt_traverse_down_f32_add_mul",
                      "output argument must be of class single");
  }

  if (!mxIsClass(prhs[1], "single")) {
    mexErrMsgIdAndTxt("tt3:tt_traverse_down_f32_add_mul",
                      "input argument must be of class single");
  }

  if (!mxIsClass(prhs[2], "int64")) {
    mexErrMsgIdAndTxt("tt3:tt_traverse_down_f32_add_mul",
                      "source argument must be of class int64");
  }

  if (!mxIsClass(prhs[3], "int64")) {
    mexErrMsgIdAndTxt("tt3:tt_traverse_down_f32_add_mul",
                      "target argument must be of class int64");
  }

  if (nlhs != 1) {
    mexErrMsgIdAndTxt("tt3:tt_traverse_down_f32_add_mul", "One output required");
  }

  mwSize edge_count = mxGetM(prhs[1]);
  mwSize m = mxGetM(prhs[0]);
  mwSize n = mxGetN(prhs[1]);

  // MATLAB does not want us to modify input data, so we must copy the
  // `output` parameter.
  plhs[0] = mxDuplicateArray(prhs[0]);
  float *output = mxGetSingles(plhs[0]);
  float *input = mxGetSingles(prhs[1]);

  ptrdiff_t *source = (ptrdiff_t *)mxGetInt64s(prhs[2]);
  ptrdiff_t *target = (ptrdiff_t *)mxGetInt64s(prhs[3]);

  traverse_down_f32_add_mul(output, input, source, target, edge_count);
}
