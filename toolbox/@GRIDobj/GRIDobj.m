classdef GRIDobj
    
%GRIDobj Create instance of a GRIDobj
%
% Syntax
%
%     DEM = GRIDobj(Z)
%     DEM = GRIDobj(Z,cs)
%     DEM = GRIDobj(Z,R)
%     DEM = GRIDobj(X,Y,Z) 
%     DEM = GRIDobj('ESRIasciiGrid.txt')
%     DEM = GRIDobj('GeoTiff.tif')
%     DEM = GRIDobj();
%     DEM = GRIDobj([]);
%     DEM = GRIDobj(FLOWobj or GRIDobj or STREAMobj or PPS,class)
%     DEM = GRIDobj(FLOWobj or GRIDobj or STREAMobj or PPS, Z)
%
%
% Description
%
%     GRIDobj creates an instance of the grid class, which contains a
%     numerical, integer or logical matrix and information on
%     georeferencing. When a GRIDobj is created from a file, the number
%     format of the data in GRIDobj is either single or double. Unsigned
%     and signed integers are converted to single. For unsigned integers,
%     missing values are assumed to be denoted as intmax(class(input)). For
%     signed integers, missing values are assumed to be
%     intmin(class(input)). Please check, that missing values in your data
%     have been identified correctly before further analysis.
%
%     Note that while throughout this help text GRIDobj is associated with
%     gridded digital elevation models, instances of GRIDobj can contain
%     other gridded, single band, datasets such as flow accumulation grids, 
%     gradient grids etc.
%
%     DEM = GRIDobj(Z) creates a GRIDobj from the elevations stored in the 
%     matrix Z. The spatial resolution is 1 and the grid will be cell
%     referenced.
%
%     DEM = GRIDobj(Z,cs) creates a GRIDobj from the elevations stored in 
%     the matrix Z. cs is a positive scalar and is the spatial resolution. 
%
%     DEM = GRIDobj(Z,R) creates a GRIDobj from the elevations stored in 
%     the matrix Z. R is a MapCellsReference, MapPostingsReference,
%     GeographicCellsReference or GeoGeographicPostingsReference object.
%
%     DEM = GRIDobj(X,Y,Z) creates a GRIDobj from the coordinate matrices
%     or vectors X and Y and the matrix Z. The elements of Z refer to the
%     elevation of each pixel.
%
%     DEM = GRIDobj('ESRIasciiGrid.txt') creates a GRIDobj from an ESRI 
%     Ascii grid exported from other GI systems. 
%
%     DEM = GRIDobj('GeoTiff.tif') creates a GRIDobj from a Geotiff. Note
%     that reading image files may not reliably detect missing data.
%
%     DEM = GRIDobj(filename) tries to create a GRIDobj from other formats
%     supported by the Mapping Toolbox function readgeoraster.
%
%     DEM = GRIDobj() opens a dialog box to read either an ESRI Ascii Grid
%     or a Geotiff.
%
%     DEM = GRIDobj([]) creates an empty instance of GRIDobj
%
%     DEM = GRIDobj(FLOWobj or GRIDobj or STREAMobj,class) creates an
%     instance of GRIDobj with all common properties (e.g., spatial
%     referencing) inherited from another instance of a FLOWobj, GRIDobj 
%     or STREAMobj class. DEM.Z is set to all zeros where class can be
%     integer classes or double or single. By default, class is double.
%
%     DEM = GRIDobj(FLOWobj or GRIDobj or STREAMobj, Z) creates an
%     instance of GRIDobj with all common properties (e.g., spatial
%     referencing) inherited from another instance of a FLOWobj, GRIDobj 
%     or STREAMobj class. The second input argument Z is written to DEM.Z.
%
% Example 1: Load a DEM
%
%     DEM = GRIDobj('srtm_bigtujunga30m_utm11.tif');
%     % Display a hillshade of the DEM
%     imageschs(DEM)
%
% Example 2: Create a global grid in geographic coordinates
%
%     R = georefcells([-90 90],[-180 180],2,2);
%     R.GeographicCRS = parseCRS(4326);
%     G = GRIDobj(zeros(R.RasterSize),R);
%     G = egm96heights(G);
%     surf(G);
%     exaggerate(gca,0.1);
%     colormap(ttscm('roma'));
%     caxis([-100 100])
%     camlight; material dull
%
% Example 3: Create a new GRIDobj filled with ones
%
%     DEM = GRIDobj('srtm_bigtujunga30m_utm11.tif');
%     Z   = GRIDobj(DEM) + 1;
%
% See also: FLOWobj, STREAMobj, GRIDobj/info, readgeoraster.
%
% Author: Wolfgang Schwanghart (schwangh[at]uni-potsdam.de)
% Date: 19. March, 2025
   
    properties
        %Public properties
        
