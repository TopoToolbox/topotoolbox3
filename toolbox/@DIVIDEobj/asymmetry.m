function [MS,varargout] = asymmetry(FD,S,D,GRID,options)
% ASYMMETRY   directional asymmetry of divide segments
%
% Syntax
%     [MS]   = asymmetry(FD,S,D,GRID)
%     [MS,DS]= asymmetry(FD,S,D,GRID,'method','basin',       ...)
%     [MS]   = asymmetry(FD,S,D,GRID,'method','pixel_pairs', ...)
%     [MS]   = asymmetry(FD,S,D,GRID,'aggfun',@function,    ...)
%
% Description
%
%     ASYMMETRY computes for each segment in the divide network the
%     difference in asymmetry (mean/median, etc.) of the values in GRID
%     represented as a vector that is centered on the divide segment and
%     points in the direction of lower GRID value.
%     Note that the optional output 'DS' contains values for all divide
%     nodes, as well as divide-segment averaged values distributed to all
%     divide nodes. It lends itself for diplaying using the function
%     'plotc'.
%
% Input
%       
%     FD        instance of class FLOWobj
%     S         instance of class STREAMobj
%     D         instance of class DIVIDEobj
%     GRID      instance of class GRIDobj
%
% Parameter name/value pairs
%
%     'method'   {'basin'} or 'pixel_pairs'. 'basin' computes divide 
%                asymmetry on either side of the drainage divide. The
%                asymetry direction is perpendicular to the average 
%                direction of the divide segment.
%                'pixel_pairs' computes the differences of pixel pairs 
%                (p,q) top+right and bottom+left in reference to divide.
%                Direction of asymmetry is computed by vector addition of 
%                asymmetry of p,q pixel pairs and is therefore not 
%                necessarily perpendicular to the divide.
%     'aggfun'   {@mean}, @median, or other aggregation function used to
%                combine across divide differences 
% Output
%
%     MS        mapping structure with POINT entries representing 
%               divide segments
%      .Geometry  - 'Point'
%      .X         - x coordinate 
%      .Y         - y coordinate 
%      .order     - order
%      .dist      - along-divide distance 
%      .u         - x-component of asymmetry (east is positive)
%      .v         - y-component of asymmetry (north is positive)
%      .theta     - angle from north of asymmetry direction (for 'basin'
%                   method points to side of lower GRID values)
%      .rho       - magnitude of asymmetry
%      .DAI       - divide asymmetry index (only for 'basin' method)
%
% Optional output     
%     
%     S         data structure with LINE entries representing divide
%               segments
%      .IX        - linear indices of divide segment nodes
%      .x         - x coordinate of divide nodes
%      .y         - y coordinate of divide nodes
%      .order     - order
%      .dist      - along-divide distance 
%      .u         - x-component of divide node asymmetry (east is positive)
%      .v         - y-component of divide node asymmetry (north is positive)
%      .theta     - angle from north of divide segment(!) asymmetry 
%      .rho       - magnitude of divide segment(!) asymmetry 
%      .DAI       - divide asymmetry index (only for 'basin' method)
%
% Example
%     
% DEM = GRIDobj('srtm_bigtujunga30m_utm11.tif');
% FD  = FLOWobj(DEM,'preprocess','carve');
% S = STREAMobj(FD,flowacc(FD)>1000);
% slope = gradient8(DEM);
% upslope = upslopestats(FD,slope);
% stream_slope = upslope.Z(S.IXgrid);
% upslope_hillslope = mapfromnal(FD,S,stream_slope);
% D = DIVIDEobj(FD,S);
% D = divorder(D,'topo');
% [MS,DS] = asymmetry2(FD,S,D,upslope_hillslope,method = "basin",aggfun = @median);
% 
% tiledlayout(1,2)
% set(gcf,'Units','normalized','OuterPosition',[0 0 1 1])
% nexttile
% imageschs(DEM,upslope_hillslope,'colorbar',false);   % plot average upstream hillslope gradient of stream pixels
% hold on
% plotc(D,vertcat(DS.DAI),'caxis', [0,0.3], 'limit',[1000 inf])  % plot DAI
% colormap(gca,flipud(pink))
% axis image
% hc = colorbar;
% hc.Label.String = 'Divide asymmetry index';
% hold on
% ix = [MS.dist]>1000; 
% u = [MS(ix).DAI] .* sind([MS(ix).theta]);   % east-component (x-axis)
% v = [MS(ix).DAI] .* cosd([MS(ix).theta]);   % north-component (y-axis)
% quiver([MS(ix).X],[MS(ix).Y],u, v,2,'color','r','linewidth',1)
% title('Drainage divide asymmetry and direction of lower hillslope gradient (basin method)')
%
% See also: DIVIDEobj, DIVIDEobj/sort
%
% Author: Dirk Scherler (scherler[at]gfz-potsdam.de)
% Date: Nov 2018
% modified by R.F. Ott, 2025

