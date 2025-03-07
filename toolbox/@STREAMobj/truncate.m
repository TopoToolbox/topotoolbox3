function S = truncate(S,n,direction)

%TRUNCATE Shrink river network by removing links at channelheads or outlets
%
% Syntax
%
%     St = truncate(S,n)
%     St = truncate(S,n,direction)
%
% Description
%
%     This function takes a stream network S (STREAMobj) and truncates it by
%     removing n pixels from either the upstream (headwaters), downstream
%     (outlet), or both. The function allows users to specify the
%     truncation direction using a parameter ('top', 'bottom', or 'both').
%     It returns a modified STREAMobj with the specified number of pixels
%     removed.
%
% Input arguments
%
%     S   STREAMobj
%     n   number of stream pixels to be removed (default = 1)
%     direction {'top'}, 'bottom', or 'both'
%
% Output arguments
%
%     St  truncated STREAMobj
%
% Example
%
%     DEM = GRIDobj('srtm_bigtujunga30m_utm11.tif');
%     FD = FLOWobj(DEM);
%     S = STREAMobj(FD,'minarea',1000);
%     S = truncate(S,1,'bottom');
%     imageschs(DEM);
%     hold on
%     plot(S,'w')   
%
% 
% See also: STREAMobj/modify
% 
% Author: Wolfgang Schwanghart (schwangh[at]uni-potsdam.de)
% Date: 7. March, 2025

arguments
    S   STREAMobj
    n   {mustBeInteger,mustBePositive} = 1
    direction {mustBeMember(direction,{'top','bottom','both'})} = 'top'
end

for r = 1:n
    if numel(S.x) < 3
        error("Stop! No stream network remaining.")
    end
    switch direction
        case 'top'
            I = streampoi(S,'channelhead','logical');
        case 'bottom'
            I = streampoi(S,'outlet','logical');
        case 'both'
            I = streampoi(S,{'channelhead','outlet'},'logical');
    end

    S  = subgraph(S,~I);
end


