function DEM = egm96heights(DEM)

%EGM96HEIGHTS Read and resample EGM96 geoid heights
%
% Syntax
%
%     EGM96 = egm96heights(DEM)
%
% Description
%
%     EGM96HEIGHTS returns the egm 96 geoid heights as GRIDobj that
%     is spatially aligned with the input GRIDobj DEM.
%
%     This function requires the mapping toolbox that includes the 
%     function egm96geoid.
%
% Input arguments
%
%     DEM      GRIDobj
%     
% Output arguments
%
%     EGM96    GRIDobj with geoid heights
%
% Example
%
%     DEM = GRIDobj('srtm_bigtujunga30m_utm11.tif');
%     EGM96 = egm96heights(DEM);
%     imageschs(DEM,EGM96)
%
% See also: GRIDobj, egm96geoid
%
% Author: Wolfgang Schwanghart (schwangh[at]uni-potsdam.de)
% Date: 24. June, 2024

if isProjected(DEM)
    [x,y] = getcoordinates(DEM,'mat');
    [lat,lon] = projinv(DEM.georef.ProjectedCRS,x(:),y(:));
    N = egm96geoid(lat,lon);
    N = reshape(N,size(x));
elseif isGeographic(DEM)
    N = egm96geoid(DEM.georef);
else
    N = egm96geoid(DEM.georef);       
end

DEM.Z = N;
