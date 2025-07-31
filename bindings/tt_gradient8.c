/*

tt_gradient8.c

*/

#include "matrix.h"
#include "mex.h"
#include "topotoolbox.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
  // INPUTS: DEM, cellsize, use_mp
  // OUTPUTS: output
  if (nrhs != 3) {
    mexErrMsgIdAndTxt("tt3:tt_gradient8:nrhs", "Three inputs required");
  }
  if (nlhs != 1) {
    mexErrMsgIdAndTxt("tt3:tt_gradient8:nlhs", "One output required");
  }

  const mxArray *demArray = prhs[0];
  float *dem = mxGetSingles(demArray);

  float cellsize  = (float) mxGetScalar(prhs[1]);
  int use_mp = (int) mxGetScalar(prhs[2]);

  ptrdiff_t dims[2];
  dims[0] = mxGetM(demArray);
  dims[1] = mxGetN(demArray);

  // Null pointer checks are not needed because out-of-memory errors
  // will terminate the MEX function.
  plhs[0] = mxCreateNumericMatrix(dims[0], dims[1], mxSINGLE_CLASS, mxREAL);
  float *output = mxGetSingles(plhs[0]);

  // Converted to float to avoid compiler warnings
  gradient8(output, dem, (float) cellsize, (int) use_mp, dims);

}