arguments
    FD  FLOWobj
    S   STREAMobj
    D   DIVIDEobj
    GRID     GRIDobj
    options.method (1,1) string {mustBeMember(options.method,["basin","pixel_pairs"])} = "basin"
    options.aggfun (1,1) function_handle                                = @mean
end

% Preprocess DZ grid
GRID.Z(GRID.Z<0) = 0;
GRID.Z(isinf(GRID.Z)) = nan;

% Get vectors 
[x,y] = ind2coord(D,vertcat(D.IX));

% get divide pixels
x1 = [NaN; x(1:end-1)];
x2 = [NaN; x(2:end)];
y1 = [NaN; y(1:end-1)];
y2 = [NaN; y(2:end)];
dx = x1-x2;
dy = y1-y2;
hcs = GRID.cellsize/2;
ix = dx==0; % vertical link
iy = dy==0; % horizontal link
meanx = (x1+x2)./2;
meany = (y1+y2)./2;
px = meanx + hcs.*ix;
qx = meanx - hcs.*ix; 
py = meany + hcs.*iy;
qy = meany - hcs.*iy;
pix = coord2ind(GRID,px,py); % top and right
qix = coord2ind(GRID,qx,qy); % bottom and left
nx = ~isnan(pix) & ~isnan(qix);

switch options.method
    case 'basin'

        % make grid labelling all basins (without nesting)
        label = labelreach(S,'shuffle',true);
        LabelGRID = mapfromnal(FD,S,label);

        pvalidinds = ~isnan(pix); 
        pval       = nan(size(pix));
        pval(pvalidinds) = GRID.Z(pix(pvalidinds));          % get GRID values for pix
        labelled_pix = nan(size(pix));
        labelled_pix(pvalidinds) = LabelGRID.Z(pix(pvalidinds));  % get basin ID for all pix
    
        qvalidinds = ~isnan(qix); 
        qval       = nan(size(qix));
        qval(qvalidinds) = GRID.Z(qix(qvalidinds));          % get GRID values for qix
        labelled_qix = nan(size(qix));
        labelled_qix(qvalidinds) = LabelGRID.Z(qix(qvalidinds));  % get basin ID for all qix
    
        Labels = onl2struct(D.IX,'pix', pix, 'pval', pval, 'pixlabel',labelled_pix, 'qix',...
            qix, 'qval', qval, 'qixlabel',labelled_qix);

        DS = onl2struct(D.IX,'x',x,'y',y,'order',D.order,'dist',D.distance);

    case 'pixel_pairs'
        
        % direction of asymmetry (orthogonal to the orientation)
        u = ix;
        v = iy;
        
        % magnitude of asymmetry
        hr1 = nan(size(pix));
        hr2 = hr1;
        hr1(nx) = GRID.Z(pix(nx)); % top and right
        hr2(nx) = GRID.Z(qix(nx)); % bottom and left
        dhr = diff([hr1,hr2],1,2); % top minus bottom, right minus left
        dhrn = dhr./sum([hr1,hr2],2); % 
        u = u.*dhrn;
        v = v.*dhrn;
        
        DS = onl2struct(D.IX,'x',x,'y',y,'order',D.order,'dist',D.distance ...
            , 'u',u,'v',v);
end

n = numel(DS);

MS = struct('Geometry','point',...
    'X',cell(n,1),...
    'Y',cell(n,1));


