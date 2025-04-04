function varargout = getoutline(SW,outformat)
%GETOUTLINE Get outline of swath
%
% Syntax
%
%     out   = getoutline(SW,outformat)
%     [x,y] = getoutline(SW,'xy')
%     [lat,lon] = getoutline(SW,'latlon')
%
% Description
%
%     getoutline returns the outline of a SWATHobj.  
%
% Input arguments
%
%     SW   SWATHobj
%    
%     Parameter name/value pairs
%
%     'output'     'xy','mappolyshape','maplineshape','geopolyshape',
%                  'maplineshape','latlon'
%
% Output arguments
%
%     OUT      Any of the output defined above.
%     x,y      nan-punctuated coordinate vectors
%     lat,lon  nan-punctuated coordinate vectors (latitude, longitude)
%
% Example
%
%     DEM = GRIDobj('srtm_bigtujunga30m_utm11.tif');
%     FD = FLOWobj(DEM,'single');
%     S = STREAMobj(FD,'minarea',1000);
%     S = klargestconncomps(S);
%     S = trunk(S);
%     SW = STREAMobj2SWATHobj(S,DEM,'smooth',true);
%     geoplot(getoutline(SW))
%     hold on
%     geoplot(gettrace(SW))
%     hold off
%
% See also: STREAMobj/gettrace
%
% Author: Wolfgang Schwanghart (schwangh[at]uni-potsdam.de)
% Date: 12. September, 2024

arguments
    SW  SWATHobj
    outformat = 'mappolyshape'
end

if nargout == 1
    validoutformats = {'xy','mappolyshape','maplineshape','geopolyshape', ...
                  'geolineshape','latlon'};
else
    validoutformats = {'xy','latlon'};
end
    

outformat = validatestring(outformat,validoutformats,2);

IM = ~isnan(SW.Z);
B = bwboundaries(IM,4);
CX = cell(length(B),1);
CY = cell(length(B),1);

for k = 1 : length(B)
    ix = sub2ind(size(IM),B{k}(:,1),B{k}(:,2));
    CX{k} = SW.X(ix);
    CY{k} = SW.Y(ix);
end

switch outformat
    case {'geopolyshape','geolineshape','latlon'}
        CRS = parseCRS(SW);
        [CY,CX] = cellfun(@(x,y)projinv(CRS,x,y),CX,CY,'UniformOutput',false);
end

switch outformat
    case {'mappolyshape','maplineshape'}
        outfun = str2func(outformat);
        CX  = cellfun(@(x) x(:)',CX,'UniformOutput',false);
        CY  = cellfun(@(x) x(:)',CY,'UniformOutput',false);
        OUT = outfun(CX,CY);
        OUT.ProjectedCRS = SW.georef.ProjectedCRS;
    case {'geopolyshape','geolineshape'}
        outfun = str2func(outformat);

        CX  = cellfun(@(x) x(:)',CX,'UniformOutput',false);
        CY  = cellfun(@(x) x(:)',CY,'UniformOutput',false);

        OUT = outfun(CY,CX);
        OUT.GeographicCRS = parseCRS(4326);
    case 'xy'
        CX = cellfun(@(x) [x;nan],CX,'UniformOutput',false);
        CY = cellfun(@(x) [x;nan],CY,'UniformOutput',false);
        OUT = [vertcat(CX{:}), vertcat(CY{:})];
    case 'latlon'
        CX = cellfun(@(x) [x;nan],CX,'UniformOutput',false);
        CY = cellfun(@(x) [x;nan],CY,'UniformOutput',false);
        OUT = [vertcat(CY{:}), vertcat(CX{:})];
end

if nargout == 1
    varargout{1} = OUT;
else
    varargout{1} = OUT(:,1);
    varargout{2} = OUT(:,2);
end

