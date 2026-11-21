function a = erode(S,a,options)

%ERODE Erode a logical node-attribute list along a stream network
%
% Syntax
%
%     ae = erode(S,a)
%     ae = erode(S,a,Name,Value)
%
% Description
%
%     Erodes a logical node-attribute list along a stream network.
%     True values are retained only if all neighboring nodes are true
%     for a specified number of steps. Erosion can proceed upstream,
%     downstream, or in both directions.
%
%     The erosion length specifies the maximum number of edges
%     traversed along the network, not a physical distance.
%
% Input arguments
%
%     S       STREAMobj
%     a       Logical node-attribute list or GRIDobj
%
%     Parameter Name-Value arguments
%
%     steps       Number of edges to erode (topological distance,
%                 default = 1)
%     direction   Direction of erosion:
%                   'upstream'   Upstream only
%                   'downstream' Downstream only
%                   'both'       Both directions (default)
%
% Output arguments
%
%     ae       Eroded logical node-attribute list
%
% See also: STREAMobj/dilate, imerode
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

% Count neighboring nodes
N = sum(M,2);

for r = 1:options.steps
    a = (M*a) == N;
end
