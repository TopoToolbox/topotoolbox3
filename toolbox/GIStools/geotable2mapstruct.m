function MS = geotable2mapstruct(GT)

%GEOTABLE2MAPSTRUCT Convert a geotable to a mapping structure
%
% Syntax
%
%     MS = geotable2mapstruct(GT)
%
% Description
%
%     geotable2mapstruct converts a geotable to a mapping structure. 
%
% Input arguments
%
%     GT    geotable
%
% See also: mapstruct2geotable, polygon2GRIDobj,
%           STREAMobj/STREAMobj2geotable, STREAMobj/STREAMobj2mapstruct
%
% Author: Wolfgang Schwanghart (schwangh@uni-potsdam.de)
% Date: 9. July, 2024

arguments
    GT {mustBeGeotable}
end

[~,isproj] = parseCRS(GT);
if ~isproj
    MS = geotable2table(GT,["Latitude" "Longitude"]);

else
    MS = geotable2table(GT,["X" "Y"]);

end

geomType = GT.Shape.Geometry;

MS = table2struct(MS);

switch geomType
    case 'point'
        [MS.Geometry] = deal('Point');
    case 'line'
        [MS.Geometry] = deal('Line');
    case 'polygon'
        [MS.Geometry] = deal('Polygon');
    otherwise
        error('Unknown geometry type.')
end



end

function mustBeGeotable(inp)
if ~isgeotable(inp)
    error("Input must be a geotable.")
end
end