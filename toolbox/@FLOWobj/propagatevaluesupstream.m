function V = propagatevaluesupstream(FD,IX,v,options)

%PROPAGATEVALUESUPSTREAM Propagates values upstream in a FLOWobj
%
% Syntax
%
%     V = propagatevaluesupstream(FD,IX,v)
%
% Description
%
%     The function takes the directed graph of a FLOWobj and a set of
%     initial values v assigned to the outlet nodes IX. The function
%     propagates these values upstream, assigning values to all parent
%     nodes upstream.
%
% Input arguments
%
%     FD   FLOWobj
%     IX   linear index into the DEM from which FD was derived
%     v    vector of values (must have the same number of elements as IX).
%
%     Parameter name/value pairs
%
%     'fillval'    by default, nan, if v is double or single, and 0 
%                  otherwise. The value is used to fill pixels that do not 
%                  have downstream located values v.
%     'overwrite'  false. If true, then upstream values will be overwritten
% 
% Output arguments
%
%     V    GRIDobj
%
%
% See also: FLOWobj, FLOWobj/mapfromnal
%
% Author: Wolfgang Schwanghart (schwangh[at]uni-potsdam.de)
% Date: 27. October, 2024

arguments
    FD FLOWobj
    IX {mustBePositive,mustBeInteger}
    v  
    options.overwrite (1,1) = false
    options.fillval (1,1) = makedefaultfillval(v)
end

fv    = options.fillval;
V     = repmat(fv,FD.size);
V(IX) = v;

ix = FD.ix;
ixc = FD.ixc;

if ~options.overwrite

    for r = numel(ixc):-1:1
        if isequaln(V(ix(r)),fv)
            V(ix(r)) = V(ixc(r));
        end
    end
else
    for r = numel(ixc):-1:1
        if ~isequaln(V(ixc(r)),fv)
            V(ix(r)) = V(ixc(r));
        end
    end
end

V = GRIDobj(FD,V);
end

function fv = makedefaultfillval(v)

c = class(v);
switch lower(c)
    case {'double','single'}
        fv = nan(1,c);
    otherwise
        fv = zeros(1,c);
end
end

