function DEM = diffusion(DEM,options)

%DIFFUSION Solve the diffusion equation
%
% Syntax
%
%     DEMd = diffusion(DEM)
%     DEMd = diffusion(DEM,pn,pv,...)
%
% Description
%
%     This function uses an implicit scheme to solve the linear diffusion
%     equation for a DEM.
%
% Input arguments
%
%     DEM     digital elevation model
%
%     Parameter name/value pairs
%
%     D           diffusivity (m^2 /y) (default = 1)
%     timespan    duration (y) (default = 1000)
%     numsteps    number of iterations (default = 5)
%     streamnet   STREAMobj. If provided, then elevation values along the
%                 stream network remain fixed (see also option fixedbc).
%     solver      'pcg' (default) or '\'
%     pcgtol      1e-6 (default)
%     uplift      GRIDobj or scalar (default = 0) in mm/y (see upliftunit)
%     upliftunit  unit of uplift ({'mmy-1'} or 'my-1')
%     fixedbc     GRIDobj (underlying class logical) with true values
%                 indicating pixels that should retain their elevation 
%                 values during the simulation.
%     
% Output arguments
%
%     DEMd    diffused DEM
%
% Example
%
%     DEM = GRIDobj('srtm_bigtujunga30m_utm11.tif');
%     FD  = FLOWobj(DEM);
%     S   = STREAMobj(FD,'minarea',200);
%     DEMd = DEM;
%     for r = 1:10;
%        DEMd = diffusion(DEMd,'streamnet',S,'D',10); 
%        imageschs(DEMd); 
%        drawnow; 
%     end
%     figure
%     imageschs(DEM,DEMd-DEM)
%
% See also: GRIDobj/filter, ttlem
%
% Author: Wolfgang Schwanghart (schwangh[at]uni-potsdam.de)
% Date: 12. June, 2026

arguments
    DEM
    options.timespan (1,1) {mustBeNumeric,mustBePositive} = 1000
    options.numsteps (1,1) {mustBeInteger,mustBePositive} = 5
    options.D = 1
    options.streamnet = []
    options.solver {mustBeMember(options.solver,{'\','pcg'})} = 'pcg'
    options.pcgtol (1,1) {mustBeNumeric,mustBePositive} = 1e-6
    options.fixedbc = []
    options.uplift = 0
    options.upliftunit {mustBeMember(options.upliftunit,{'mmy-1','my-1'})} = 'mmy-1';
end

D = options.D;
numsteps = options.numsteps;
dt = options.timespan / numsteps;
dx = DEM.cellsize;

nrc = prod(DEM.size);

% get neighbor indices
[ic,icd] = ixneighbors(DEM.Z,[],4);

% remove indices to nan-cells
I = isnan(DEM.Z(ic)) | isnan(DEM.Z(icd));
ic(I) = [];
icd(I) = [];

% Calculate alpha
if isa(D,'GRIDobj')
	alpha = D.Z(:)*dt/(dx.^2);
else
	alpha = repmat(D,numel(DEM.Z),1)*dt/(dx.^2);
end

if isempty(options.streamnet) && isempty(options.fixedbc)
    % calculate laplacian
    L  = sparse(ic,icd,1,nrc,nrc);
    L  = spdiags(sum(L,2),0,nrc,nrc) - L;
	A  = speye(nrc) + spdiags(alpha,0,nrc,nrc)*L;
else
    if isempty(options.fixedbc)
    	S  = STREAMobj2GRIDobj(options.streamnet);
    elseif isempty(options.streamnet)
        S  = options.fixedbc;
    else
        S  = STREAMobj2GRIDobj(options.streamnet) | options.fixedbc;
    end
    I      = S.Z(ic);
    ic(I)  = [];
    icd(I) = [];

    % calculate laplacian
    L = sparse(ic,icd,1,nrc,nrc);
    L = spdiags(sum(L,2),0,nrc,nrc) - L;
    A = speye(nrc) + (spdiags(alpha(:),0,nrc,nrc)*L);
end

% must work with doubles
% remember class
c        = class(DEM.Z);
% ensure double
DEM.Z    = double(DEM.Z);

% set nan values to zero
I        = isnan(DEM.Z);
DEM.Z(I) = 0;

% solve
Z1 = DEM.Z(:);

if isa(options.uplift,'GRIDobj')
    u = options.uplift.Z;
else 
    u = double(options.uplift);
    u = repmat(u,DEM.size);
end

if ~isempty(options.streamnet) || ~isempty(options.fixedbc)
    u(S.Z) = 0;
end
u = u(:);

switch options.upliftunit
    case 'mmy-1'
        u = u/1000 * dt; % convert to my^-1
    case 'my-1'
        u = u*dt;
end

for r = 1:numsteps
    switch options.solver
        case '\'
            Z1 = A\(Z1+u);
        case 'pcg'
            [Z1,~] = pcg(A,double(Z1+u),options.pcgtol,[],[],[],Z1);
        otherwise
            error('unknown solver')
    end
end

% reshape
DEM.Z = reshape(Z1,DEM.size);
% reset values to nan
DEM.Z(I) = nan;
% reset input class
DEM.Z = cast(DEM.Z,c);