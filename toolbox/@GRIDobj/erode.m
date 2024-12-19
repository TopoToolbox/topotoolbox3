function DEM = erode(DEM,SE)

%ERODE Morphological erosion
%
% Syntax
%
%     DEMe = erode(DEM,SE)
%
% Description
%
%     erode is a simple wrapper around imerode that handles nans.
%
% Input arguments
%
%     DEM     GRIDobj
%     SE      structuring element. Default is ones(3).
%
% Output arguments
%
%     DEMe    GRIDobj
%
% See also: imerode, GRIDobj/dilate
%
% Author: Wolfgang Schwanghart (schwangh[at]uni-potsdam.de)
% Date: 10. December, 2024

arguments
    DEM  GRIDobj
    SE   = ones(3)
end

if isa(DEM.Z,'double') || isa(DEM.Z,'single')
    I = isnan(DEM.Z);
    DEM.Z(I) = inf;
    checknans = true;
else
    checknans = false;
end

DEM.Z = imerode(DEM.Z,SE);
if checknans
    DEM.Z(I) = nan;
end
