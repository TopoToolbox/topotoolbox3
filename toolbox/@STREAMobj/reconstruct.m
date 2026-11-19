function a = reconstruct(S,marker,mask,options)

%RECONSTRUCT Morphological reconstruction of a node-attribute list
%
% Syntax
%
%     a = reconstruct(S,marker,mask)
%     a = reconstruct(S,marker,mask,Name,Value)
%
% Description
%
%     Performs morphological reconstruction by dilation along a
%     stream network. The marker is iteratively dilated, while its
%     values are constrained by the mask.
%
%     Reconstruction continues until convergence. Both logical and
%     grayscale node-attribute lists are supported.
%
% Input arguments
%
%     S       STREAMobj
%     marker  Marker node-attribute list or GRIDobj
%     mask    Mask node-attribute list or GRIDobj
%
%     Parameter Name-Value arguments
%
%     direction   Direction of reconstruction:
%                   'upstream'   Upstream only
%                   'downstream' Downstream only
%                   'both'       Both directions (default)
%
% Output arguments
%
%     a       Reconstructed node-attribute list
%
% See also: dilate, erode, components, STREAMobj

arguments
    S   STREAMobj
    marker {mustBeGRIDobjOrNal(marker,S)}
    mask   {mustBeGRIDobjOrNal(mask,S)}
    options.direction {mustBeMember(options.direction,...
        {'upstream','downstream','both'})} = 'both'
end

marker = ezgetnal(S,marker);
mask   = ezgetnal(S,mask);

marker = marker(:);
mask   = mask(:);

n = numel(S.x);

% Check marker and mask
if any(isnan(marker) | isnan(mask))
    error('Marker and mask must not contain NaN values.')
end

if any(marker > mask)
    error('Marker must be less than or equal to mask.')
end

% Define neighborhood according to propagation direction
switch options.direction
    case 'upstream'
        i = S.ix;
        j = S.ixc;
    case 'downstream'
        i = S.ixc;
        j = S.ix;
    case 'both'
        i = [S.ix; S.ixc];
        j = [S.ixc; S.ix];
end

% Include each node itself in its neighborhood
i = [i; (1:n)'];
j = [j; (1:n)'];

% Iterative geodesic dilation
a = marker;

while true

    % Maximum value among neighboring nodes
    b = accumarray(i,a(j),[n 1],@max);

    % Constrain values by the mask
    b = min(b,mask);

    % Stop when convergence is reached
    if isequal(a,b)
        break
    end

    a = b;
end

end
