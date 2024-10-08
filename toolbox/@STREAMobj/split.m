function S = split(S,V,removeedge,doclean)

%SPLIT Split drainage network at predefined locations
%
% Syntax
%
%     Ss = split(S)
%     Ss = split(S,ix)
%     Ss = split(S,C)
%     Ss = split(S,...,removeedge)
%     Ss = split(S,...,clean)
%
% Description
%
%     SPLIT disconnects the channel network at predefined locations. With
%     only the STREAMobj as input argument, the stream network will be
%     split at all confluences. Otherwise, the network will be split at ix 
%     which is a vector of linear indices into the DEM from which S was 
%     derived. The function does not delete nodes in the network but edges
%     between nodes. Whether these are the incoming or outgoing edges of ix
%     can be controlled with setting removeedge to 'incoming' or
%     'outgoing'.
%
% Input arguments
%
%     S     STREAMobj
%     ix    linear index into DEM. The indexed pixels must be located on 
%           the channel network, e.g. ismember(ix,S.IXgrid).
%     C     GRIDobj. The GRIDobj should be a label grid. The stream network
%           is split where it traverses different regions. 
%     removeedge {'incoming'} or 'outgoing'. 'incoming' removes the edge or
%           edges between ix and its upstream neighbor(s). 'outgoing'
%           removes the downstream edge.
%     clean {true} or false. If true, split will call the function
%           STREAMobj/clean to remove nodes in the stream network that do
%           not have an incoming or outgoing edge.
% 
% Output arguments
%
%     Ss    STREAMobj
%
% Example 1: Split at confluences
%     
%     DEM = GRIDobj('srtm_bigtujunga30m_utm11.tif');
%     FD  = FLOWobj(DEM,'preprocess','carve');
%     S = STREAMobj(FD,'minarea',1e6,'unit','map');
%     S2 = split(S);
%     plot(S)
%     hold on
%     plot(S2,'k')
%     % zoom in to see that the stream network has been split
%
% Example 2: Split at random locations
%
%     S2 = split(S,randlocs(S,100));
%     plotc(S2,S2.distance)
%
% Example 3: Split at changes along a classified grid
%
%     C = reclassify(DEM,'equalint',5);
%     DEM = imposemin(S,DEM);
%     S2 = split(S,C,'outgoing',true);
%     [x,y] = streampoi(S2,'outlets','xy');
%     imageschs(DEM,C)
%     hold on
%     plot(x,y,'wo')
%     hold off
%
% See also: STREAMobj, STREAMobj/modify, STREAMobj/randlocs, 
%           STREAMobj/STREAMobj2cell, STREAMobj/clean
%
% Author: Wolfgang Schwanghart (schwangh[at]uni-potsdam.de)
% Date: 17. June, 2024

arguments
    S     STREAMobj
    V    = streampoi(S,'confluences','logical')
    removeedge = 'incoming'
    doclean  (1,1) = true
end

if nargin >= 2
    if isa(V,'GRIDobj') || isnal(S,V)
        d = gradient(S,V);
        V = d~=0;
    else
        V = ismember(S.IXgrid,V);
    end
end


method = validatestring(removeedge,{'outgoing','incoming'},'STREAMobj/split','removeedge',3);

switch method
    case 'outgoing'
        I = V(S.ix);
    case 'incoming'
        I = V(S.ixc);
end

S.ix(I) = [];
S.ixc(I) = [];

if doclean
    S = clean(S);
end
