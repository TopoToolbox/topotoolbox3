function [P,locb] = aggregate(P,c,varargin)

%AGGREGATE Aggregate points in PPS to new point pattern
%
% Syntax
%
%     P2  = aggregate(P,c)
%     P2  = aggregate(P,c,pn,pv,...)
%
% Description
%
%     aggregate merges points in a PPS object to a new PPS object based on
%     the labels in the marks c. The labels can be generated by the
%     function PPS/cluster. Equal labels in c must not occur in different
%     drainage basins. Moreover, the edges of a shortest path tree between
%     points with a specific label must not lie on shortest path trees
%     of other labels.
%
% Input arguments
%
%     P      instance of PPS
%     c      npoints(P)x1 label vector
%
%     Parameter name/value pairs
%
%     'type'         'centroid' (default) finds the location in the network
%                    that has the least squared distance to all points
%                    with the same label. Distances are calculated along
%                    the stream network.
%                    'euclideancentroid' calculates the centroid of all
%                    points with the same label and snaps the location of
%                    the centroid to the stream network. 
%                    'nearesttocentroid' calculates the centroid and then
%                    chooses the point that is nearest to this centroid.
%
% Output arguments
%
%     P2     PPS object
%
% Example
%
%     DEM = GRIDobj('srtm_bigtujunga30m_utm11.tif');
%     FD  = FLOWobj(DEM);
%     S   = STREAMobj(FD,'minarea',500);
%     S   = klargestconncomps(S,1);
%     P   = PPS(S,'runif',200,'z',DEM);
%     c   = cluster(P,'cutoff',2000);
%     convhull(P,'groups',c,'bufferwidth',200)
%     P2  = aggregate(P,c);
%     hold on
%     plotpoints(P2,'Size',30,'MarkerFaceColor','b')
%     hold off
%     axis equal
%     box on
%
% See also: PPS, PPS/cluster, PPS/convhull
%
% Author: Wolfgang Schwanghart (schwangh[at]uni-potsdam.de)
% Date: 5. July, 2024


p = inputParser;
p.KeepUnmatched = true;
addRequired(p,'P');
addRequired(p,'c',@(x) numel(x) == npoints(P));
addParameter(p,'type','centroid');
addParameter(p,'useparallel',true);

% Parse
parse(p,P,c,varargin{:});

type = validatestring(p.Results.type,...
    {'centroid','euclideancentroid',...
    'nearesttocentroid','mostupstream','mostdownstream'});

% make sure that one label does not occur in multiple drainage basins.
concom = conncomps(P.S);
concom = getmarks(P,concom);
tf     = accumarray(c,concom,[],@(x) numel(unique(x)));
if any(tf>1)
    error('Labels span across more than one drainage basin.')
end

switch lower(type)
    case {'mostupstream','mostdownstream'}
        [uniquec,~,locb] = unique(c);
        d = P.S.distance;
        d = getmarks(P,d);
        switch lower(type)
            case 'mostdownstream'
                d = 1./d;
        end
        d = sparse((1:numel(locb))',locb,d,numel(locb),max(locb));
        [~,ix] = max(d);
        P.PP = P.PP(ix);
    
    case 'nearesttocentroid'
        % Calculate centroids
        [Pc,locb] = aggregate(P,c,'useparallel',p.Results.useparallel);
        % Nearest to centroid
        G  = as(P,'graph');
        d = distances(G,P.PP,Pc.PP);
        % get distance from each point to centroid of its group
        ix = sub2ind(size(d),(1:size(d,1))',locb);
        I  = true(size(d));
        I(ix) = false;
        d(I)  = inf; 
        
        [~,ix] = min(d);
        
        P.PP = P.PP(ix);
    
    case 'euclideancentroid'
        % Euclidean distance is easy. 
        [uniquec,~,locb] = unique(c); 
        nc    = numel(uniquec);
        [x,y] = points(P);
        % calculate centroids for each label
        xc = accumarray(locb,x,[nc 1],@mean);
        yc = accumarray(locb,y,[nc 1],@mean);
        
        % snap centroids back to the stream network
        [~,~,IX] = snap2stream(P.S,xc,yc);
        % and update the point pattern in P
        [~,P.PP] = ismember(IX,P.S.IXgrid);
    
    case 'centroid'
         
        % The network centroid is a bit more tricky
        G    = as(P,'graph');
        % This line returns for each label the edges that belong to the
        % minimum spanning tree that connects the points
        [~,~,c] = unique(c);
        locb = c;
        G.Nodes.group = zeros(size(P.S.x));
        G.Nodes.group(P.PP) = c;

        E    = accumarray(c,P.PP,[max(c) 1],@(x) {spedges(x)});
        % list the edges
        E    = vertcat(E{:});

        if numel(unique(E)) ~= numel(E)
            error('Overlapping shortest path trees');
        end
        
        % Edges that should be removed from the graph
        E       = setdiff(1:size(G.Edges,1),E);
        G       = rmedge(G,E');
        % Also remove nodes with zero degree
        G       = rmnode(G,find(degree(G) == 0));  
        % Calculate the connected components of the remaining network
        cc      = conncomp(G,'outputform','cell');
        
        % Go through the individual connected components
        ix      = zeros(size(cc));
        cl      = zeros(size(cc));
%         pp      = cell(size(cc));
        parfor r = 1:numel(cc)
            % Extract the subgraph that contains each connected component
            GSUB = subgraph(G,cc{r});
            % Calculate distances from each point to all nodes 
            d    = distances(GSUB,find(GSUB.Nodes.ispoint));
            % Calculate the sum of squares
            d    = sum(d.^2,1);
            % Find the node with the minimum sum of squares
            [~,ixx] = min(d);
            ix(r)  = GSUB.Nodes.pts(ixx);
            cl(r)  = GSUB.Nodes.group(find(GSUB.Nodes.ispoint,1,'first'));
            
        end
        I    = accumarray(c,1) > 1;
        I    = I(c);
        % gr = locb(P.PP);
        P.PP(I) = [];
        P.PP = [P.PP;ix(:)];
        locb = c;
        
end


function E = spedges(nodes)

nodes = unique(nodes);    
if numel(nodes) == 1
    E = [];
    return
end
[~,~,E] = shortestpathtree(G,nodes(1),nodes(2:end));
E = find(E);

end
end

