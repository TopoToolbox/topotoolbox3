function M = mosaic(DEM)

%MOSAIC Merge multiple GRIDobjs into a larger GRIDobj
%
% Syntax
%
%     M = mosaic(DEM1,DEM2,...)
%
% Description
%
%     This function merges multiple adjacent raster tiles stored as
%     GRIDobjs. It replicates the behavior of mergetiles (Mapping Toolbox
%     function since 2024a), but will also work for older versions and if
%     the tiles do not fill an entire rectangle and if there are
%     overlappings. However, there are only minimal error checks and the
%     function assumes that all GRIDobj have the same spatial coordinate
%     reference system, the same cellsize, and the same underlying data
%     class.
%
%     The function requires the Mapping Toolbox.
%
%     Note of caution: TopoToolbox stores GRIDobjs in the main memory and
%     mosaicking might quickly lead to very large grids that may not fit
%     into memory.
%
% Input arguments
%
%     DEM1, DEM2, ...    Several GRIDobj
%
% Output arguments
%
%     M     Merged GRIDobj
%
% Example: Read multiple .tif-files in a directory and mosaic them
%
%     files = dir('*.tif');
%     CDEM = cellfun(@(x) GRIDobj(x),{files.name},'UniformOutput',false);
%     DEM = mosaic(CDEM{:});
%     clear CDEM
%
% See also: GRIDobj/ind2coord, mergetiles
%
% Author: Wolfgang Schwanghart (schwangh[at]uni-potsdam.de)
% Date: 7. April, 2025

arguments (Repeating)
    DEM GRIDobj
end

if nargin == 1
    M = DEM;
    return
end

Z = cellfun(@(x) x.Z,DEM,'UniformOutput',false);
R = cellfun(@(x) x.georef,DEM,'UniformOutput',false);

%% The following code fails if tiles overlap or do not cover the entire 
% rectangle spanned by the data

try
    assert(~isMATLABReleaseOlderThan('R2024a'))
    inp = [Z(:)';R(:)'];
    inp = inp(:);

    [B,RB] = mergetiles(inp{:});

    M = GRIDobj(B,RB);
catch
    %% Alternatively, we can build the mosaic by ourselves

    t = class(R{1});
    R = R(:);
    switch t
        case {'map.rasterref.MapCellsReference','map.rasterref.MapPostingsReference'}

            xxyy = cellfun(@(x) [x.XWorldLimits x.YWorldLimits],R,'UniformOutput',false);
            xxyy = vertcat(xxyy{:});
            xlimits = [min(xxyy(:,1)) max(xxyy(:,2))];
            ylimits = [min(xxyy(:,3)) max(xxyy(:,4))];

            switch t
                case 'map.rasterref.MapCellsReference'
                    Rn = maprefcells(xlimits,ylimits,...
                        R{1}.CellExtentInWorldX,R{1}.CellExtentInWorldY,...
                        "ColumnsStartFrom","north");
                case 'map.rasterref.MapPostingsReference'
                    Rn = maprefpostings(xlimits,ylimits,...
                        R{1}.SampleSpacingInWorldX,R{1}.SampleSpacingInWorldY,...
                        "ColumnsStartFrom","north");
            end
            Rn.ProjectedCRS = R{1}.ProjectedCRS;

        case {'map.rasterref.GeographicCellsReference','map.rasterref.GeographicPostingsReference'}

            latlon = cellfun(@(x) [x.LatitudeLimits x.LongitudeLimits],R,'UniformOutput',false);
            latlon = vertcat(latlon{:});
            latlimits = [min(latlon(:,1)) max(latlon(:,2))];
            lonlimits = [min(latlon(:,3)) max(latlon(:,4))];

            switch t
                case 'map.rasterref.GeographicCellsReference'
                    Rn = georefcells(latlimits,lonlimits,...
                        R{1}.CellExtentInLatitude,R{1}.CellExtentInLongitude,...
                        "ColumnsStartFrom","north");
                case 'map.rasterref.GeographicPostingsReference'
                    Rn = maprefpostings(latlimits,lonlimits,...
                        R{1}.CellExtentInLatitude,R{1}.CellExtentInLongitude,...
                        "ColumnsStartFrom","north");
            end
            Rn.GeographicCRS = R{1}.GeographicCRS;
    end

    cl = class(Z{1});
    try
        fillval = cast(nan,cl);
    catch
        fillval = false;
    end

    M = GRIDobj(repmat(fillval,Rn.RasterSize),Rn);

    for r = 1:numel(DEM)
        [x,y,z] = findcoord(DEM{r});
        ix = coord2ind(M,x,y);
        M.Z(ix) = z;
    end
end