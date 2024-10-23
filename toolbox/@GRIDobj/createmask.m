function [MASK,pos] = createmask(DEM,options)

%CREATEMASK Create a binary mask using polygon mapping
%
% Syntax
%
%     MASK = createmask(DEM)
%     MASK = createmask(DEM,pn,pv,...)
%
% Description
%
%     createmask is an interactive tool to create a mask based on an
%     interactively mapped polygon.
%
% Input arguments
%
%     DEM           GRIDobj
%
%     Parameter name/value pairs
%
%     'hillshade'  use hillshade as background image ({false} or true)
%     'rect'       mask is an axis-aligned rectangle
%
% Output arguments
%
%     MASK   GRIDobj with logical mask
% 
% Example
%
%     DEM = GRIDobj('srtm_bigtujunga30m_utm11.tif');
%     BW = createmask(DEM);
%     DEM = clip(DEM,~BW);
%     DEM =  inpaintnans(DEM);
%     imageschs(DEM)
%    
% See also: imroi, GRIDobj
%
% Author: Wolfgang Schwanghart (schwangh[at]uni-potsdam.de)
% Date: 6. June, 2024

arguments
    DEM  GRIDobj
    options.hillshade = false
    options.rect      = false
end

figure
if options.hillshade
    imageschs(DEM);
else
    imagesc(DEM);
end

if ~options.rect
    title('Draw polygon');
else
    title('Draw rectangle');
end

ext = getextent(DEM);
cs4 = DEM.cellsize/4;
ext = ext + cs4*[1 -1 1 -1];

if ~options.rect
    h = drawpolygon('DrawingArea',...
        [ext(1) ext(3) ext(2)-ext(1) ext(4)-ext(3)]);
else
    h = drawrectangle('DrawingArea',...
        [ext(1) ext(3) ext(2)-ext(1) ext(4)-ext(3)]);
end
customWait(h);

MASK = DEM;
MASK.name = 'mask';
MASK.Z = createMask(h);

pos = h.Position;

delete(h);
hold on
plot(pos([1:end 1],1),pos([1:end 1],2));
hold off
title('Done');


end


function pos = customWait(hROI)

% Listen for mouse clicks on the ROI
l = addlistener(hROI,'ROIClicked',@clickCallback);

% Block program execution
uiwait;

% Remove listener
delete(l);

% Return the current position
pos = hROI.Position;

end

function clickCallback(~,evt)

if strcmp(evt.SelectionType,'double')
    uiresume;
end

end
