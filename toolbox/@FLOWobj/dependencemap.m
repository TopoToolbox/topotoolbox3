function OUT = dependencemap(FD, seed1, seed2, options)

%DEPENDENCEMAP Delineate upslope area for specific locations in a DEM
%
% Syntax
%
%     I = dependencemap(FD,L)
%     I = dependencemap(FD,ix)
%     I = dependencemap(FD,x,y)
%
% Description
%
%     dependencemap returns a GRIDobj with true values masking the upslope
%     part of the digital elevation model that contributes to the specified
%     area in the region in L or pixels with the linear index ix or
%     coordinates x,y.
%
% Input
%
%     FD        flow direction object (FlowDirObj)
%     L         logical grid (GRIDobj)
%     ix        linear index into a grid
%     x,y       coordinate pairs
%
%     Parameter name/value pairs
%
%     'uselibtt'  {false} or true. If true, influencemap will use
%                 libtopotoolbox if available.
%
% Output
%
%     I         logical influence grid (GRIDobj)
%
% Example
%
%     DEM = GRIDobj('srtm_bigtujunga30m_utm11.tif');
%     I   = GRIDobj(DEM,'logical');
%     I.Z(300:500,300:500) = true;
%     FD = FLOWobj(DEM);
%     D  = dependencemap(FD,I);
%     imageschs(DEM,I+D)
%
% See also: FLOWobj, FLOWobj/INFLUENCEMAP
%
% Author: Wolfgang Schwanghart (schwangh[at]uni-potsdam.de)
%         Will Kearney
% Date: 26. June, 2026

arguments
    FD  FLOWobj
    seed1
    seed2 = []
    options.uselibtt (1, 1) logical = false
end

%% Identify seed pixels
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
        ix   = round(ix);
        if any(ix <= 0 | ix > prod(FD.size))
            error('TopoToolbox:WrongInput',...
            ['Linear indices must not be less or equal to zero \n' ...
             'or larger than ' double2str(prod(FD.size)) '.']);
        end
        
        SEED(ix) = true;
    end
else
    % SEED pixels are supplied as coordinate pairs
    ix   = coord2ind(FD,seed1,seed2);
    SEED = false(FD.size);
    SEED(ix) = true;
end

%% Compute dependence map
if options.uselibtt && haslibtopotoolbox
    W = 0xff * ones(numel(FD.ix), 1, 'uint8');
    SEED = tt_traverse_up_u8_or_and(uint8(SEED), W, ...
        int64(FD.ix - 1), int64(FD.ixc - 1));
    SEED = SEED == 1;
else
    ixtemp  = FD.ix;
    ixctemp = FD.ixc;
    for r = numel(ixtemp):-1:1
        SEED(ixtemp(r)) = SEED(ixtemp(r)) || SEED(ixctemp(r));
    end
end


%% Prepare Output
% write output to GRIDobj
OUT = GRIDobj(FD,SEED);
OUT.zunit = 'logical';
OUT.name  = 'dependence map';


end








