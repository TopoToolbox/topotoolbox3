classdef STREAMobj
    
%STREAMobj Create stream object (STREAMobj)
%
% Syntax
%
%     S = STREAMobj(FD,W)
%     S = STREAMobj(FD,pn,pv)
%
% Description
%
%     An instance of stream object encapsulate the information on geometry
%     and connectivity of a stream network based on the flow direction of a
%     digital elevation model and a logical raster that indicates the
%     position of streams. STREAMobj provides access to various methods
%     that investigate properties of a stream network and associated data.
%
% Input arguments
%
%     FD     instance of flow direction object (FLOWobj)
%     W      logical grid (GRIDobj) that indicates stream locations (e.g.
%            obtained from thresholding the flow accumulation raster)
%
% Parameter name/value pairs
%
%     minarea      upslope area threshold for channel initiation (default =
%                  1000)
%     unit         'pixels' (default), 'mapunits', 'm2', or 'km2'. Note
%                  that if mapunits is chosen, than STREAMobj assumes that
%                  coordinates are measured in m. 'm2' thus produces the
%                  same output as 'mapunits', if FD has a projected
%                  coordinate system. Note that if S was derived from a DEM
%                  with geographical coordinates, then the default unit is
%                  'm2' and 'pixels' and 'mapunits' is not allowed.
%     outlets      linear indices of drainage basin outlets (default = [])
%     channelheads linear indices of channelheads (this argument can only
%                  be used when no other parameters are set).
%
% Output arguments
%
%     S      instance of STREAMobj
%
% Examples
%
%     DEM = GRIDobj('srtm_bigtujunga30m_utm11.tif');
%     FD  = FLOWobj(DEM,'preprocess','c');
%     S = STREAMobj(FD,flowacc(FD)>1000);
%     plot(S)
%
% Note: You can use flowpathapp to manually map channelheads and export an
%       instance of STREAMobj.
%  
% See also: STREAMobj/modify, FLOWobj, GRIDobj, flowpathapp
%
% Author: Wolfgang Schwanghart (schwangh[at]uni-potsdam.de)
% Date: 2. July, 2024
    
        
properties
    size      % size of instance of GRIDobj from which STREAMobj was derived
    ix        % [edge attribute] topologically sorted nodes (givers) 
    ixc       % [edge attribute] topologically sorted nodes (receivers)
    cellsize  % cellsize
    wf        % 2-by-3 affine transformation matrix (see worldfilematrix)
    georef    % additional information on spatial referencing
    IXgrid    % [node attribute] linear index of stream nodes into instance of GRIDobj
    x         % [node attribute] x-coordinate vector 
    y         % [node attribute] y-coordinate vector
end

properties (Dependent = true)    
    distance  % [node attribute] distance from outlet (dynamic property)
    orderednanlist % nan-separated index into node attributes
end


