function [FD,S] = multi2single(FD,options)
%MULTI2SINGLE Converts multiple to single flow direction
%
% Syntax
%
%     FD = multi2single(FDm)
%     FD = multi2single(FDm,pn,pv,...)
%     [FD,S] = multi2single(FDm,pn,pv,...)
%
% Description
%
%     multi2single converts a multiple flow direction FLOWobj FDm into a 
%     single flow direction FLOWobj. Additional arguments enable to convert
%     only the channelized part defined by a minimum upstream area from
%     multi to single. 
%
% Input arguments
%
%     FDm   multiple flow directions
%     
%     Parameter name/value pairs
%
%     'minarea'      minimum upstream area required to initiate streams. The
%                    default is 0. Higher values will result in flow
%                    networks that have multiple flow directions up to the
%                    defined upstream area, and single flow directions
%                    downstream.
%     'unit'         unit of value determined with the parameter 'minarea':
%                    'pixels' (default) or 'mapunits'.
%     'channelheads' linear index into DEM with channelheads. 
%     'W'            GRIDobj with weights for weighted flow accumulation
%
% Output arguments
%
%     FD    FLOWobj. If 'minarea' == 0 (default), then FD will be a FLOWobj  
%           with single flow directions. Otherwise, FLOWobj will be of type 
%           'multi'.
%     S     STREAMobj (only applicable if 'minarea' is set >0 or
%           channelheads are provided.)
%     
%
% Example
% 
%     DEM = GRIDobj('srtm_bigtujunga30m_utm11.tif');
%     FD  = FLOWobj(DEM,'preprocess','carve','mex',true);
%     DEM = imposemin(FD,DEM,0.0001);
%     FD  = FLOWobj(DEM,'multi');
%     [FD,S]  = multi2single(FD,'minarea',1000);
%     A   = flowacc(FD);
%     imageschs(DEM,log(A),'colormap',flowcolor)
%     hold on
%     plot(S,'k')
%     hold off
%
% See also: FLOWobj, FLOWobj/ismulti
%
% Author: Wolfgang Schwanghart (schwangh[at]uni-potsdam.de)
% Date: 25. September, 2024

arguments
    FD
    options.minarea (1,1) {mustBeNumeric,mustBeNonnegative} = 0
    options.unit {mustBeMember(options.unit,{'pixels','mapunits'})} = 'pixels'
    options.channelheads = []
    options.probability (1,1) = false
    options.randomize (1,1) = false
    options.W = GRIDobj(FD)+1
end

% If FLOWobj has single type, then there's no need to continue
switch FD.type
    case 'single'
        return
end

%% Minimum upstream area is 0.
if options.minarea == 0
    % Find links between givers and receivers that pass the maximum fraction
    I = findmaxlink(FD,'randomize',options.randomize,'W',options.W);

    if isempty(options.channelheads)
        FD.ix = FD.ix(I);
        FD.ixc = FD.ixc(I);
        FD.fraction = [];
        FD.type = 'single';

        S = [];
        return
    else
        FDs = FD;
        FDs.ix = FDs.ix(I);
        FDs.ixc = FDs.ixc(I);
        FDs.fraction = [];
        FDs.type = 'single';

        C  = influencemap(FDs,options.channelheads);

        I2 = ~C.Z(FD.ix);
        I  = I2 | I;

        FD.ix = FD.ix(I);
        FD.ixc = FD.ixc(I);
        FD.fraction = FD.fraction(I);

        FD = multi_normalize(FD);

        S = STREAMobj(FDs,C);
        return
    end

%% 
else
    % Minimum upstream area is positive. This is a bit more complicated
    if options.randomize
        FD = randomize(FD);
    end

    I = findmaxlink(FD,'randomize',false,'W',options.W);

    % Create a GRIDobj that contains upslope area. This will be computed on
    % the fly
    A = options.W.Z;

    switch options.unit
        case 'mapunits'
            minarea = options.minarea / (FD.cellsize^2);
            % A = A/(FD.cellsize^2);
        otherwise
            minarea = options.minarea;
    end

    % Make copies of the arrays in FD
    ix  = FD.ix;
    ixc = FD.ixc;
    fr  = FD.fraction;

    isChannel = false(FD.size);

    for r = 1:numel(ix)

        % Is the giver node a stream pixel
        if A(ix(r)) >= minarea
            if I(r) % neighbor is maximum downstream neighbor
                A(ixc(r)) = A(ixc(r)) + A(ix(r));
                isChannel(ix(r)) = true;
                isChannel(ixc(r)) = true;
            end
        else
            % Giver node is not a stream pixel, so water is distributed and
            % accumulated to all downstream neighbors.
            A(ixc(r)) = A(ixc(r)) + fr(r).*A(ix(r));
            I(r) = true;
        end
    end

    FD.ix  = ix(I);
    FD.ixc = ixc(I);
    FD.fraction = fr(I);

    FD = multi_normalize(FD);
    
    % STREAMobj is required
    if nargout == 2
        FDs = FD;
        II  = isChannel(FD.ix) & isChannel(FD.ixc);
        FDs.ix = FDs.ix(II);
        FDs.ixc = FDs.ixc(II);
        FDs.fraction = [];
        FDs.type = 'single';
        S   = STREAMobj(FDs,'minarea',0);
    end

end
    
    




end


%% Subfunctions

function I = findmaxlink(FD,options)

arguments 
    FD
    options.randomize (1,1) = false
    options.W = GRIDobj(FD,'single')+1;
end

if options.randomize
    FD = randomize(FD);
end
ix  = FD.ix;
fr  = FD.fraction;

% Flow accumulation from multiple flow directions is required to provide 
% more realistic flow directions in flat areas
am   = flowacc(FD,options.W);
am   = am.Z(FD.ixc);

maxval = zeros(FD.size);
maxvalloc = zeros(FD.size);

I = false(size(ix));

for r = 1:numel(ix)
   
    valcurrent = fr(r)*am(r);

    if valcurrent > maxval(ix(r))         
        maxval(ix(r)) = valcurrent;
        maxvalloc(ix(r)) = r;
    end
end

I(maxvalloc(maxvalloc>0)) = true;
end