%Z matrix with elevation values
%    The Z property contains the elevation values in a 2D matrix.
%
%    See also GRIDobj
        Z         
        
%CELLSIZE cellsize of the grid (scalar)
%    The cellsize property specifies the spacing of the grid in x and y
%    directions. Note that TopoToolbox requires grids to have square cells,
%    e.g., dx and dy are the same.
%
%    See also GRIDobj       
        cellsize  
        
%WF 2-by-3 affine transformation matrix
%    The wf (world-file) property specifies a 2-by-3 affine transformation 
%    matrix as used by the mapping toolbox. 
%
%    See also GRIDobj, worldFileMatrix
        wf  
        
%SIZE size of the grid (two element vector)
%    The cellsize property is a two element vector that contains the number
%    of rows and columns of the Z matrix.
%
%    See also GRIDobj, size
        size 
        
%NAME optional name (string)
%    The name property allows to specify a name of the grid. By default and
%    if the constructor is called with a filename, the name property is set
%    to the name of the file.
%
%    See also GRIDobj
        name     
        
%ZUNIT unit of grid values (string)
%    The zunit is optional and is used to store the physical unit (e.g. m)
%    of an instance of GRIDobj. This property is currently not fully
%    supported and TopoToolbox functions usually assume that the unit is in
%    meters and equals the xyunit property.
%
%    See also GRIDobj
        zunit     
        
%XYUNIT unit of the coordinates (string)
%    The xyunit is optional and is used to store the physical unit (e.g. m)
%    of the coordinates. This property is currently not fully
%    supported and TopoToolbox functions usually assume that the unit is in
%    meters and equals the zunit property.
%
%    See also GRIDobj            
        xyunit    
        
