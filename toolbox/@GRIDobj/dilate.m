function DEM = dilate(DEM,SE)

%DILATE Morphological dilation
%
% Syntax
%
%     DEMd = dilate(DEM,SE)
%
% Description
%
%     dilate is a simple wrapper around imdilate that handles nans.
%
% Input arguments
%
%     DEM     GRIDobj
%     SE      structuring element. Default is ones(3).
%
% Output arguments
%
%     DEMd    GRIDobj
%
% See also: imdilate, GRIDobj/erode
%
% Author: Wolfgang Schwanghart (schwangh[at]uni-potsdam.de)
% Date: 10. December, 2024

arguments
    DEM  GRIDobj
    SE   = ones(3)
end

if isa(DEM.Z,'double') || isa(DEM.Z,'single')
    I = isnan(DEM.Z);
    DEM.Z(I) = -inf;
    checknans = true;
else
    checknans = false;
end

DEM.Z = imdilate(DEM.Z,SE);
if checknans
    DEM.Z(I) = nan;
end
