function DZ = vertdistance2stream(FD,S,DEM)

%VERTDISTANCE2STREAM Vertical distance to streams (height above nearest drainage) 
%
% Syntax
%
%     DZ = vertdistance2stream(FD,S,DEM)
%
% Description
%
%     vertdistance2stream calculates the height of each cell in a digital
%     elevation model DEM above the nearest stream cell in S along the flow
%     paths in FD (height above nearest drainage (HAND)).
%
% Input arguments
%
%     FD    instance of FLOWobj
%     DEM   digital elevation model (class: GRIDobj)
%     S     stream network (class: STREAMobj)
%
% Output arguments
%
%     DZ    vertical distance to streams (class: GRIDobj)
%
% Example
%
%     DEM = GRIDobj('srtm_bigtujunga30m_utm11.tif');
%     FD = FLOWobj(DEM,'preprocess','c');
%     S = STREAMobj(FD,'minarea',1e6,'unit','m');
%     DZ = vertdistance2stream(FD,S,DEM);
%     imageschs(DEM,DZ)
%     hold on
%     plot(S,'k','LineWidth',2)
% 
%
% See also: FLOWobj, FLOWobj/flowdistance, FLOWobj/mapfromnal, GRIDobj, 
%           STREAMobj, FLOWobj/propagatevaluesupstream
% 
% Author: Wolfgang Schwanghart (schwangh[at]uni-potsdam.de)
% Date: 24. June, 2024


arguments
    FD   FLOWobj
    S    STREAMobj {validatealignment(S,FD)} 
    DEM  GRIDobj {validatealignment(S,DEM)}
end

DZ = DEM - propagatevaluesupstream(FD,S.IXgrid,DEM.Z(S.IXgrid),...
    "fillval",-inf(1,'like',DEM.Z),"overwrite",false);
DZ.name = 'Heigt above nearest drainage';
