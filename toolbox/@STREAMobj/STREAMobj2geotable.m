function GT = STREAMobj2geotable(S,options)

%STREAMobj2geotable Convert STREAMobj to a geotable
%
% Syntax
%
%     GT = STREAMobj2geotable(S)
%     GT = STREAMobj2geotable(S,'seglength',seglength,'type',type)
%     GT = STREAMobj2geotable(...,'attributes',{attname data aggfun ...})
%
% Description
%
%     STREAMobj2geotable takes a STREAMobj and converts it to a geotable. A
%     geotable (geospatial table) is a type of table designed to store and
%     manage geospatial data. It is specifically used for handling data
%     that includes geographic coordinates and associated attributes.
%     Geotables are part of MATLAB's Mapping Toolbox. They store coordinate
%     reference systems, and can be exported to shapefiles. Their use
%     should be preferred over mapstructs (see STREAMobj2mapstruct).
%
% Input parameters
%
%     S       STREAMobj
%     
%     Parameter name/value pairs
%
%     'seglength'   length of line features
%     'type'        'geo' or 'map'. Determines whether the function returns
%                   geometries as geoshape or mapshape objects.
%     'attributes'  cell array with attribute data (see STREAMobj2mapstruct
%                   for details). These data will be aggregated to feature
%                   properties. 
%     'ixsplit'     linear index of locations where the network should be
%                   split into features. 
%
% Output arguments
%
%     GT      geotable
%
% Example
%
%     DEM = GRIDobj('srtm_bigtujunga30m_utm11.tif');
%     FD = FLOWobj(DEM);
%     S = STREAMobj(FD,'minarea',1000);
%     A = flowacc(FD);
%     c = chitransform(S,A);
% 
%     GT = STREAMobj2geotable(S,'type','geo',...
%             'attributes',{...
%             'z' DEM @mean ...
%             'chi' c @mean});
%
%     geoplot(GT,ColorVariable="chi");
% 
% See also: STREAMobj2mapstruct
%
% Author: Wolfgang Schwanghart (schwangh[at]uni-potsdam.de)
% Date: 23. June, 2025

arguments
    S   STREAMobj
    options.type {mustBeMember(options.type,{'geo','map'})} = 'map'
    options.seglength (1,1) {mustBePositive} = max(max(S.distance)/20,5*S.cellsize)
    options.attributes {mustBeA(options.attributes,'cell')} = {}
    options.ixsplit = []
end


% Calculate mapping structure
GT = STREAMobj2mapstruct(S,'seglength',options.seglength,...
    'attributes',options.attributes,'ixsplit',options.ixsplit);

if isProjected(S)
    proj = S.georef.ProjectedCRS;
    t    = 'planar';
elseif isGeographic(S)
    proj = S.georef.GeographicCRS;
    t    = 'geographic';
else
    proj = [];
    t    = 'planar';
end

GT = mapstruct2geotable(GT,'CoordinateReferenceSystem',proj,...
    'coordinateSystemType',t);
GT.ID = (1:size(GT,1))';

if isProjected(S) & strcmp(options.type,'geo')
    GT = projectshape(GT,4326);
end
