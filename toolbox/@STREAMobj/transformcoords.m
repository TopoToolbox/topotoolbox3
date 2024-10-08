function varargout = transformcoords(S,options)

%TRANSFORMCOORDS transform coordinates of stream network
%
% Syntax
%
%     St = transformcoords(S)
%     St = transformcoords(S,'pn',pv,...)
%     [xt,yt] = ...
%
% Description
%
%     transformcoords lets you transform the spatial coordinates. By default
%     the transformation will be done interactively by drawing a new x-axis 
%     into a planform layout of the river network. Alternatively, the
%     coordinate transformation will be performed automatically using a
%     principal component analysis.
%
%     transformcoords changes the properties S.x and S.y of the stream
%     network, but retains all other properties. The method 'inv' changes
%     the coordinates back to their original values.
%
% Input arguments
%     
%     S      STREAMobj
%     
%     Parameter name/value pairs {default}
%
%     'method'         {'interactive'}, 'pca' or 'inv'
%     'nonnegcoords'   true or {false}. Setting to true will set minimum x
%                      and y values to zero.
%
% Output arguments
%
%     St     transformed STREAMobj
%     xt,yt  node-attribute lists of transformed coordinates
%
% Example
%
%     DEM = GRIDobj('srtm_bigtujunga30m_utm11.tif');
%     FD = FLOWobj(DEM,'preprocess','carve');
%     S = STREAMobj(FD,'minarea',1000);
%     S = klargestconncomps(S);
%     St = transformcoords(S,'method','pca');
%     subplot(2,1,1)
%     plot(S)
%     subplot(2,1,2)
%     plot(St)
%
% See also: STREAMobj
%
% Author: Wolfgang Schwanghart (schwangh[at]uni-potsdam.de)
% Date: 11. June, 2024

arguments
    S  STREAMobj
    options.method = 'interactive'
    options.nonnegcoords = false
end


method = validatestring(options.method,{'pca','interactive','inv'});

switch method
    case 'pca'
        [~,s] = pca([S.x S.y]);
        xx = s(:,1);
        yy = s(:,2);
    case 'interactive'
        plot(S);
        hold on
        h = imline;
        title('Double-click line to finish')
        position = wait(h);
        
        sp = position(1,:);
        ep = position(2,:);
        
        x  = S.x-sp(1);
        y  = S.y-sp(2);
        
        ep = ep-sp;
        ep = ep(:);
        
        % projection of [x; y] on vector a
        beta = (ep' * [x y]')./(ep'*ep);
        xx = beta .* sqrt(ep'*ep);
        yy = beta .* ep;
        yy = [x y]-yy';
        
        s  = sign(yy(:,2));
        yy = hypot(yy(:,1),yy(:,2));
        yy = yy.*s;
    case 'inv'

        [rows,cols] = ind2sub(S.size,S.IXgrid);
        xy =  S.wf*[double(cols(:))-1 double(rows(:))-1 ones(numel(rows),1)]';
        xy = xy';
        xx = xy(:,1);
        yy = xy(:,2);


end

if options.nonnegcoords
    xx = xx - min(xx);
    yy = yy - min(yy);
end

if nargout == 1
    S.x = xx(:);
    S.y = yy(:);
    varargout{1} = S;
    
else
    varargout{1} = xx;
    varargout{2} = yy;
    
end
        


