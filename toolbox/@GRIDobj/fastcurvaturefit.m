function C = fastcurvaturefit(DEM,ws,options)

%FASTCURVATUREFIT Fast calculation of curvature using polynomial fit
%
% Syntax
%
%     C = fastcurvaturefit(DEM,ws)
%
% Description
%
%     This function calculates the curvature of a Digital Elevation Model
%     (DEM) by fitting a second-order (quadratic) 2D polynomial surface to
%     elevation values within a specified arbitrary window size centered on
%     each DEM cell. The polynomial takes the form:
%
%     z = rx^2 + ty^2 + sxy + px + qy + o
%
%     General curvature C is then calculated by C = 2r+2s which is the
%     laplacian. In terms of DEMs, values of C tell you how the elevation 
%     at a point compares to the average elevations nearby. If C is 
%     positive, the value at the point is less than in the surroundings -
%     like a valley. If it is negative, the function is greater than its 
%     surroundings — like a hill. Calculating C with larger window sizes
%     means that locations in increasing distance are taken into account.
%     This emphasizes the geometry at larger scales and that individual 
%     locations are compared to their larger surrounding rather than their
%     immediate neighboring locations.
%
%     The function proceeds as follows:
%
%     (1) Based on the window size and neighborhood, the design matrix for
%     a regression analysis is derived. The coordinate vectors x and y
%     thereby represent a local coordinate system centered at the central
%     pixel of the window.
%
%     X = [x.^2 y.^2 x.*y x y 1]
%     
%     (2) Then, the equation to obtain the parameters is obtained. In
%     general, these are obtained by solving the overdetermined system
%     using least squares. The resultant matrix (P = inv(X'*X)*X') is the
%     Moore-Penrose pseudoinverse. By default, calculation of this matrix
%     is done using pinv, which is better than using inv both in terms of
%     numerical stability and performance. The matrix is constant and only
%     depends on the window size and cellsize. 
%
%     (3) The parameter a in the polynomial equation, can then be
%     calculated by the dot product P(1,:)*z, where z is the column vector
%     of elevations in the window. The dot product can also be expressed as
%     a 2D convolution which will be very fast to calculate the parameter
%     for each pixel in the DEM. Similarly, parameter b in the polynomial
%     equation is calculated using P(2,:)*z and the convolution is
%     repeated.
%
%     The approach generalizes the method of Pennock et al. (1987) and
%     Shary et al. (2002) to quadratic windows with arbitrary sizes.
%
%     Note that the function will not pad the grid and that only the valid
%     part of the convolution is returned. Pixel along the edges will be
%     set to nan. 
%
% Input arguments
%
%     DEM     GRIDobj
%     ws      window size (default = 11). Must be positive and odd integer
%
%     Parameter name/value pairs
%
%     'usepinv'   use pinv instead of inv. By default, true.
%
% Example
%
%     DEM = GRIDobj('srtm_bigtujunga30m_utm11.tif');
%     C = fastcurvaturefit(DEM,31);
%     m = max(abs([min(C) max(C)]));
%     imageschs(DEM,C,'colormap',ttscm('vik'),'clim',[-m m]);
%
% Reference
%
%     Shary, P. A., Sharaya, L. S., and Mitusov, A. V.: Fundamental
%     quantitative methods of land surface analysis, Geoderma, 107, 1–32,
%     https://doi.org/10.1016/S0016-7061(01)00136-7, 2002.
%
%     Pennock, D. J., Zebarth, B. J., and De Jong, E.: Landform
%     classification and soil distribution in hummocky terrain,
%     Saskatchewan, Canada, Geoderma, 40, 297–315,
%     https://doi.org/10.1016/0016-7061(87)90040-1, 1987.
% 
% See also: GRIDobj, GRIDobj/curvature
% 
% Author: Wolfgang Schwanghart (schwangh[at]uni-potsdam.de)
% Date: 22. May, 2025

arguments
    DEM  GRIDobj
    ws   (1,1) {validateattributes(ws,...
        {'numeric'},{'positive','integer','odd'})} = 3
    options.usepinv (1,1) = true
    options.type {mustBeTextScalar,mustBeMember(options.type,{'laplacian','gaussian'})} = 'laplacian'
end

K = surfacefitkernel(DEM,ws,'usepinv',options.usepinv);

% Convolution
R  = conv2(DEM.Z,K.r,"same");
T  = conv2(DEM.Z,K.t,"same");

switch options.type
    case 'laplacian'

        % Addition of both curvatures in both directions gives laplacian
        C = 2*R + 2*T;
        
    case 'gaussian'
        
        S = conv2(DEM.Z,K.s,"same");
        P = conv2(DEM.Z,K.p,"same");
        Q = conv2(DEM.Z,K.q,"same");

        C = (4*R.*T - S.^2)./((1 + P.^2 + Q.^2).^2);
        % C = (P.^2 + Q.^2).^(1/2); 
end

% Set invalid parts of the grid to nan
cw = floor(ws/2);
C(:,1:cw) = nan;
C(:,end-cw:end) = nan;
C(1:cw,:) = nan;
C(end-cw:end,:) = nan;

% Return GRIDobj
C  = GRIDobj(DEM,C);
