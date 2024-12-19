function GT = mapstruct2geotable(MS,options)
%MAPSTRUCT2GEOTABLE Convert a mapping structure to a geotable
%
% Syntax
%
%     GT = mapstruct2geotable(MS)
%     GT = mapstruct2geotable(MS,pn,pv,...)
%
% Description
%
%     The function converts a mapping structure (mapstruct) MS to a
%     geotable GT. Geospatial tables are table objects with a Shape 
%     variable and attribute variables. It thus resembles the way how
%     shapefiles are stored and how vector data are handled by the package
%     sf in R.
%
% Input arguments
%
%     MS     Mapping structure (mapstruct). The structure array must have
%            a Geometry field, as well as two fields with coordinates.
%            The coordinates fields must have the names 'X' and 'Y', or 'x'
%            and 'y', or 'lat' and 'lon' or 'Latitude' and 'Longitude'. 
%
%     Parameter name/value pairs
%
%     coordinateSystemType   {'geographic'} or 'planar'
%     CoordinateReferenceSystem   geocrs or projcrs object or numeric
%                            scalar that is understood by either geocrs or
%                            projcrs. Default is geocrs(4326). This assumes
%                            that the data is in a geographic coordinate
%                            system of the horizontal WGS84 systm. It is
%                            also possible to supply a GRIDobj from which
%                            the reference system is extracted using
%                            parseCRS.
%
% Output arguments
%
%     GT     geotable
%
% Example
%
%     DEM = GRIDobj('srtm_bigtujunga30m_utm11.tif');
%     FD = FLOWobj(DEM);
%     S = STREAMobj(FD,'minarea',1000);
%     MS = STREAMobj2mapstruct(S);
%     GT = mapstruct2geotable(MS,'CoordinateReferenceSystem',32611);
%     geoplot(GT)
%
% See also: table2geotable, parseCRS
%
% Author: Wolfgang Schwanghart (schwangh[at]uni-potsdam.de)
% Date: 17. June, 2024

arguments
    MS   {mustBeA(MS,'struct')}
    options.varnames {mustBeA(options.varnames,'cell')} = {}
    options.coordinateSystemType ...
        {mustBeMember(options.coordinateSystemType,{'planar','geographic'})} ...
        = 'geographic'
    options.CoordinateReferenceSystem = geocrs(4326)
end

% Check if there is a geometry field
fn = fieldnames(MS);
IGeometry  = strcmpi(fn,'geometry');
if any(IGeometry)
    GeometryType = MS(1).(fn{IGeometry});
    switch lower(GeometryType)
        case 'polyline'
            GeometryType = 'line';
        otherwise
            GeometryType = validatestring(GeometryType,...
                {'point','line','polygon'});
    end
else
    error('TopoToolbox:input','MS must have a geometry field.')
end

% Delete geometry field
MS = rmfield(MS,fn{IGeometry});

% Extract variable names containing the coordinates    
if isempty(options.varnames)
    [varnames,islatlon] = getCoordNames(fn);
    % If varnames are lat-lon, then there's no doubt that these coordinates
    % are geographic. If coordinate names are X and Y there's still the
    % possibility that these are actually geographic. Thus, if they are in
    % a range of -180 to 180 and -90 to 90, then they are also believed to 
    % be geographic.

    if ~islatlon

        XC = {MS.(varnames{1})};
        YC = {MS.(varnames{2})};
        
        minx = min(cellfun(@min,XC));
        maxx = max(cellfun(@max,XC));
        miny = min(cellfun(@min,YC));
        maxy = max(cellfun(@max,YC));

        if minx>=-180 && maxx <= 180 && miny >=-90 && maxy <= 90
            islatlon = true;
            varnames = fliplr(varnames);
        else
            islatlon = false;
        end
    end
end

% Make sure that vectors in MS are row vectors (required by table2geotable)
fun = @(x) x(:)';
for r = 1:2
    T = cellfun(fun,{MS.(varnames{r})},'UniformOutput',false);
    [MS.(varnames{r})] = T{:};
end

% Convert to table
GT = struct2table(MS);

% Convert geo-variable names to two-element string vector
varnames = string(varnames);

% Get coordinate system type (planar or geographic)
coordinateSystemType = options.coordinateSystemType;

% Obtain and check projection
if ~isempty(options.CoordinateReferenceSystem)
    proj = parseCRS(options.CoordinateReferenceSystem);
else
    proj = [];
end

% Make some final checks
if ~islatlon
    coordinateSystemType = 'planar';
    if isa(proj,"geocrs")
        error('TopoToolbox:input',...
            'The coordinate system must be projected (see projcrs).')
    end
end

% Convert to geotable
if ~isempty(proj)
    GT = table2geotable(GT,coordinateSystemType,varnames,...
        CoordinateReferenceSystem=proj,GeometryType=GeometryType);
else
    GT = table2geotable(GT,coordinateSystemType,varnames,...
            GeometryType=GeometryType);
end

% Remove the coordinate variables
GT = removevars(GT,varnames);

end

%% ----------------------------------------------------------------
function [varnames,islatlon] = getCoordNames(fn)
% The function scans the fieldnames fn and
% returns candidate fieldnames that hold the coordinates


%% Lat-Lon or lat-lon
Ilat = strcmpi(fn,'lat');
Ilon = strcmpi(fn,'lon');

if nnz(Ilat) > 1 || nnz(Ilon) > 1
    error('Multiple coordinate candidate fieldnames found.')
end

if any(Ilat) && any(Ilon)
    varnames = {fn{Ilat}, fn{Ilon}};
    islatlon = true;
    return
end

%% Latitude-Longitude or latitude-longitude
Ilat = strcmpi(fn,'latitude');
Ilon = strcmpi(fn,'longitude');

if nnz(Ilat) > 1 || nnz(Ilon) > 1
    error('Multiple coordinate candidate fieldnames found.')
end

if any(Ilat) && any(Ilon)
    varnames = {fn{Ilat}, fn{Ilon}};
    islatlon = true;
    return
end

%% X-Y or x-y
Ix = strcmpi(fn,'x');
Iy = strcmpi(fn,'y');

if nnz(Ix) > 1 || nnz(Iy) > 1
    error('Multiple coordinate candidate fieldnames found.')
end

if any(Ix) && any(Iy)
    varnames = {fn{Ix}, fn{Iy}};
    islatlon = false;
    return
end
end