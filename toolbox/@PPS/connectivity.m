function [metric,label] = connectivity(P,options)

%CONNECTIVITY River network connectivity according to Flecker et al. (2022)
%
% Syntax
%
%     metric = connectivity(P)
%     [metric,label] = connectivity(P,'pn',pv,...)
%
% Description
%
%     This function calculates the potamodromous connectivity RCIP and the
%     diadromous connectivity RCID according to Flecker et al. (2022).
%     Points in the point pattern PPS are considered as dams that have a
%     fish passability of 0.5. 
%
% Input arguments
%
%     P     PPS
%     
%     Parameter name/value pairs
%
%     'streamorder'    default = streamorder(P.S). Distance calculations
%                      are weighted according to 2 to the power of 
%                      streamorder as a proxy of river volume
%     'p'              scalar or vector with npoints(P) entries between 0
%                      and 1, indicating the passability between river
%                      segments.
%     'type'           'RCIP' (default) or 'RCID' (see Flecker et al.
%                      (2022), Eq. 1 an 2 in the supplements).
%
% Output arguments
%
%     metric   connectivity metric
%     label    node-attribute list with connected components (RCIP) or the
%              shortest river stretch between the outlet and the first dam.
%
% Example
%
%     DEM = GRIDobj('srtm_bigtujunga30m_utm11.tif');
%     FD = FLOWobj(DEM);
%     S = STREAMobj(FD,'minarea',1000); 
%     S = klargestconncomps(S);
%     P = PPS(S,'runif',10,'z',DEM);
%     [RCIP,label] = connectivity(P,'type','RCIP');
%     plotc(P,label);
%     title(['RCIP = ' num2str(RCIP)])
%
% See also: PPS
%
% Author: Wolfgang Schwanghart (schwangh[at]uni-potsdam.de)
% Date: 4. March, 2025

arguments
    P  PPS {mustBeSingleBasin} 
    options.streamorder = streamorder(P.S)
    options.p = 0.5
    options.type {mustBeMember(options.type,{'RCIP','RCID'})} = 'RCIP'
end


switch lower(options.type)
    case 'rcip'
        % Break network at locations into connected components
        label = getnal(P.S);
        label(P.PP) = 1:npoints(P);

        c = npoints(P)+1;
        ix = P.S.ix;
        ixc = P.S.ixc;
        for r = numel(ix):-1:1
            if label(ixc(r)) == 0
                % outlet
                label(ixc(r)) = c;
                c = c+1;
            end
            if label(ix(r)) == 0
                label(ix(r)) = label(ixc(r));
            end
        end


        nlabels = max(label);
        [~,locb] = ismember(P.PP,P.S.ix);
        labelup  = label(P.S.ix(locb));
        labeldo  = label(P.S.ixc(locb));

        w = (2.^options.streamorder).*distance(P.S,'node_to_node');
        Lstar = sum(w);
        vals  = accumarray(label,w,[],@sum)/Lstar;
        p     = sparse(labelup,labeldo,options.p,nlabels,nlabels);
        p     = p+p';
        p     = p+speye(nlabels);
        RCIp  = vals'.*vals .* p;
        RCIp  = full(sum(RCIp(:))*100);
        metric = RCIp;

    case 'rcid'
        w = (2.^options.streamorder).*distance(P.S,'node_to_node');
        Lstar = sum(w);
        w = cumsum(P.S,w,'upstream');
        [w,ixx] = min(w(P.PP));
        metric = 100*w/Lstar;

        if nargout == 2
            S2    = modify(P.S,'downstreamto',P.S.IXgrid(ixx));
            label = nal2nal(S2,P.S,getnal(S2,1),0);
        end
end


end
function mustBeSingleBasin(P)

ix = streampoi(P.S,'outlet','ix');
if numel(ix)>1
    error('The stream network must contain only one basin.')
end
end


