function [lims,A] = prcclip(A,prc,symmetric)

%PRCCLIP Percentile clipping
%
% Syntax
%
%     lims = prcclip(A,prc)
%     lims = prcclip(A,prc,symmetric)
%     [lims,Ac] = prcclip(A,prc)
%     
% Description
%
%     This function clips the values of the input `GRIDobj` to a specified
%     percentile range, allowing for optional symmetric clipping. The
%     function calculates the cumulative distribution of values in the `Z`
%     field of the GRIDobj, ignoring NaNs. It determines the clipping
%     limits based on the specified percentile range and adjusts the values
%     in `A.Z` accordingly. If the symmetric option is enabled, the
%     clipping limits are made symmetric around zero. If the resulting
%     limits are identical, a warning is issued, and no changes are made to
%     the `Z` values.
%
% Input arguments
%
%     A          GRIDobj
%     prc        Percentile for clipping (default = 2). This value is
%                interpreted as the percentage of data to clip from both
%                the lower and upper ends of the distribution. If a scalar
%                is provided, it clips at prc% from the lower bound and
%                (100 - prc)% from the upper bound. To specify different
%                lower and upper clipping thresholds, provide 'prc' as a
%                2-element vector [lower_percentile upper_percentile].
%     symmetric  Boolean flag (default = false). If true, the clipping
%                limits are forced to be symmetric around zero by taking
%                the maximum absolute value of the lower and upper bounds.
%                This is useful for visualizing data with a balanced range
%                about zero.
%
% Output arguments
%
%     lims       A two-element vector [lval, uval] representing the 
%                calculated lower and upper clipping limits.
%     Ac         percentile clipped GRIDobj
%
% Example
%
%     DEM = GRIDobj('srtm_bigtujunga30m_utm11.tif');
%     C   = curvature(DEM);
%     lims = prcclip(C,2,true);
%     clr = ttscm('vik');
%     imageschs(DEM,C,'colormap',clr,'caxis',lims);
%     
%
% See also: GRIDobj/minmaxnorm, GRIDobj/zscore
%
% Author: Wolfgang Schwanghart (schwangh[at]uni-potsdam.de)
% Date: 14. June, 2024

arguments
    A    GRIDobj
    prc  = 2
    symmetric (1,1) = false
end
    
qclip = prc/100;
if numel(qclip) == 1
    qclip = [qclip 1-qclip];
end

qclip = sort(qclip);

I = ~isnan(A.Z);

[n,edges] = histcounts(A.Z(I(:)),'Normalization','cdf');
lval = edges(find(n>=qclip(1),1,'first'));
uval = edges(find(n<(qclip(2)),1,'last'));
if lval == uval
    warning('TopoToolbox:imageschs','percent clip returns flat matrix');

else
    if nargout == 2
        A.Z(I) = max(A.Z(I),lval);
        A.Z(I) = min(A.Z(I),uval);
    end
    
end

lims = [lval,uval];

if symmetric
    lims = max(abs(lims));
    lims = [-lims lims];
end

% if nargout == 2
%     if flatmatrix
%         A(:,:) = lval;
%     else
%         A = max(A,lims(1));
%         A = min(A,lims(2));
%     end
% end
    
    