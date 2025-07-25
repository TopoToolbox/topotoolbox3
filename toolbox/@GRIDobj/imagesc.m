function h = imagesc(DEM,varargin)

%IMAGESC Scale data in GRIDobj and display as image object
%
% Syntax
%
%     h = imagesc(DEM)
%     h = imagesc(DEM,'nanstransparent',true)
%
% Description
%
%     This function overloads the built-in imagesc. In contrast to imagesc,
%     however, the function sets nans in the DEM to transparent. For
%     further information see the documentation of imagesc. 
%
% Input arguments
%
%     DEM     GRIDobj
%    
%     Parameter name/value pairs
%
%     'nanstransparent'  {true} or false: If true, nans in DEM are
%                        displayed fully transparent
%
% Output arguments
%
%     h       handle to image object
%
% Example
%
%     DEM = GRIDobj('srtm_bigtujunga30m_utm11.tif');
%     imagesc(DEM)
%
% See also: GRIDobj/imageschs
%
% Author: Wolfgang Schwanghart (schwangh[at]uni-potsdam.de)
% Date: 11. July, 2025

%% Update on 18. Feb 2022
% nans in the data are set to transparent

p = inputParser;
p.KeepUnmatched = true;
addParameter(p,'nanstransparent',true, @(x) isscalar(x));
parse(p,varargin{:})

[x,y] = wf2XY(DEM.wf,DEM.size);
ht = imagesc(x,y,DEM.Z,p.Unmatched);

axis xy
axis image

if p.Results.nanstransparent
    if isscalar(ht.AlphaData)   
        ht.AlphaData = ~isnan(DEM.Z);
    else
        ht.AlphaData = ht.AlphaData .* (~isnan(DEM.Z));
    end
end

if nargout == 1
    h = ht;
end
