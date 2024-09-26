function D = flowdivergence(FD)

%FLOWDIRVERGENCE Calculate the number of downstream neighbors
%
% Syntax
%
%     D = flowdivergence(FD)
%
% Description
%
%     flowdivergence determines the number of downstream neighbor of each
%     cell based on a multiple flow direction matrix. 
%
% Input arguments
%
%     FD   FLOWobj
%
% Output arguments
%
%     D    GRIDobj with underlying class uint8.
%
%
% See also: FLOWobj, FLOWobj/ismulti
%
% Author: Wolfgang Schwanghart (schwangh[at]uni-potsdam.de)
% Date: 25. September, 2024

arguments
    FD    FLOWobj
end

%% Histcounts is fastest
D = histcounts(FD.ix,1:(prod(FD.size)+1));

%% Accumarray is more flexible and some aggregation function such as shannon
% entropy could be applied in the future. That's why I leave this code
% below

% fun = @(x) sum(x.*log2(x));
% fun = @(x) uint8(numel(x)); 
% fillval = zeros(1,'uint8');
% D = accumarray(FD.ix,FD.fraction,[prod(FD.size) 1],fun,fillval);

%% Reshape and create GRIDobj
D = reshape(D,FD.size);
D = GRIDobj(FD,D);
