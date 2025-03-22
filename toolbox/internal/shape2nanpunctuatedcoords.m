function [x,y,ix] = shape2nanpunctuatedcoords(inp,options)

%SHAPE2NANPUNCTUATEDCOORDS Mapstruct or geotable with lines to vectors
%
% Syntax
%
%     [x,y] = shape2nanpunctuatedcoords(MS or GT)
%     [x,y] = shape2nanpunctuatedcoords(...,coords = ["X" "Y"])
%     [x,y] = shape2nanpunctuatedcoords(...,coords = ["Lon" "Lat"])
%     [x,y,ix] = ...
%
% Description
%
%     This function converts geo or map shape to nan-punctuated coordinate
%     column vectors.
%
% Input arguments
%
%     MS      Mapping structure
%     GT      geotable
%     
%     Parameter name/value pairs
%
%     'coords'   Two element vector of strings for the x and y-coordinate
%                field in MS.
%
% Output arguments
%
%     x,y      nan-punctuated coordinate vectors
%     ix       linear index for each coordinate pair to reference back into
%              MS or GT. 
%
%
% See also: mapstruct2geotable
%
% Author: Wolfgang Schwanghart (schwangh@uni-potsdam.de)
% Date: 20. March, 2025

% Argument checking
arguments 
    inp 
    options.coords {mustBeFieldorEmpty(options.coords,inp)} = []
end

% Convert to mapping structure
if isgeotable(inp)
    MS = geotable2mapstruct(inp);
else
    MS = inp;
end

% Get coordinate cell arrays from fields
if isempty(options.coords)
    xFieldCandidates = {'x' 'X' 'Lon' 'Longitude'};
    yFieldCandidates = {'y' 'Y' 'Lat' 'Latitude'};

    tf = cellfun(@(xx,yy) isfield(MS,xx) && isfield(MS,yy), ...
        xFieldCandidates, yFieldCandidates,'UniformOutput',true);

    if nnz(tf)>1
        tf = find(tf,1,"first");
        warning('TopoToolbox:input',...
            ['Multiple candidate coordinate fields found.\n' ...
            'Proceeding with fields ' xFieldCandidates{tf} ' and ' yFieldCandidates{tf} '.'])
    end

    x = {MS.(xFieldCandidates{tf})};
    y = {MS.(yFieldCandidates{tf})};
else
    x = {MS.(options.coords(1))};
    y = {MS.(options.coords(2))};
end

% Expand each line with nans
[x,y] = cellfun(@(x,y) expandwithnan(x,y),x,y,'UniformOutput',false);

% Concatenate into column vectors
x = vertcat(x{:});
y = vertcat(y{:});

if nargout == 3
    I  = isnan(x);
    ix = circshift(I,1);
    ix = cumsum(ix);
    ix(I) = nan;
end
end

%% ---- subfunctions
function [x,y] = expandwithnan(x,y)
% This function expands vectors with a nan and returns column vectors

if isnan(x(end)) && isnan(y(end))
    % do nothing
elseif ~(isnan(x(end))) && ~(isnan(y(end)))
    x(end+1) = nan(1,class(x));
    y(end+1) = nan(1,class(x));
else
    x(end) = nan(1,class(x));
    y(end) = nan(1,class(x));
end
x = x(:);
y = y(:);
end

function mustBeFieldorEmpty(inp,MS)
% This function checks the coordinate fields

if isgeotable(MS)
    return
end
if isempty(inp)
    return
end
if ~isstring(inp)
    error('Field names must be a 1x2 string array, e.g. ["X" "Y"] or ["Lon" "Lat"].')
end
if ~isequal(size(inp),[1 2])
    error('Field names must be a 1x2 string array, e.g. ["X" "Y"] or ["Lon" "Lat"].')
end
if isequal(inp(1),inp(2))
    error('Two different fields are required, e.g. ["X" "Y"] or ["Lon" "Lat"].')
end

tf = isfield(MS,inp(1)) && isfield(MS,inp(2));

if ~tf
    error('Structure array does not contain coordinate fields.')
end

end

