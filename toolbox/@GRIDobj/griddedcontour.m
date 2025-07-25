function C = griddedcontour(DEM,level,fourconn)

%GRIDDEDCONTOUR plot contours on grid
%
% Syntax
%
%     C = griddedcontour(DEM,n)
%     C = griddedcontour(DEM,levels)
%     C = griddedcontour(...,fourconn)
%
% Description
%
%     griddedcontour wraps the function contour and approximates the lines
%     on a grid.
%
% Input arguments
%
%     DEM       grid (class: GRIDobj)
%     n         number of contour levels
%     levels    vector with levels (if only one specific level should be 
%               returned, use [level level]).
%     fourconn  true or false (default). If true, gridded contours will be
%               modified to be four-connected lines.
%  
% Output arguments
%
%     C         instance of GRIDobj
%
% Example
%
%     DEM = GRIDobj('srtm_bigtujunga30m_utm11.tif');
%     C = griddedcontour(DEM,[100:100:2000]);
%     imageschs(DEM,dilate(C,ones(3)));
%
% See also: GRIDobj, GRIDobj/imageschs, GRIDobj/contour
%
% Author: Wolfgang Schwanghart (schwangh[at]uni-potsdam.de)
% Date: 3. June, 2024

arguments
    DEM    GRIDobj
    level  {mustBeNumeric}
    fourconn = false
end

% Compute contour levels
[x,y] = contour(DEM,level);

C = GRIDobj(DEM,'logical');
C.name = 'griddedcontour';

I = ~isnan(x);

C.Z(coord2ind(DEM,x(I),y(I))) = true;

if nargin == 3
    if fourconn
        C.Z = bwmorph(C.Z,'diag');
    end
end
