function G = gradient8(DEM,unit,options)

%GRADIENT8 8-connected neighborhood gradient of a digital elevation model
%
% Syntax
%
%     G = gradient8(DEM)
%     G = gradient8(DEM,unit)
%     G = gradient8(DEM,unit,pn,pv,...)
%
% Description
%
%     gradient8 calculates the steepest downward gradient using the D8 
%     (deterministic eight-node) algorithm of O'Callaghan and Mark (1984).
%     Here, the slope at a pixel is determined by the steepest descent
%     among its eight neighboring pixels.
%
% Input
%
%     DEM       Digital elevation model (class: GRIDobj)
%     unit      'tan' --> tangent (default)
%               'rad' --> radian
%               'deg' --> degree
%               'sin' --> sine
%               'per' --> percent
%
%     Parameter name value/pairs (pn,pv,...)
%     
%     'useblockproc'    true or {false}: use block processing 
%                       (see function blockproc)
%     'useparallel'     true or {false}: use parallel computing toolbox
%     'blocksize'       blocksize for blockproc (default: 5000)
%     'uselibtt'        true or {false}
% 
% Output
%
%     G         Gradient (class: GRIDobj)
%                  
% Example
% 
%     DEM = GRIDobj('srtm_bigtujunga30m_utm11.tif');
%     G = gradient8(DEM,'degree');
%     subplot(2,1,1)
%     imagesc(DEM)
%     subplot(2,1,2)
%     imagesc(G)
%
% Reference
%
%     O’Callaghan, J. F. and Mark, D. M.: The extraction of drainage
%     networks from digital elevation data, Computer Vision, Graphics, and
%     Image Processing, 28, 323–344,
%     https://doi.org/10.1016/S0734-189X(84)80011-0, 1984.
%
% See also: GRIDobj, GRIDobj/CURVATURE, GRIDobj/ASPECT, GRIDobj/arcslope
% 
% Author: Wolfgang Schwanghart (schwangh[at]uni-potsdam.de)
% Date: 31. July, 2024

arguments
    DEM   GRIDobj
    unit  {mustBeMember(unit,{'tangent' 'degree' 'radian' 'percent' 'sine'})} = 'tangent'
    options.useblockproc (1,1) = false
    options.blocksize (1,1) = 5000
    options.useparallel (1,1) = false
    options.uselibtt (1,1) = false
end

if options.uselibtt && haslibtopotoolbox
    G = GRIDobj(DEM,tt_gradient8(...
        single(DEM.Z),single(DEM.cellsize),true));
else

    % create a copy of the DEM instance
    G = DEM;
    c = class(DEM.Z);
    switch c
        case 'double'
            G.Z = double.empty(0,0);
        otherwise
            G.Z = single.empty(0,0);
            c   = 'single';
    end

    % I found Large matrix support using blockproc inefficient for gradient8.
    % Matrix dimensions have thus been increased to an out-of-range value to
    % avoid calling blockproc.
    % Large matrix support. Break calculations in chunks using blockproc.

    if options.useblockproc
        blksiz = bestblk(size(DEM.Z),options.blocksize);
        c   = class(DEM.Z);

        switch c
            case {'double', 'single'}
                padval = inf;
            case 'logical'
                padval = true;
            otherwise
                padval = intmax(c);
        end
        cs  = G.cellsize;
        fun = @(x) steepestgradient(x,cs,c);
        G.Z = blockproc(DEM.Z,blksiz,fun,...
            'BorderSize',[1 1],...
            'Padmethod',padval,...
            'UseParallel',options.useparallel);
    else
        G.Z = steepestgradient(DEM.Z,G.cellsize,c);
    end
end

G.name = 'gradient';
G.zunit = unit;

switch unit
    case 'tangent'
        % do nothing
    case 'degree'
        G.Z = atand(G.Z);
    case 'radian'
        G.Z = atan(G.Z);
    case 'sine'
        G.Z = sin(atan(G.Z));
    case 'percent'
        G.Z = G.Z*100;
end
end




function G = steepestgradient(z,cellsize,c)

if isstruct(z)
    z = z.data;
end
    

% check for nans;
I = isnan(z);
flagnan = any(I(:));
if flagnan
    z(I) = inf;
end

NEIGH = false(3);
% calculate along orthogonal neighbors
NEIGH(2,:) = true;
NEIGH(:,2) = true;

switch c
    case 'double'
        G = (z-imerode(z,NEIGH))/cellsize;
    case 'single'
        G = single(z-imerode(z,NEIGH))/cellsize;
end

% calculate along diagonal neighbors
NEIGH(:,:) = false;
NEIGH([1 5 9 3 7]) = true;

switch c
    case 'double'
        G = max(G,(z-imerode(z,NEIGH))/norm([cellsize cellsize]));
    case 'single'
        G = max(G,single(z-imerode(z,NEIGH))/single(norm([cellsize cellsize])));
end

if flagnan
    G(I) = nan;
end
end

