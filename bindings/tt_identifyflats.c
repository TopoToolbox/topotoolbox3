#include "mex.h"
#include "topotoolbox.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

  if (nrhs != 1) {
    mexErrMsgIdAndTxt("tt3:tt_identifyflats:nrhs", "One input required");
  }
  if (nlhs != 1) {
    mexErrMsgIdAndTxt("tt3:tt_identifyflats:nrls", "One output required");
  }

  const mxArray *demArray = prhs[0];
  float *dem = mxGetSingles(demArray);
  ptrdiff_t dims[2];
  dims[0] = mxGetM(demArray);
  dims[1] = mxGetN(demArray);

  plhs[0] = mxCreateNumericMatrix(dims[0], dims[1], mxINT32_CLASS, mxREAL);
  int32_t *out = mxGetInt32s(plhs[0]);

  identifyflats(out, dem, dims);
}
