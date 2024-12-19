function A = minmaxnorm(A,prcclip)

%MINMAXNORM Min-max normalization with optional percent clipping
%
% Syntax
%
%     B = minmaxnorm(A)
%     B = minmaxnorm(A,prc)
%
% Description
%
%     minmaxnorm normalizes GRIDobj A to a range between 0 and 1.
%     Optionally, extremes of the data can be removed by percent clipping
%     such that values higher (lower) the 1-prc (prc) percentile are set 
%     to 1 (0).
%
% Input arguments
%
%     A     GRIDobj
%     prc   percentile, scalar value between 0 and 100.
%
% Output arguments
%
%     B     GRIDobj with values that range between 0 and 1.
%
% See also: normalize, GRIDobj/zscore
% 
% Author: Wolfgang Schwanghart (schwangh[at]uni-potsdam.de)
% Date: 11. December, 2024

arguments
    A  GRIDobj
    prcclip {mustBeNumeric,mustBeInRange(prcclip,0,100)} = 2
end

if nargin == 1
    minz = min(A);
    maxz = max(A);
    A = (A - minz)/(maxz-minz);
else

    if isscalar(prcclip)
        prclow = prcclip;
        prchigh = 1-prclow;
    else
        validateattributes(prcclip,{'numeric'},{'increasing'},...
            "minmaxnorm","prcclip",2)
        prclow = prcclip(1);
        prchigh = prcclip(2);
    end

    qlow  = prclow/100;
    qhigh = prchigh/100;

    Z = A.Z;
    I = ~isnan(Z);

    [n,edges] = histcounts(Z(I(:)),'Normalization','cdf');
    lval = edges(find(n>=qlow,1,'first'));
    uval = edges(find(n<qhigh,1,'last'));

    if lval == uval
        warning('TopoToolbox:minmaxnorm','The returned matrix is flat.');
        Z(I) = lval;
    else
        Z(I) = max(Z(I),lval);
        Z(I) = min(Z(I),uval);
        Z(I) = (Z(I)-lval)/(uval-lval);
    end
    
    A.Z = Z;
    
end

