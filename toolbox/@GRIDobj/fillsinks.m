function DEM = fillsinks(DEM,maxdepth,options)

%FILLSINKS Fill/remove pits, sinks or topographic depressions
%
% Syntax
%
%     DEMfs = fillsinks(DEM)
%     DEMfs = fillsinks(DEM,maxdepth)
%     DEMfs = fillsinks(DEM,sinks)
%     DEMfs = fillsinks(DEM,sinks)
%     DEMfs = fillsinks(DEM,'uselibtt',true)
%
% Description
%
%     fillsinks removes topographic depressions in a Digital Elevation 
%     Model (DEM). Use this function to enable a continuous flow towards 
%     the DEM edges. 
%
%     Sinks may, however, be closed basins or dolines and as such they are 
%     important features of DEMs. In order to account for such sinks, 
%     fillsinks allows you to specify a maximum depth of sinks, that 
%     will be filled, or to employ a logical grid (sinks) that is true
%     where sinks should remain (minima imposition). Note that for latter
%     option, there will be one regional minima for each connected
%     component in the sinks grid. 
%
%     fillsinks uses morphological image reconstruction (Image Processing
%     Toolbox function imreconstruct). By default, and if the function is
%     called with only one input argument, and if libtopotoolbox is
%     available (see haslibtopotoolbox) the function uses the fillsinks
%     function of libtopotoolbox. Set 'uselibtt', false, if you want to use
%     the MATLAB implementation. Note that libtopotoolbox sets the
%     underlying class of DEM to single precision.
%
% Input
%
%     DEM       digital elevation model (GRIDobj)
%     maxdepth  positive scalar with maximum depth of sinks that will be
%               filled
%     SINKS     logical matrix same size as dem with true elements
%               referring to sinks (GRIDobj)
%
%     Parameter name/value pairs
%
%     'uselibtt' {true} or false. If true, fillsinks uses libtopotoolbox.
%
% Output
%
%     DEMfs    digital elevation model with filled sinks (GRIDobj)
%
% Example
%
%     DEM = GRIDobj('srtm_bigtujunga30m_utm11.tif');
%     DEMf = fillsinks(DEM);
%     % display sink depth
%     DIFFDEM = DEMf-DEM;
%     DIFFDEM.Z(DIFFDEM.Z==0) = nan;
%     imageschs(DEM,DIFFDEM.Z);
%
%
% See also: IMFILL, IMRECONSTRUCT, IMIMPOSEMIN, PREPROCESSTOOL
%
% Author: Wolfgang Schwanghart (schwangh[at]uni-potsdam.de)
% Date: 27. October, 2024

arguments
    DEM   GRIDobj
    maxdepth = []
    options.uselibtt (1,1) = true
end

% If two input arguments are supplied, validate input
if nargin == 2
    if isscalar(maxdepth) && ~isa(maxdepth,'GRIDobj')
        validateattributes(maxdepth,{'numeric'},{'>',0});
        md = true;
    else
        SINKS = maxdepth;
        validatealignment(DEM,SINKS);
        if isa(SINKS,'GRIDobj')           
            SINKS = SINKS.Z;
        end
        md = false;
    end
        
end

dem = DEM.Z;

% START here
% identify nans
Inan      = isnan(dem);
% set nans to -inf
dem(Inan) = -inf;

uselibtt = options.uselibtt && haslibtopotoolbox;

if (nargin == 1 || nargin >= 3) && uselibtt

    % Use libtopotoolbox
    dem = single(dem); % requires dem to be single
    bc = ones(size(dem), 'uint8');
    bc(2:end-1, 2:end-1) = uint8(0);
    bc(Inan) = uint8(1);
    demfs = tt_fillsinks(dem, bc);

elseif  nargin == 1

    % Fall back to imreconstruct without libtopotoolbox
    marker     = -dem;
    II         = false(size(dem));
    II(2:end-1,2:end-1) = true;
    marker(II & ~Inan) = -inf;
    demfs = -imreconstruct(marker,-dem,8);
    
elseif nargin==2 && md
    
    % create mask
    % complement image
    dem  = imcomplement(dem);
    
    % create marker
    marker = dem;
    marker(2:end-1,2:end-1) = -inf;
    if any(Inan)
        I = (imdilate(Inan,ones(3)) & ~Inan);
        marker(I) = dem(I); 
    end
    
    demfs = imreconstruct(marker,dem);
    
    % difference image between filled and original DEM
    D   = dem-demfs;
    Inan = ~Inan;
    Inan = Inan(:);
    
    while any(D(Inan) > maxdepth)
        
        % find maximum difference in each connected sink area
        I = D>0;
        STATS = regionprops(I,D,'MaxIntensity','PixelIdxList');
        
        for r = 1:numel(STATS)
            if STATS(r).MaxIntensity < maxdepth
                % do nothing
            else
                [~,ix] = max(D(STATS(r).PixelIdxList));
                ix     = ix(1);
                marker(STATS(r).PixelIdxList(ix)) = dem(STATS(r).PixelIdxList(ix));
            end
        end
        demfs = imreconstruct(marker,dem);
        D   = dem-demfs;
    end
    
    % complement image again
    demfs = imcomplement(demfs);
    Inan  = reshape(~Inan,DEM.size);
else
    % minima imposition
    I = true(size(dem));
    I(2:end-1,2:end-1) = false;
    if any(Inan(:))
        I = (imdilate(Inan,ones(3)) & ~Inan) | I;
    end
    
    % Refine markers by identifying the lowest value in each sink
    STATS = regionprops(SINKS,dem,'MinIntensity','PixelIdxList');
    SINKS = false(size(SINKS));
    for r = 1:numel(STATS)
        ix = find(dem(STATS(r).PixelIdxList)==STATS(r).MinIntensity,1,'first');
        SINKS(STATS(r).PixelIdxList(ix)) = true;
    end
    
    marker        = -inf(size(dem),class(dem));
    marker(SINKS) = -dem(SINKS);
    marker(I)     = -dem(I);
    demfs         = -imreconstruct(marker,-dem);
    
end

% nans in the dem are set to nan again
if isfloat(demfs)
    demfs(Inan) = nan;
end
DEM.Z = demfs;
