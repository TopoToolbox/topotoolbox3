function OUT = flowacc(FD,W0,RR,options)

%FLOWACC flow accumulation (upslope area, contributing area)
%
% Syntax
%
%     A = flowacc(FD)
%     A = flowacc(FD,W0)
%     A = flowacc(FD,W0,RR)
%
% Description
%
%     flowacc calculates the number of upstream cells based on a flow
%     direction object (FLOWobj). To obtain upslope or contributing area in
%     metric units, multiply A by the square of the cellsize, e.g.
%     A = flowacc(FD).*(FD.cellsize^2).
%
%     The second input argument can be used to define spatially variable
%     weights into the flow accumulation e.g., to simulate spatially
%     variable precipitation patterns. By default, W0 is a grid of ones.
%
%     The third input argument is the runoff ratio. By default, the runoff
%     ratio equals one everywhere. To simulate infiltration or channel
%     transmission losses, values between 0 and 1 indicate the proportion
%     of flow transferred from a cell to its downstream neighbor. 
%
% Input arguments
%
%     FD    Flow direction object (class: FLOWobj)
%     W0    weight grid (class: GRIDobj) 
%     RR    runoff ratio grid (class: GRIDobj)
%
% Output arguments
%
%     A     flow accumulation grid (class: GRIDobj)
%
% Example
%
%     DEM = GRIDobj('srtm_bigtujunga30m_utm11.tif');
%     FD = FLOWobj(DEM);
%     A = flowacc(FD);
%     imageschs(DEM,dilate(sqrt(A),ones(5)),'colormap','flowcolor')
%     
% 
% See also: FLOWobj, GRIDobj, FLOWobj/drainagebasins
% 
% Author: Wolfgang Schwanghart (schwangh[at]uni-potsdam.de)
% Date: 31. August, 2024
  

% 4/3/2016: the function now makes copies of FD.ix and FD.ixc (see 
% https://topotoolbox.wordpress.com/2015/10/28/good-and-possibly-bad-news-about-the-latest-matlab-r2015b-release/comment-page-1/#comment-127

arguments
    FD   FLOWobj
    W0   = []
    RR   = []
    options.uselibtt (1,1) = true
end

if ~isempty(W0)
    validatealignment(FD,W0);
end

if ~isempty(RR)
    if isa(RR,'GRIDobj')
        validatealignment(FD,RR);
    end
end

if options.uselibtt && haslibtopotoolbox
    if isempty(W0)
        W = ones(FD.size);
    elseif isa(W0, "GRIDobj")
        W = double(W0.Z);
    else
        W = double(W0);
    end
    switch (lower(FD.type))
        case 'single'
            R = ones(numel(FD.ix), 1);
        case {'multi', 'dinf'}
            R = double(FD.fraction);
    end
    if isempty(RR)
    elseif isscalar(RR)
        R = R .* exp(-(1-RR).*getdistance(FD.ix,FD.ixc,FD.size,FD.cellsize));
    elseif isa(RR, "GRIDobj")
        R = R .* RR.Z(FD.ix);
    else
        R = R .* RR(FD.ix);
    end
    A = tt_traverse_down_f64_add_mul(W, R, int64(FD.ix - 1), int64(FD.ixc-1));
else
    if nargin == 1 || (nargin > 1 && isempty(W0))
        A = ones(FD.size);
    else
        if isa(W0,'GRIDobj')
            A = double(W0.Z);
        else
            A = double(W0);
        end

    end

    if nargin == 3
        if isa(RR,'GRIDobj')
            RR = RR.Z;
        end
    end

    % copies of ix and ixc to increase speed with 2015b
    ix = FD.ix;
    ixc = FD.ixc;

    switch lower(FD.type)
        case 'single'
            if nargin < 3

                for r = 1:numel(ix)
                    A(ixc(r)) = A(ix(r))+A(ixc(r));
                end
            else
                if isscalar(RR)
                    % if RR is a scalar, RR is assumed to be the
                    % coefficient of a homogenous differential equation

                    dx = getdistance(ix,ixc,FD.size,FD.cellsize);
                    RR = exp(-(1-RR).*dx);
                    clear dx

                    for r = 1:numel(ix)
                        A(ixc(r)) = A(ix(r))*RR(r)+A(ixc(r));
                    end
                else
                    for r = 1:numel(ix)
                        A(ixc(r)) = A(ix(r))*RR(ix(r)) + A(ixc(r));
                    end
                end


            end

        case {'multi','dinf'}
            fraction = FD.fraction;
            if nargin < 3
                for r = 1:numel(ix)
                    A(ixc(r)) = A(ix(r))*fraction(r) + A(ixc(r));
                end
            else
                for r = 1:numel(ix)
                    A(ixc(r)) = A(ix(r))*fraction(r)*RR(ix(r)) + A(ixc(r));
                end
            end
    end
end


%% Prepare Output
OUT = GRIDobj(FD,A);
OUT.zunit = 'nr of cells';
OUT.name  = 'flow accumulation';



end