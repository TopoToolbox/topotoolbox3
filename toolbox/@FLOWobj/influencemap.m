function OUT = influencemap(FD,seed1, seed2, options)

%INFLUENCEMAP Downslope area for specific locations in a digital elevation model
%
% Syntax
%
%     I = influencemap(FD,L)
%     I = influencemap(FD,ix)
%     I = influencemap(FD,x,y)
%
% Description
%
%     influencemap returns a GRIDobj with true values for those pixels that
%     are downstream of the locations in L, ix, or x and y.
%
% Input
%
%     FD        flow direction object (FlowDirObj)
%     L         logical grid (GRIDobj)
%     ix        linear index into a grid
%     x,y       coordinate pairs
%
% Output
%
%     I         logical influence grid (GRIDobj)
%
% Example
%
%     DEM = GRIDobj('srtm_bigtujunga30m_utm11.tif');
%     FD = FLOWobj(DEM);
%     I  = influencemap(FD,540261);
%     imageschs(DEM,dilate(I,ones(5)));
%
%
% See also: FLOWobj, FLOWobj/DEPENDENCEMAP
%
% Author: Wolfgang Schwanghart (schwangh[at]uni-potsdam.de)
% Date: 31. August, 2024

arguments
    FD  FLOWobj
    seed1
    seed2 = []
    options.uselibtt (1,1) logical = false
end

%% check input arguments
if isempty(seed2)
    % SEED pixels are either supplied as logical matrix, GRIDobj, or linear
    % index
    SEED = seed1;
    isGRIDobj = isa(SEED,'GRIDobj');   
    if (islogical(SEED) || isGRIDobj)
        validatealignment(FD,SEED);
        if isGRIDobj
            SEED = SEED.Z;
        end
    else
        % SEED is supposed to be supplied as linear index in the GRIDobj
        ix   = seed1;
        SEED = false(FD.size);
        SEED(ix) = true;
    end
else
    % SEED pixels are supplied as coordinate pairs
    ix   = coord2ind(FD,seed1,seed2);
    SEED = false(FD.size);
    SEED(ix) = true;
end

%% Do calculation
if options.uselibtt && haslibtopotoolbox
    W = 0xff * ones(numel(FD.ix), 1, 'uint8');
    SEED = tt_traverse_down_u8_or_and(uint8(SEED), W, ...
        int64(FD.ix - 1), int64(FD.ixc - 1));
    SEED = SEED == 1;
else
ixtemp  = FD.ix;
ixctemp = FD.ixc;
for r = 1:numel(FD.ix)
    SEED(ixctemp(r)) = SEED(ixtemp(r)) || SEED(ixctemp(r));
end
end

%% Prepare Output
% empty GRIDobj
OUT = GRIDobj(FD,SEED);
OUT.zunit = 'logical';
OUT.name  = 'influence map';
