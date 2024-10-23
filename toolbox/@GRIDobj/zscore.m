function X = zscore(X)

%ZSCORE Standardized z-scores for GRIDobj
%
% Syntax
%
%     Z = zscore(X)
%
% Description
%
%     zscore returns the z-score for each element of GRIDobj X such that 
%     all values of X are centered to have mean 0 and scaled to have 
%     standard deviation 1.
%
% Input arguments
%
%     X     GRIDobj
%
% Output arguments
%
%     Z     GRIDobj
% 
% Example
%
%     DEM = GRIDobj('srtm_bigtujunga30m_utm11.tif');
%     Z = zscore(DEM);
%     imagesc(Z); colorbar
% 
% See also: GRIDobj, zscore
% 
% Author: Wolfgang Schwanghart (schwangh[at]uni-potsdam.de)
% Date: 3. June, 2024

X.Z    = (X.Z-mean(X.Z,"all","omitmissing"))./...
          std(X.Z,0,"all","omitmissing");