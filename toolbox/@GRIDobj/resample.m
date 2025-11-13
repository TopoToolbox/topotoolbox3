function DEMr = resample(DEM,target,method,options)

%RESAMPLE Change spatial resolution of a GRIDobj
%
% Syntax
%
%     DEMr = resample(DEM,cellsize)
%     DEMr = resample(DEM,GRID)
%     DEMr = resample(...,method)
%
% Description
%
%     resample changes the cellsize of a grid. The function uses the
%     functions mapresize or georesize, if a target cellsize is supplied.
%     If an instance of GRIDobj is supplied as second argument, resample
%     interpolates values in DEM to match the spatial reference of GRID
%     using the function imtransform. Note that resampling might create
%     nans along the borders of the resulting raster. 
%
% Input arguments
%
%     DEM       grid object (GRIDobj)
%     cellsize  cellsize of resampled grid
%     GRID      other grid object
%     method    'cubic', 'bilinear', or 'nearest' (default is 'bilinear')
%
% Output arguments
%
%     DEMr    grid object (GRIDobj)
%
% Example
%
%     DEM = GRIDobj('srtm_bigtujunga30m_utm11.tif');
%     DEMr = resample(DEM,1000);
%     subplot(1,2,1)
%     imageschs(DEM,'colorbar',false)
%     subplot(1,2,2)
%     imageschs(DEMr,'colorbar',false)
%
% See also: griddedInterpolant, imtransform
%        
% Author:  Wolfgang Schwanghart (schwangh[at]uni-potsdam.de)
% Date: 18. February, 2025 

% check also mapresize, georesize

arguments
    DEM   GRIDobj
    target  {mustBeGRIDobjOrPositiveScalar}
    method = "bilinear"
    options.crop     = false
end

method = validatestring(method,{'cubic', 'bilinear', 'nearest' },...
    'GRIDobj/resample','method',3);


% Fillvalues and methods
if isUnderlyingType(DEM,'logical') || isUnderlyingInteger(DEM)
    fillval = 0;
    method = 'nearest';
else
    fillval = nan;
end

% resample if resolution is supplied. This is easy with the 
% new functions mapresize and georesize
if ~isa(target,'GRIDobj')
    % With the new 
    if isProjected(DEM)
        scale = DEM.cellsize / target;
        [B,RB] = mapresize(DEM.Z,DEM.georef,scale,method);
        DEMr = GRIDobj(B,RB);
    elseif isGeographic(DEM)
        scale = DEM.cellsize / target;
        [B,RB] = georesize(DEM.Z,DEM.georef,scale,method);
        DEMr = GRIDobj(B,RB);
    else

        if ~isempty(DEM.georef)
            % DEM has a mapcellreference-object, but no projection
            scale = DEM.cellsize / target;
            [B,RB] = mapresize(DEM.Z,DEM.georef,scale,method);
            DEMr = GRIDobj(B,RB);

        elseif isempty(DEM.georef)
            % no mapping toolbox seems to be available and georef property 
            % is empty. We'll use image processing tools (tform, imref2d, 
            % and imwarp.
            tform = affinetform2d([1 0 0; 0 1 0; 0 0 1]);
            [im,RA] = GRIDobj2im(DEM);
            xout = RA.XWorldLimits(1):target:RA.XWorldLimits(2);
            yout = RA.YWorldLimits(1):target:RA.YWorldLimits(2);
            RB = imref2d([numel(yout) numel(xout)],xout([1 end]),yout([1 end]));
            
            
            im = imwarp(im,RA,tform,method,...
                "FillValues",nan,...
                "OutputView",RB);
            DEMr = GRIDobj(xout,yout,im);

        end
    end
    
else
    T = maketform('affine',[1 0 0; 0 1 0; 0 0 1]);
    switch method
        case 'cubic'
            method = 'bicubic';
    end

    if ~isEqualGeoreference(DEM,target)
        error("TopoToolbox:wronginput","Both GRIDobjs must have the same projection.")
    end

    if isProjected(DEM) 
        R    = DEM.georef;
        Rnew = target.georef;

        DEMr = target;
        DEMr.Z = flipud(imtransform(flipud(DEM.Z),T,method,...
        'Udata',R.XWorldLimits,'Vdata',R.YWorldLimits,...
        'Xdata',Rnew.XWorldLimits,'Ydata',Rnew.YWorldLimits,...
        'Size',Rnew.RasterSize,...
        'FillValues',fillval));
    elseif isGeographic(DEM)
        R    = DEM.georef;
        Rnew = target.georef;

        DEMr = target;
        DEMr.Z = flipud(imtransform(flipud(DEM.Z),T,method,...
        'Udata',R.LongitudeLimits,'Vdata',R.LatitudeLimits,...
        'Xdata',Rnew.LongitudeLimits,'Ydata',Rnew.LatitudeLimits,...
        'Size',Rnew.RasterSize,...
        'FillValues',fillval));
        
    else
        error("Function requires mapping toolbox")
    end

end
DEMr.name = 'resampled';
if options.crop
    DEMr = crop(DEMr);
end

end
% %% ----------------------------------------------------------------------
function mustBeGRIDobjOrPositiveScalar(x)

tf = isa(x,'GRIDobj') || (isscalar(x) && x > 0);
if ~tf 
    error("TopoToolbox:validation","Input must be GRIDobj or a positive scalar.")
end
end