methods 
    function S = STREAMobj(FD,W,options)

        arguments
            FD  FLOWobj
            W = []
            options.minarea = 1000
            options.unit {mustBeUnit(options.unit,FD)}  = getdefaultunit(FD)
            options.outlets = []
            options.channelheads = []
        end
        
        
        if ismulti(FD,true)
            error('TopoToolbox:STREAMobj','STREAMobj supports only single flow directions');
        end
        
        if nargin == 2
            % Two input arguments: FD, W
            validatealignment(FD,W);
        else 
           
            IX           = options.outlets;
            minarea      = options.minarea;
            channelheads = options.channelheads;
            unit         = options.unit;
            
            % Dealing with units here
            if ~isGeographic(FD)
                switch unit
                    case 'mapunits'
                        minarea = minarea/(FD.cellsize.^2);
                    case 'km'
                        minarea = minarea*1e6/(FD.cellsize.^2); 
                end
            end
            
            % Create channel mask
            if ~isempty(channelheads)
                W = influencemap(FD,channelheads);
            else
                W = flowacc(FD) >= minarea;
            end
            
            % Restrict stream net to specified outlets
            if ~isempty(IX)
                W = drainagebasins(FD,IX) > 0 & W;
            end

            if ~any(W.Z(:))
                warning('TopoToolbox:STREAMobj',...
                    'There is no stream network that meets your criteria. \n STREAMobj returns an empty instance');
            end
            
        end
        
        % The stream obj should have only 
        % Z = false(size(W.Z));
        % Z(FD.ix) = W.Z(FD.ix);
        % Z(FD.ixc) = W.Z(FD.ixc);
        % W.Z = Z;
        
        Z = false(size(W.Z));
        Z(FD.ix)  = W.Z(FD.ix);
        I = Z(FD.ix);
        Z(FD.ixc(I)) = W.Z(FD.ixc(I));
        W.Z = Z;

        % transfer properties from FLOWobj to STREAMobj
        S.size     = FD.size;
        I          = W.Z(FD.ix);
        S.ix       = double(FD.ix(I));
        S.ixc      = double(FD.ixc(I));
        
        S.cellsize = FD.cellsize;
        S.wf       = FD.wf;
        S.georef   = FD.georef;

        % recalculate stream indices
        IX        = zeros(FD.size,'uint32');
        IX(W.Z)   = 1:nnz(W.Z);
        S.ix      = double(IX(S.ix));
        S.ixc     = double(IX(S.ixc));
        
        I          = S.ixc == 0;
        S.ix(I)    = [];
        S.ixc(I)   = [];
        
        clear IX
        S.IXgrid  = find(W.Z);

        % get coordinate pairs
        [rows,cols] = ind2sub(S.size,S.IXgrid);
        xy =  S.wf*[double(cols(:))-1 double(rows(:))-1 ones(numel(rows),1)]';
        xy = xy';
        S.x = xy(:,1);
        S.y = xy(:,2);
          
    end
    
    
    
    
    
    
    function d = get.distance(S)
        % [dynamic property] distance from outlet
        
        % This parts needs some work once we allow STREAMobjs and FLOWobjs
        % to be based on geographic grids.
        if false % isgeographic(S)
            d_node = sph_distance(S.y(S.ix),S.x(S.ix),S.y(S.ixc),S.x(S.ixc),S.georef.gcs);
        else
            d_node = sqrt((S.x(S.ix)-S.x(S.ixc)).^2 + (S.y(S.ix)-S.y(S.ixc)).^2);
        end
        
        d = zeros(numel(S.x),1);
        for r = numel(S.ix):-1:1
            d(S.ix(r)) = d(S.ixc(r)) + d_node(r);
        end
    end
        
    function order = get.orderednanlist(S)
        % [dynamic property] orderednanlist returns a nan-separated vector 
        % with indices into the nodes of the STREAMobj (e.g. S.x, S.y, etc)
        
        nnal   = numel(S.x);
        nedg   = numel(S.ix);
        
        ixcix  = zeros(nnal,1);
        ixcix(S.ix) = 1:nedg;
        
        notvisited = true(nedg,1);
        row     = 1;
        counter = 1;
        
        order = nan(nedg,1);
        
        while ~isempty(row)
            % initiate new stream
            order(counter)  = S.ix(row);
            % increase counter
            counter         = counter+1;
            
            while row~=0  
                % follow stream
                order(counter)   = S.ixc(row);
                % inidicate as visited
                ixcix(S.ix(row)) = 0;
                notvisited(row)  = false;
                % jump to next row
                row              = ixcix(S.ixc(row));
                % increase counter
                counter          = counter + 1;
            end
            % you have reached the end of the stream
            % separate streams with a nan
            order(counter) = nan;
            % increase counter
            counter        = counter+1;
            % find the next stream head
            row            = find(notvisited,1,'first');
        end
        
        order = order(:);
    end
    
    function [S,locb] = subgraph(S,nal)
    %SUBGRAPH extract part of the stream network
    % 
    % Syntax
    %
    %     Snew = subgraph(S,nal)
    %     [Snew,locb] = subgraph(S,nal)
    %
    % Description
    %
    %     subgraph takes a logical node-attribute list (nal) and extracts  
    %     the nodes in the stream network where elements in nal are true.
    %
    % Input arguments
    %
    %     S       STREAMobj
    %     nal     logical node-attribute list
    %
    % Output arguments
    %
    %     Snew    STREAMobj
    %     locb    linear index into node attribute lists of S
    %
    % Example
    %
    %     DEM = GRIDobj('srtm_bigtujunga30m_utm11.tif');
    %     FD = FLOWobj(DEM,'preprocess','carve');
    %     S = STREAMobj(FD,'minarea',1000);
    %     d = S.distance;
    %     nal = d>10000 & d<30000;
    %     Sn = subgraph(S,nal);
    %     plot(S)
    %     hold on
    %     plot(Sn)
    %     hold off
    %
    % See also: STREAMobj, STREAMobj/getnal, STREAMobj/modify,
    %           STREAMobj/rmnode
    % 
    % Author: Wolfgang Schwanghart (schwangh[at]uni-potsdam.de)
    % Date: 25. September, 2024
    
    arguments
        S  STREAMobj
        nal
    end

    nal = ezgetnal(S,nal);
    nal = nal>0; % make sure that nal is logical
    
    if all(nal)
        % do nothing
        if nargout == 2
            locb = (1:numel(S.IXgrid))';
        end
        return
    end
    
    if nargout == 2
        IXgrid_old = S.IXgrid;
    end
    
    I = nal(S.ix) & nal(S.ixc);

    S.ix  = S.ix(I);
    S.ixc = S.ixc(I);

    IX    = cumsum(nal);

    S.ix  = IX(S.ix);
    S.ixc = IX(S.ixc);

    S.x   = S.x(nal);
    S.y   = S.y(nal);
    S.IXgrid   = S.IXgrid(nal);
    
    S     = clean(S);
    if nargout == 2
        [~,locb] = ismember(S.IXgrid,IXgrid_old);
    end
     
    end
    
    function S = rmnode(S,nal)
    %RMNODE remove nodes in a stream network
    % 
    % Syntax
    %
    %     Snew = rmnode(S,nal)
    %
    % Description
    %
    %     rmnode takes a logical node-attribute list (nal) and removes the 
    %     nodes in the stream network where elements in nal are true.
    %
    % Input arguments
    %
    %     S       STREAMobj
    %     nal     logical node-attribute list
    %
    % Output arguments
    %
    %     Snew    STREAMobj
    %
    % Example
    %
    %     DEM = GRIDobj('srtm_bigtujunga30m_utm11.tif');
    %     FD = FLOWobj(DEM,'preprocess','carve');
    %     S = STREAMobj(FD,'minarea',1000);
    %     d = S.distance;
    %     nal = d>10000 & d<30000;
    %     Sn = rmnode(S,~nal);
    %     plot(S)
    %     hold on
    %     plot(Sn)
    %     hold off
    %
    % See also: STREAMobj, STREAMobj/getnal, STREAMobj/modify,
    %           STREAMobj/subgraph
    % 
    % Author: Wolfgang Schwanghart (schwangh[at]uni-potsdam.de)
    % Date: 25. September, 2024    
    
    arguments
        S    STREAMobj
        nal  
    end

    validateattributes(nal,{'logical'},{"size",[numel(S.x) 1]},'STREAMobj/rmnode','nal',2);
    S = subgraph(S,~nal);
    
    end
        
    function S = rmedge(S,eal)
    %RMEDGE remove edges in a stream network
    % 
    % Syntax
    %
    %     Snew = rmedge(S,eal)
    %
    % Description
    %
    %     RMEDGE takes a logical edge-attribute list (eal) and removes the 
    %     edges in the stream network where elements in eal are true.
    %
    % Input arguments
    %
    %     S       STREAMobj
    %     eal     logical edge-attribute list
    %
    % Output arguments
    %
    %     Snew    STREAMobj
    %
    % Example: Plot the stream network without zero gradient sections
    %
    %     DEM = GRIDobj('srtm_bigtujunga30m_utm11.tif');
    %     FD = FLOWobj(DEM,'preprocess','carve');
    %     S = STREAMobj(FD,'minarea',1000);    
    %     z = imposemin(S,getnal(S,DEM));
    %     I = (z(S.ix)-z(S.ixc)) == 0;
    %     Snew = rmedge(S,I);
    %     plot(Snew)
    %
    % See also: STREAMobj, STREAMobj/getnal, STREAMobj/modify
    % 
    % Author: Wolfgang Schwanghart (schwangh[at]uni-potsdam.de)
    % Date: 25. September, 2024

    arguments
        S    STREAMobj
        eal  
    end

    validateattributes(eal,{'logical'},{"size",[numel(S.ix) 1]},'STREAMobj/rmnode','eal',2);
    
    eal   = ~eal;
    
    S.ix  = S.ix(eal);
    S.ixc = S.ixc(eal);
    
    nal   = false(numel(S.IXgrid),1);
    nal(S.ix)  = true;
    nal(S.ixc) = true;

    IX    = cumsum(nal);

    S.ix  = IX(S.ix);
    S.ixc = IX(S.ixc);

    S.x   = S.x(nal);
    S.y   = S.y(nal);
    S.IXgrid   = S.IXgrid(nal);
     
    end
    
    function tf = issubgraph(S,FD)
    %ISSUBGRAPH tests if stream network is a subgraph of another stream or flow network
    %
    % Syntax
    %
    %     tf = issubgraph(S,FD)
    %     tf = issubgraph(S,S2)
    %
    % Description
    % 
    %     ISSUBGRAPH tests if a stream network S is a subgraph of the flow
    %     network in FD or another stream network in S2.
    %
    % Input arguments
    %
    %     S     STREAMobj
    %     FD    FLOWobj
    %     S2    STREAMobj
    %
    % Output arguments
    %
    %     tf    true or false scalar
    %
    % Example
    %
    %     DEM = GRIDobj('srtm_bigtujunga30m_utm11.tif');
    %     FD = FLOWobj(DEM,'preprocess','carve');
    %     S = STREAMobj(FD,'minarea',1000);
    %     S2 = klargestconncomps(S);
    %     % is S a subgraph of FD -> yes
    %     issubgraph(S2,FD)
    % 
    %     ans =
    % 
    %       logical
    % 
    %        1
    % 
    %     % is S a subgraph of S2 -> no
    %     issubgraph(S,S2)
    % 
    %     ans =
    % 
    %       logical
    % 
    %        0
    % 
    %     % is S2 a subgraph of S -> yes
    %     issubgraph(S2,S)
    % 
    %     ans =
    % 
    %       logical
    % 
    %        1
    % 
    % 
    % See also: STREAMobj/modify, STREAMobj/conncomps
    % 
    % Author: Wolfgang Schwanghart (schwangh[at]uni-potsdam.de)
    % Date: 25. September, 2024
    
    arguments
        S  STREAMobj
        FD 
    end
    
    n  = prod(S.size);
    M  = sparse(S.IXgrid(S.ix),S.IXgrid(S.ixc),true,n,n);
    if isa(FD,'STREAMobj')
        S2 = FD;
        M2 = sparse(S2.IXgrid(S2.ix),S2.IXgrid(S2.ixc),true,n,n);
        
        
    elseif isa(FD,'FLOWobj')
        M2 = FLOWobj2M(FD);
        M2 = M2>0;
    end
    tf = isequal(M2,M2|M);
    end


    function S = clean(S)

    %CLEAN remove non-connected nodes in stream networks
    %
    % Syntax
    %
    %     Sc = clean(S)
    %
    % Description
    %
    %     Modifying a STREAMobj S may sometimes generate nodes in S that have
    %     neither an incoming nor outgoing edge. This functions removes these
    %     nodes as most calculations on stream networks will dismiss them
    %     anyway.
    %
    % Input arguments
    %
    %     S     STREAMobj
    %
    % Output arguments
    %
    %     Sc    cleaned STREAMobj
    %
    % See also: STREAMobj, STREAMobj/modify
    %
    % Author: Wolfgang Schwanghart (schwangh[at]uni-potsdam.de)
    % Date: 25. September, 2024
    
    arguments
        S  STREAMobj
    end


    % non connected nodes in the stream network are those that have neither an
    % incoming nor an outgoing edge

    M = sparse(S.ix,S.ixc,true,numel(S.x),numel(S.y));
    I = (sum(M,2) == 0) & (sum(M,1)' == 0);
    S = rmnode(S,I);
    end


end
end   
    
    
function unit = getdefaultunit(FD)
    if isGeographic(FD)
        unit = 'm';
    else
        unit = 'pixels';
    end
end

function mustBeUnit(unit,FD)
    if isGeographic(FD)
        validatestring(unit,{'m', 'km'});
    else
        validatestring(unit,{'m', 'km', 'pixels', 'mapunits'});
    end
end
    