%GEOREF additional information on spatial referencing (structure array)
%    The georef property stores an instance of a MapCellsReference, a
%    MapPostingsReference, GeographicCellsReference or
%    GeographicPostingsRefernce object if the Mapping Toolbox is available.
%    These objects contain a projcrs or geocrs object which stores the type
%    of coordinate reference system. This information is required if a
%    GRIDobj or any output shall be stored as georeferenced data. In
%    addition, the georef stores a structure array (GeoKeyDirTag), which is
%    only non-empty if the GRIDobj was created from a geotiff-file. It is
%    required to export a GRIDobj as geotiff (see GRIDobj2geotiff).
%
%    See also GRIDobj, geotiffinfo        
        georef    
        
    end
    
    methods

        %% The main constructor function starts here ---------------------
        function DEM = GRIDobj(varargin)
            
            % ............................................................
            % With no input functions, a dialog box will open to choose
            % a raster file to be read. 
            if numel(varargin) == 0
                DEM = GRIDobj(openRasterDialog);
                return
            end
            
            % ............................................................
            % With input arguments, there are several options
            if isnumeric(varargin{1})         

                % ........................................................
                %% Case 1: GRIDobj is created from a numeric array
                if nargin <= 2
                    % DEM = GRIDobj(Z) or DEM = GRIDobj(Z,cs)
                    % or DEM = GRIDobj([])

                    % An empty numeric array as first input returns an
                    % empty GRIDobj
                    if isempty(varargin{1})
                        return
                    end

                    % One numeric input sets the cellsize to 1.
                    if nargin < 2
                        cs = 1;
                    else
                        cs = varargin{2};
                    end

                    if isnumeric(cs)
                        % Check whether cellsize is a scalar and positive
                        validateattributes(cs,{'numeric'},...
                            {'scalar','positive'},'GRIDobj','cs',2)
                        % cs contains the cellsize
                        Z   = varargin{1};
                        siz = size(Z);
                        x   = linspace(cs/2,siz(2)*cs-cs/2,siz(2));
                        y   = linspace(cs/2,siz(1)*cs-cs/2,siz(1))';

                        [Z,R,wf] = createRasterFromMat(x,y,Z);
                        
                    else
                        % cs is a maprefpostings or georefpostings object
                        css = superclasses(class(cs));
                        if ismember("map.rasterref.internal.GeographicRasterReferenceAlias",css) || ...
                                ismember("map.rasterref.internal.MapRasterReferenceAlias",css)
                        else
                            error('Cannot handle second input variable.')
                        end

                        Z = varargin{1};
                        R = varargin{2};
                        wf = worldFileMatrix(R);                  

                        % check whether size of Z is same as in referencing
                        % object
                        tf = sizesMatch(R,Z);
                        assert(tf,"Array size of first argument and referencing matrix differs.")

                    end

                else

                    % DEM = GRIDobj(x,y,Z);
                    [Z,R,wf] = createRasterFromMat(varargin{:});
                end
                
            elseif ischar(varargin{1}) || isstring(varargin{1}) 

                % ........................................................
                %% Case two: Input one is text (either filename or folder)
                if isfolder(varargin{1}) || isempty(varargin{1})
                    DEM = GRIDobj(openRasterDialog(varargin{1}));
                    return 
                else
                    % Case 2a
                    % Text is filename (image)
                    [Z,R,wf] = createRasterFromFile(varargin{:});                             
                end

            elseif isa(varargin{1},'GRIDobj') || ...
                           isa(varargin{1},'FLOWobj') || ...
                           isa(varargin{1},'STREAMobj') || ...
                           isa(varargin{1},'PPS')
                % ........................................................
                %% Case three: Input one another TT object
                if isa(varargin{1},'PPS')
                    varargin{1} = varargin{1}.S;
                end

                if nargin == 1
                    cl = 'single';
                else
                    cl = varargin{2};
                end

                if ~(ischar(cl) || isstring(cl))
                    if ~isequal(varargin{1}.size,size(cl))
                        error('TopoToolbox:wrongInput',...
                            'Size of TopoToolbox object and input matrix does not match.')
                    end
                    Z = cl;
                elseif strcmp(cl,'logical')
                    Z = false(varargin{1}.size);
                else
                    Z = zeros(varargin{1}.size,cl);
                end
                R = varargin{1}.georef;
                wf = varargin{1}.wf;
                    
            end
            
            % ............................................................
            % Finally, construct the GRIDobj
            DEM.Z        = Z;
            DEM.size     = size(Z);
            DEM.cellsize = wf2cellsize(wf);
            DEM.wf       = wf;
            DEM.xyunit   = '';
            DEM.zunit    = '';
            DEM.name     = '';
            DEM.georef   = R;
            % DEM.georef.GeoKeyDirTag = GeoKeyDirTag;


        end

        % ................................................................
        % A number of basic functions follow that are used to test, access  
        % or change the properties of a GRIDobj

        function typename = underlyingType(A)
            %UNDERLYINGTYPE Determine the underlying data type of GRIDobj
            %
            % Syntax
            %
            %     typename = underlyingType(A)
            %
            typename = class(A.Z);
        end

        function tf = isUnderlyingType(A,typename)
            %ISUNDERLYINGTYPE Determine whether input GRIDobj has specified underlying data type
            %
            % Syntax
            %
            %     tf = isUnderlyingType(A,typename)
            %
            tf = strcmp(underlyingType(A),typename);
        end

        function mustBeUnderlyingType(A,typename)
            %MUSTBEUNDERLYINGTYPE Validate that GRIDobj has specified underlying data type
            %
            % Syntax
            %
            %     mustBeUnderlyingType(A,typename)
            %
            tf = isUnderlyingType(A,typename);
            if ~tf
                error("TopoToolbox:validation",...
                    append("Underlying GRIDobj data type is ",...
                    underlyingType(A), ...
                    " but must be ", string(typename)))
            end
        end

        function tf = isUnderlyingInteger(A)
            %ISUNDERLYINGINTEGER Determine if GRIDobj has underlying integer data type
            %
            % Syntax
            %
            %     isUnderlyingInteger(A)
            %
            tf = isinteger(A.Z);

        end

        function mustBeUnderlyingInteger(A)
            %MUSTBEUNDERLYINGINTEGER Validate that GRIDobj has underlying integer data type
            %
            % Syntax
            %
            %     mustBeUnderlyingInteger(A)
            %
            tf = isinteger(A.Z);
            if ~tf
                error("TopoToolbox:validation",...
                    "Underlying GRIDobj data type must be integer.")
            end
        end

        function tf = isUnderlyingNumeric(A)
            %ISUNDERLYINGINTEGER Determine if GRIDobj has underlying numeric data type
            %
            % Syntax
            %
            %     isUnderlyingNumeric(A)
            %
            tf = isnumeric(A.Z);

        end

        function mustBeUnderlyingNumeric(A)
            %MUSTBEUNDERLYINGNUMERIC Validate that GRIDobj has underlying numeric data type
            %
            % Syntax
            %
            %     mustBeUnderlyingNumeric(A)
            %
            tf = isnumeric(A.Z);
            if ~tf
                error("TopoToolbox:validation",...
                    "Underlying GRIDobj data type must be numeric (double or single).")
            end
        end


        %% Additional functions to add
        % hasReference Determines whether GRIDobj has a map or geo
        % reference
        % hasMissingValues
        % mustNotHaveMissingValues
        %

        
    end
end
    