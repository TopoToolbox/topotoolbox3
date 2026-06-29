function K = surfacefitkernel(DEM,ws,options)

%SURFACEFITKERNEL Convolution kernels for fitting local polynomials
%
% Syntax
%
%     K = surfacefitkernel(DEM,ws)
%     K = surfacefitkernel(DEM,ws,usepinv = true)
%
% Description
%
%     Locally fitting a 2D parabolic surface is efficiently computed using
%     convolution kernels. This function returns a structure array K with
%     kernels (to be used by conv2) which can then be applied to the
%     digital elevation model DEM for square kernels of size ws.
%
% Input arguments
%
%     DEM   GRIDobj (used to obtain the cell size)
%     ws    scalar giving the kernel size in pixels (must be an odd number)
%
%     Input arguments
%
%     'usepinv'  {true} or false. If true, pinv is used instead of inv.
%
% Output arguments
%
%     K     structure array with kernels. See Shary et al. (2002)
%
% References
%
%     Shary, P. A., Sharaya, L. S., and Mitusov, A. V.: Fundamental 
%     quantitative methods of land surface analysis, Geoderma, 107, 1–32, 
%     https://doi.org/10.1016/S0016-7061(01)00136-7, 2002.
%
% See also: GRIDobj/curvature, GRIDobj/fastcurvaturefit, GRIDobj/troughness
% 
% Author: Wolfgang Schwanghart (schwangh[at]uni-potsdam.de)
% Date: 25. June, 2026



arguments
    DEM   GRIDobj
    ws   (1,1) {validateattributes(ws,...
                {'numeric'},{'positive','integer','odd'})} = 3
    options.usepinv (1,1) = true
end

% Calculate distances
DX      = -floor(ws/2):floor(ws/2);
DX      = DX*DEM.cellsize;
[DX,DY] = meshgrid(DX);
DX      = DX(:);
DY      = DY(:);

N       = ws^2;

% Design matrix for polynomial fitting
X  = [DX.^2 DY.^2 DX.*DY DX DY ones(N,1)];

% Determine inverse for calculating parameter estimates
if options.usepinv
    PM = pinv(X);
else
    PM = inv(X'*X)*X';
end

% Calculate kernels
K.r = reshape(PM(1,:),ws,ws);
K.t = reshape(PM(2,:),ws,ws);
K.s = reshape(PM(3,:),ws,ws);
K.p = reshape(PM(4,:),ws,ws);
K.q = reshape(PM(5,:),ws,ws);
K.o = reshape(PM(6,:),ws,ws);


