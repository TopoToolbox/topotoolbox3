function varargout = identifyflats(DEM)

%IDENTIFYFLATS identify flat terrain in a digital elevation model
%
% Syntax
%
%     [FLATS,SILLS,CLOSED] = identifyflats(DEM)
%
% Description
%
%     identifyflats returns a logical matrix that is true for cells
%     indicating flat terrain. flat terrain cells are defined as cells that
%     do not have a downward neighboring cell. The second output argument 
%     contains a logical matrix that is true for sill cells. Sill cells are
%     pixels in the DEM where flat regions spill over into lower terrain.
%     Both output arguments are returned as instances of GRIDobj.
%
% Input
%
%     DEM        digital elevation model(GRIDobj)
%    
% Output
% 
%     FLATS      instance of GRIDobj that contains logical matrix 
%                where true cells indicate flat terrain (GRIDobj). 
%     SILLS      instance of GRIDobj that contains logical matrix 
%                where true cells indicate sill locations (GRIDobj).
%     CLOSED     instance of GRIDobj that contains the lowest 
%                locations in closed basins as logical grid.
%                
% Example
%
%     DEM = GRIDobj('srtm_bigtujunga30m_utm11.tif');
%     DEM = fillsinks(DEM);
%     [FLATS,SILLS] = identifyflats(DEM);
%     imageschs(DEM,FLATS+2*SILLS,'colormap','parula')
% 
% See also: GRIDobj, GRIDobj/fillsinks
%
% Author: Wolfgang Schwanghart (w.schwanghart[at]geo.uni-potsdam.de)
% Date: 26. April, 2018

narginchk(1,1)
dem = DEM.Z;

% identify NaNs
% libtopotoolbox's implementation does not need the NaNs removed from
% the DEM, so we remove them below after deciding whether we will use
% libtopotoolbox
log_nans = isnan(dem);
if any(log_nans(:))
    flag_nans = true;
else
    flag_nans = false;
end

if haslibtopotoolbox
    % Use libtopotoolbox's identifyflats
    % bitget(iflats,1) == 1 for flats
    % bitget(iflats,2) == 1 for sills
    % bitget(iflats,4) == 1 for pre-sills
    % 2024-10-07: closed pixels are not yet identified by
    % libtopotoolbox
    iflats = tt_identifyflats(dem);
    flats = bitget(iflats,1) == 1;
else
    % Fallback to the Image Processing Toolbox
    dem(log_nans) = -inf;

    if flag_nans
        flats = imerode(dem,ones(3)) == dem & ~log_nans;
    else
        flats = imerode(dem,ones(3)) == dem;
    end

    % remove flats at the border
    flats(1:end,[1 end]) = false;
    flats([1 end], 1:end) = false;

    if flag_nans
        % remove flat pixels bordering to nans
        flats(imdilate(log_nans,ones(3))) = false;
    end
end


% prepare output
varargout{1} = DEM;
varargout{1}.Z = flats;
varargout{1}.name = 'flats';

% identify sills
if nargout >= 2
    if haslibtopotoolbox
        Imr = bitget(iflats,2) == 1;
    else
        Imr = -inf(size(dem));
        Imr(flats) = dem(flats);
        Imr = (imdilate(Imr,ones(3)) == dem) & ~flats;

        if flag_nans
            Imr(log_nans) = false;
        end
    end

    % prepare output
    varargout{2} = DEM;
    varargout{2}.Z = Imr;
    varargout{2}.name = 'sills';
end

% identify interior basins
if nargout >= 3
    if haslibtopotoolbox
        % libtopotoolbox doesn't yet compute interior basins
        % so we need to process the NaNs if we haven't already
        dem(log_nans) = -inf;
    end
    varargout{3} = DEM;
    varargout{3}.Z = imregionalmin(dem);
    
    if flag_nans
        varargout{3}.Z = varargout{3}.Z | log_nans;
        varargout{3}.Z = imclearborder(varargout{3}.Z);
        varargout{3}.Z(log_nans) = false;
    else
        varargout{3}.Z = imclearborder(varargout{3}.Z);
    end
    varargout{3}.name = 'closed basins';
end



end

