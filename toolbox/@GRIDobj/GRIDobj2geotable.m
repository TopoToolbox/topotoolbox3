function [GT,x,y] = GRIDobj2geotable(DB,options)

%GRIDOBJ2GEOTABLE Convert categorical GRIDobj to geotable (polygon) 
%
% Syntax
%
%     GT = GRIDobj2geotable(DB)
%     GT = GRIDobj2geotable(DB,pn,pv,...)
%     [GT,x,y] = GRIDobj2geotable(DB,pn,pv,...)
%
% Description
%
%     GRIDobj2geotable takes a GRIDobj with categorical values and stores
%     the outlines of each region with the same values as geotable.
%     Regions with zero-values will be ignored. 
%
% Input arguments
%
%     DB    GRIDobj with categorical values (this is not meant that the
%           underlying type is categorical but that there are contiguous
%           regions with the same values. These need not to be integer
%           values.)
% 
%     Parameter name/value pairs
%
%     'conn'         8 or 4 connectivity. 8 is default.
%     'holes'        {true} or false
%     'parallel'     {true} or false. If true, function is run in parallel.
%                    Testing is required to check performance differences.
%
% Output arguments
%
%     GT      geotable
%     x,y     nan-punctuated coordinate vectors of the polygon outlines
%     
% Example 1
%
%     DEM = readexample('taalvolcano');
%     I = identifyflats(DEM);
%     I.Z = bwareaopen(I.Z,20);
%     DEM = clip(DEM,~I);
%     imageschs(DEM)
%    
%     C = reclassify(DEM,'equalintervals',5);
%     GT = GRIDobj2geotable(C);
%     geoplot(GT)
%
% Example 2
%
%     DEM = GRIDobj('srtm_bigtujunga30m_utm11.tif');
%     FD  = FLOWobj(DEM);
%     S = STREAMobj(FD,'minarea',1000);
%     D   = drainagebasins(FD,S);
%     GT = GRIDobj2geotable(D);
%
% See also: GRIDobj/reclassify, GRIDobj/GRIDobj2polygon,
%           GRIDobj/cropbyregion
% 
% Author: Wolfgang Schwanghart (schwangh[at]uni-potsdam.de)
% Date: 7. November, 2025 

arguments (Input)
    DB   GRIDobj
    options.simplify = false
    options.tol      = 0
    options.conn      = 8;
    options.holes    = true;
    options.parallel = false;
end

holes = options.holes;
conn  = options.conn;

if isempty(DB.georef)
    error('DB.georef must contain a reference object.')
end

% Check projection
[CRS,isproj] = parseCRS(DB);
if isnan(isproj)
    isgeo = false;
elseif ~isproj
    isgeo = true;
else
    isgeo = false;
end
    
% Disaggregate the grid into subgrids using cropbyregion which uses
% regionprops
C       = cropbyregion(DB);

% Depending on region IDs and whether they are consecutive numbers or not,
% some elements in C will be empty
isvalid = cellfun(@(x) isa(x,'GRIDobj'),C,'UniformOutput',true);

% Remove invalid entries of C
C   = C(isvalid);

% Nr of regions
nregions = numel(C);
% Preallocate cell array of shapes
s   = cell(nregions,1);
% Preallocate cell array of coordinates
xy  = cell(nregions,1);


if options.parallel
    parfor r = 1:numel(s)
        [s{r},xy{r}] = GRIDobj2shape(C{r},"holes",holes,...
                        "conn",conn,"isgeo",isgeo);
    end
else
    for r = 1:numel(s)
        [s{r},xy{r}] = GRIDobj2shape(C{r},"holes",holes,...
                        "conn",conn,"isgeo",isgeo);
    end
end

validIDs = find(isvalid);
validIDs = validIDs(:);
ID = num2cell(validIDs);
Geom = repmat({'Geometry'},nregions,1);
GT = cell2table([s Geom ID],"VariableNames",["Shape" "Geometry" "ID"]);

if isgeo
    GT.Shape.GeographicCRS = CRS;
elseif isproj
    GT.Shape.ProjectedCRS = CRS;
end

if nargout >= 2
    xy = vertcat(xy{:});
    x = xy(:,1);
    y = xy(:,2);
end

