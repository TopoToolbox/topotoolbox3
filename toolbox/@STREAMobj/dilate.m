function a = dilate(S,a,options)

%DILATE Dilate a logical node-attribute list along a stream network
%
% Syntax
%
%     ad = dilate(S,a)
%     ad = dilate(S,a,Name,Value)
%
% Description
%
%     Dilates a logical node-attribute list along a stream network.
%     True values are propagated to neighboring nodes for a specified
%     number of steps. Dilation can proceed upstream, downstream, or
%     in both directions.
%
%     The dilation length specifies the maximum number of edges
%     traversed along the network, not a physical distance.
%
% Input arguments
%
%     S       STREAMobj
%     a       Logical node-attribute list or GRIDobj
%
%     Parameter Name-Value arguments
%
%     length      Number of edges to dilate (topological distance, 
%                 default = 1)
%     direction   Direction of dilation:
%                   'upstream'   Upstream only
%                   'downstream' Downstream only
%                   'both'       Both directions (default)
%
% Output arguments
%
%     ad      Dilated logical node-attribute list
%
% See also: STREAMobj/erode, imdilate
%
% Author: Wolfgang Schwanghart (schwangh[at]uni-potsdam.de)
% Date: 19. November, 2026

arguments
    S   STREAMobj
    a   {mustBeGRIDobjOrNal(a,S)}
    options.steps (1,1) {mustBeInteger,mustBePositive} = 1
    options.direction {mustBeMember(options.direction,...
        {'upstream','downstream','both'})} = 'both'
end

a = ezgetnal(S,a,'logical');

n = numel(S.x);
% Construct adjacency matrix
M = sparse(S.ix,S.ixc,1,n,n);
switch options.direction
    case 'upstream'
        % M = M;
    case 'downstream'
        M = M';
    case 'both'
        M = M + M';
end
M = spones(M + speye(n));

for r = 1:options.steps
    a = M*a > 0;
end
        