for i = 1 : length(MS)
    
    tx = DS(i).x(1:end-1);
    ty = DS(i).y(1:end-1);
    td = getdistance(tx,ty);
    if numel(td)>1
        MS(i).X = interp1(td,tx,max(td)/2);
        MS(i).Y = interp1(td,ty,max(td)/2);
    else
        MS(i).X = tx;
        MS(i).Y = ty;
    end
    MS(i).order = mean(DS(i).order , 'omitnan');
    MS(i).dist = mean(DS(i).dist, 'omitnan');

    switch options.method
        case 'basin'
            
            basin_inds = unique([Labels(i).pixlabel; Labels(i).qixlabel]);   % find indices of basins that border this divide
            basin_inds = basin_inds(~isnan(basin_inds)); % remove nans
            rho = nan;
            DAI = nan;
            if length(basin_inds)>2
                warning('A divide segment had more than two bordering basins and will be skipped. No reason to worry.')
                theta = nan;
            elseif length(basin_inds) <2
                warning('A divide segment has less than 2 two bordering basins. No worries, this happens with small divides or the ones at the DEM border.')
                theta = nan;
            else
                coords       = [Labels(i).pix, Labels(i).qix];
                values       = [Labels(i).pval; Labels(i).qval];
                basin_labels = [Labels(i).pixlabel; Labels(i).qixlabel];
                
                % values of either side of divide
                values_side1 = values(basin_labels == basin_inds(1)); % find values on one side
                values_side2 = values(basin_labels == basin_inds(2)); % fine values on other side
                
                % apply desired function
                values_side1 = options.aggfun(values_side1, 'omitnan');
                values_side2 = options.aggfun(values_side2, 'omitnan');
                rho = abs(values_side1 - values_side2);
                
                % compute divide asymmetry index DAI 
                DAI = abs(values_side1 - values_side2)/(values_side1 + values_side2);

                % compute direction of asymmetry
                coords_side1 = coords(basin_labels == basin_inds(1));
                coords_side2 = coords(basin_labels == basin_inds(2));

                [side1_x,side1_y] = ind2coord(GRID,coords_side1);  % get coords of side 1
                [side2_x,side2_y] = ind2coord(GRID,coords_side2); % get coords of side 2
                side1_xm = mean(side1_x, 'omitnan'); % mean x coord of side 1
                side1_ym = mean(side1_y, 'omitnan');
                side2_xm = mean(side2_x, 'omitnan');
                side2_ym = mean(side2_y, 'omitnan');
                x_conn = side1_xm - side2_xm; % x coordinate of connection vector for average x,y of both sides
                y_conn = side1_ym - side2_ym;
        
                % calculate azmiuth of vector between average x,y of both divide sides
                [theta,~] = cart2pol(x_conn, y_conn); 
                theta = rad2deg(theta);
                theta = -theta+90; 
                theta(theta<0) = theta(theta<0)+360;

                % turn around direction vector to make sure it points
                % towards divide side with lower values 
                if (values_side1 - values_side2) > 0
                    if theta > 180 % turn vector around if side 1 was larger
                        theta = theta - 180;
                    else
                        theta = theta + 180;
                    end
                end

            end
            MS(i).DAI = DAI; % divide asymmetry index
            DS(i).DAI  = [ones(size(tx)).*MS(i).DAI;nan];

        case 'pixel_pairs'

            MS(i).u = double( options.aggfun( DS(i).u , 'omitnan') );
            MS(i).v = double( options.aggfun( DS(i).v ,'omitnan') );

    
            [theta,rho] = cart2pol(MS(i).u,MS(i).v);
            theta = rad2deg(theta);
            theta = -theta+90;
            theta(theta<0) = theta(theta<0)+360;

            
            DS(i).east = [ones(size(tx)).*double(MS(i).u);nan];
            DS(i).north = [ones(size(tx)).*double(MS(i).v);nan];
    end

    MS(i).theta = double(theta);
    DS(i).theta = [ones(size(tx)).*double(theta);nan];
    MS(i).rho = double(rho);
    DS(i).rho = [ones(size(tx)).*double(rho);nan];

end

if nargout>1
    varargout{1} = DS;
end

