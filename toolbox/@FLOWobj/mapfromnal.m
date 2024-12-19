function [V,IX] = mapfromnal(FD,S,nal,cl)

%MAPFROMNAL Map values from node-attribute list to nearest upstream grid
%
% Syntax
%
%     V = mapfromnal(FD,S,nal)
%     [V,IX] = mapfromnal(FD,S,nal)
%
% Description
%
%     mapfromnal takes a STREAMobj S and an associated node-attribute list
%     nal and maps the values in the nal to the nearest grid values
%     measured along flowpaths based on the FLOWobj FD. S should be have
%     been derived from FD.
%
% Input arguments
%
%     FD      FLOWobj
%     S       STREAMobj
%     nal     node-attribute list
%
% Output arguments
%
%     V       GRIDobj with values derived from nal
%     IX      matrix with size V.size with linear indices into 
%             node-attributes of S. Elements in IX with no downstream
%             stream pixel are zero.
%
% Example
%
%     DEM = GRIDobj('srtm_bigtujunga30m_utm11.tif');
%     FD = FLOWobj(DEM);
%     S = STREAMobj(FD,'minarea',1000);
%     A = flowacc(FD);
%     V = mapfromnal(FD,S,A);
%     imagesc(V)
%
% See also: FLOWobj, STREAMobj, flowdistance, vertdistance2stream
% 
% Author: Wolfgang Schwanghart (schwangh[at]uni-potsdam.de)
% Date: 31. August, 2024

arguments
    FD    FLOWobj
    S     STREAMobj
    nal   {mustBeGRIDobjOrNal}
    cl = 'single'
end

% If the variable nal is a GRIDobj than extract the nal
nal = ezgetnal(S,nal);
    
% Use propagatevaluesupstream
IX = propagatevaluesupstream(FD,S.IXgrid,uint32(1:numel(S.IXgrid)),...
    'fillval',zeros(1,'uint32'),'overwrite',false);
IX = IX.Z;
V  = GRIDobj(FD,nan(FD.size,cl));
I  = IX>0;
V.Z(I) = nal(IX(I));
