% TopoToolbox
% Version 3.0  17-March-2025
%
% TopoToolbox provides a set of Matlab functions that support the analysis
% of relief and flow pathways in digital elevation models. The major 
% aim of TopoToolbox is to offer helpful analytical GIS utilities in a 
% non-GIS environment in order to support the simultaneous application
% of GIS-specific and other quantitative methods.
%
% If you have any questions or remarks, please contact the authors:
%
% Wolfgang Schwanghart
% w.schwanghart[at]fu-berlin.de
%
% Dirk Scherler
% scherler[at]gfz-potsdam.de
%
% William Kearney
% william.kearney[at]uni-potsdam.de
% 
% When you use TopoToolbox in your work, please reference one of these 
% publications:
% 
% Schwanghart, W., Scherler, D. (2014): TopoToolbox 2 – MATLAB-based 
% software for topographic analysis and modeling in Earth surface sciences. 
% Earth Surface Dynamics, 2, 1-7. [DOI: 10.5194/esurf-2-1-2014]
% 
% Schwanghart, W., Kuhn, N. J. (2010): TopoToolbox: a set of Matlab 
% functions for topographic analysis. Environmental Modelling & Software, 
% 25, 770-781. [DOI: 10.1016/j.envsoft.2009.12.002]
%
%
% Objects
%
%     GRIDobj         - object for gridded, geospatial data
%     FLOWobj         - object for flow direction
%     STREAMobj       - object for stream (channel) networks
%     DIVIDEobj       - object for drainage divide networks
%     SWATHobj        - object for swath profiles
%     PPS             - object for point patterns on stream networks
%
% Graphical user interfaces
%
%     flowpathapp     - Map, visualize and export flowpaths that start at manually set channelheads                     
%     slopeareatool   - Interactively create slope area plots and fit power laws                    
%     mappingapp      - Map points combining river planform and profile view
%
% GRIDobj methods
%
%     GRIDOBJ                 : Create instance of a GRIDobj
%     GRIDOBJ2ASCII           : write/export GRIDobj to ESRI ArcGIS ASCII file
%     GRIDOBJ2GEOTABLE        : Convert categorical GRIDobj to geotable (polygon) 
%     GRIDOBJ2GEOTIFF         : Exports an instance of GRIDobj to a geotiff file
%     GRIDOBJ2IM              : GRIDOBJ2IM Create image from GRIDobj
%     GRIDOBJ2MAT             : Convert GRIDobj to matrix and coordinate vectors
%     GRIDOBJ2PM              : Combine several GRIDobjs into a predictor matrix
%     GRIDOBJ2POLYGON         : Conversion from drainage basin grid to polygon or polyline
%     GRIDOBJ2RGB             : Convert GRIDobj to RGB image
%     ACV                     : Anisotropic coefficient of variation (ACV) 
%     AGGREGATE               : Resampling a GRIDobj using aggregation/binning
%     ARCSLOPE                : Slope from a digital elevation model sensu ArcGIS
%     ASPECT                  : Direction of the steepest slope
%     CASTSHADOW              : Cast shadow calculated from digital terrain
%     CELLAREA                : Calculate cell areas of a GRIDobj in geographic coordinate system
%     CLIP                    : clip a GRIDobj with a polygon or another GRIDobj
%     CONTOUR                 : Contour plot of an instance of GRIDobj
%     COORD2IND               : convert x and y coordinates to linear index
%     COORD2SUB               : convert x and y coordinates to subscripts into a GRIDobj
%     CREATEMASK              : Create a binary mask using polygon mapping
%     CROP                    : Crop an instance of GRIDobj with axis-aligned minimum bounding box
%     CURVATURE               : Curvature of a digital elevation model 
%     DEMAREA                 : Calculate the corrected surface area of a DEM
%     DEMPROFILE              : Get profile along path
%     DIFFUSION               : Solve the diffusion equation
%     DILATE                  : Morphological dilation
%     DIST2CURVE              : Labels pixels in a GRIDobj by their directed distance to a curved line
%     DIST2LINE               : labels pixels in a GRIDobj by their distance to a straight line
%     DISTANCE                : distance transform
%     ELEVATEMINIMA           : Elevate regional minima in a DEM to their lowest neighbor
%     ERODE                   : Morphological erosion
%     EVANSSLOPE              : Calculate surface slope using Evans method
%     EXCESSTOPOGRAPHY        : reconstruct surface with threshold-slope surface
%     FILLSINKS               : Fill/remove pits, sinks or topographic depressions
%     FILTER                  : 2D-filtering of DEMs with different kernels 
%     FIND                    : Find indices of nonzero elements in GRIDobj
%     FINDCOORD               : Find coordinates of nonzero elements in GRIDobj
%     GETCOORDINATES          : get coordinate vectors of an instance of GRIDobj
%     GETEXTENT               : return extent of a GRIDobj
%     GETOUTLINE              : Get outline of GRIDobj
%     GRADIENT8               : 8-connected neighborhood gradient of a digital elevation model
%     GRIDDEDCONTOUR          : plot contours on grid
%     HEXGRID                 : creates an array of haxagonal points
%     HILLSHADE               : Calculate hillshading from a digital elevation model
%     HISTOGRAM               : Plot frequency distribution of values in GRIDobj
%     HYDROGRAM               : Generate an hydrogram
%     HYPSCURVE               : plot hypsometric curve of a digital elevation model
%     IDENTIFYFLATS           : identify flat terrain in a digital elevation model
%     IMAGESC                 : Scale data in GRIDobj and display as image object
%     IMAGESCHS               : Plot hillshade image with overlay
%     IND2COORD               : convert linear index to x and y coordinates
%     INFO                    : Detailed information on GRIDobj instance
%     INPAINTNANS             : Interpolate or fill missing values in a grid (GRIDobj)
%     INTERP                  : Interpolate to query locations
%     INTERP2GRIDOBJ          : Interpolate scattered data to GRIDobj
%     INTERPWITHBARRIERS      : Laplace interplation with barriers
%     ISUNDERLYINGINTEGER     : Create instance of a GRIDobj
%     ISUNDERLYINGNUMERIC     : Create instance of a GRIDobj
%     ISUNDERLYINGTYPE        : Create instance of a GRIDobj
%     ISNAN                   : Returns array elements that are NaNs as logical grid
%     KSDENSITY               : Kernel density estimator for GRIDobj
%     LARGESTINSCRIBEDGRID    : Find and crop the largest grid with no nans
%     LINE2GRIDOBJ            : Convert line to a grid
%     LOCALTOPOGRAPHY         : Local topography
%     MAX                     : Maximum value in GRIDobj
%     MEASURE                 : Take interactive measurements along a polyline
%     MIN                     : Minimum value in GRIDobj
%     MINMAXNORM              : Min-max normalization with optional percent clipping
%     MPOWER                  : overloaded power for GRIDobj
%     MRDIVIDE                : overloaded right division for GRIDobj
%     MTIMES                  : overloaded multiplication for GRIDobj
%     MUSTBEUNDERLYINGINTEGER : Create instance of a GRIDobj
%     MUSTBEUNDERLYINGNUMERIC : Create instance of a GRIDobj
%     MUSTBEUNDERLYINGTYPE    : Create instance of a GRIDobj
%     NCOLS                   : Return the number of columns in a DEM
%     NROWS                   : Return the number of rows in a DEM
%     PAD                     : Add or remove a border of pixels around a GRIDobj
%     POLYGON2GRIDOBJ         : Convert polygon to a grid
%     POSTPROCFLATS           : Postprocess flat terrain for visualization purpose
%     PRCCLIP                 : Percentile clipping
%     PROJECT                 : Warps a GRIDobj to a different coordinate system
%     PROMINENCE              : Calculate the prominence of mountain peaks
%     RAND                    : Compute a GRIDobj with random, spatially uncorrelated numbers
%     RANDOMSAMPLE            : Uniform random sampling of a GRIDobj
%     RECLABEL                : Labels GRIDobj by rectangular fields
%     RECLASSIFY              : Generate univariate class intervals for an instance of GRIDobj
%     REPROJECT2UTM           : Reproject DEM with WGS84 coordinate system to UTM-WGS84 
%     RESAMPLE                : Change spatial resolution of a GRIDobj
%     ROUGHNESS               : Terrain ruggedness, position and roughness indices of DEMs
%     SHUFFLELABEL            : Shufflelabel randomly relabels a label matrix
%     SNAP2STREAM             : snap gauges or pour points to stream raster
%     SUB2COORD               : Convert subscripts to x and y coordinates
%     SURF                    : Surface plot for GRIDobj
%     TANAKACONTOUR           : Relief depiction using Tanaka contours
%     TOPOSHIELDING           : topographic shielding from cosmic rays
%     UNDERLYINGTYPE          : Create instance of a GRIDobj
%     VALIDATEALIGNMENT       : Checks validity that two GRIDobj are spatially aligned
%     ZSCORE                  : Standardized z-scores for GRIDobj
% 
% FLOWobj methods
% 
%     FLOWOBJ                 : Create flow direction object
%     FLOWOBJ2GRIDOBJ         : Create ESRI ArcGIS flow direction grid from FLOWobj
%     FLOWOBJ2M               : Convert instance of FLOWobj to flow direction matrix 
%     FLOWOBJ2CELL            : return cell array of FLOWobjs for individual drainage basins
%     CLIP                    : Clip FLOWobj
%     COORD2IND               : Convert linear indices to world coordinates
%     CROP                    : crop an instance of FLOWobj
%     DBASYMMETRY             : Drainage basin asymmetry
%     DBENTROPY               : Entropy of drainage basin delineation
%     DEPENDENCEMAP           : Delineate upslope area for specific locations in a DEM
%     DRAINAGEBASINS          : drainage basin delineation/catchments
%     DRAINAGEBASINSTATS      : Zonal statistics on drainage basins
%     FHAND                   : Fuzzy height above nearest drainage (HAND)
%     FHBR                    : Fuzzy Height Below Ridge (fHBR)
%     FIND                    : Find indices and values of edges in the flow direction graph
%     FLIPDIR                 : Flip direction of flow
%     FLOWACC                 : flow accumulation (upslope area, contributing area)
%     FLOWCONVERGENCE         : Compute flow convergence of a digital elevation model
%     FLOWDISTANCE            : Flow distance in upstream and downstream direction
%     FLOWDIVERGENCE          : Calculate the number of downstream neighbors
%     FLOWPATHEXTRACT         : Extract linear indices of a single flowpath in a DEM
%     FLOWTIME                : Flow time (and distance) in upstream direction
%     FLOWVEC                 : Velocity vectors from FLOWobj
%     GETOUTLETS              : Retrieve outlets of a flow network (FLOWobj)
%     GRADIENT                : Gradient along flow direction
%     IMPOSEMIN               : Minima imposition (carving) along drainage network
%     IND2COORD               : Convert linear index to x and y coordinates
%     INFLUENCEMAP            : Downslope area for specific locations in a digital elevation model
%     ISMULTI                 : Determine whether FD is multi (incl. Dinf) or single flow direction
%     MAPFROMNAL              : Map values from node-attribute list to nearest upstream grid
%     MEANFLOWDIST            : Average flow distance based on multiple flow directions
%     MELTONRUGGEDNESS        : Melton ruggedness
%     MULTI2SINGLE            : Converts multiple to single flow direction
%     MULTI_NORMALIZE         : Create flow direction object
%     PLOTDBFRINGE            : Plot semitransparent fringe around each drainage basin
%     PROPAGATEVALUESUPSTREAM : Propagates values upstream in a FLOWobj
%     QUANTCARVE              : Quantile carving
%     RANDOMIZE               : Randomize multiple flow directions
%     REMOVESMALLFRACTIONS    : Remove links with small fractions in FLOWobj
%     REWEIGHT                : Re-calculate flow weights in a multiple flow direction FLOWobj
%     SAVEOBJ                 : Create flow direction object
%     SLOPEAREATOOL           : Interactively create slope area plots and fit power laws
%     SLOPEPOSITION           : Slope position index (relative relief)
%     STREAMORDER             : Calculate stream order based on a FLOWobj and stream grid
%     TFACTOR                 : Transverse topographic symmetry (T-)factor
%     UPDATETOPOSORT          : Update topological sorting
%     UPSLOPESTATS            : Upslope statistics computed in flow directions
%     VALIDATEALIGNMENT       : Validates whether instances of FLOWobj and GRIDobj are spatially aligned
%     VERTDISTANCE2STREAM     : Vertical distance to streams (height above nearest drainage) 
% 
% STREAMobj methods
% 
%     STREAMOBJ           : Create stream object (STREAMobj)
%     STREAMOBJ2GRIDOBJ   : Convert STREAMobj to GRIDobj
%     STREAMOBJ2SWATHOBJ  : Create swath profile (SWATHobj) from stream network
%     STREAMOBJ2XY        : convert instance of STREAMobj to NaN-separated X and Y coordinates
%     STREAMOBJ2CELL      : convert instance of STREAMobj to cell array of stream objects
%     STREAMOBJ2GEOTABLE  : Convert STREAMobj to a geotable
%     STREAMOBJ2KML       : Convert STREAMobj to kml (Google Earth)
%     STREAMOBJ2LATLON    : convert instance of STREAMobj to NaN-separated geographic coordinates
%     STREAMOBJ2MAPSTRUCT : convert instance of STREAMobj to mapstruct
%     AGGREGATE           : Summarizing values within segments of the stream network
%     BIFURCATIONRATIO    : Calculate the bifurcation ratio of a STREAMobj
%     BINARIZE            : Make a stream network a strictly binary tree
%     CHIPLOT             : Chi analysis for bedrock river analysis
%     CHITRANSFORM        : Coordinate transformation using the integral approach
%     CLEAN               : Create stream object (STREAMobj)
%     CONNCOMPS           : Labels of connected components (individual trees) in a stream network
%     CRS                 : Constrained regularized smoothing of the channel length profile
%     CRSLIN              : constrained regularized smoothing of the channel length profile
%     CUMMAXUPSTREAM      : Cumulative maximum in upstream direction
%     CUMSUM              : Cumulative sum on stream network
%     CUMTRAPZ            : Cumulative trapezoidal numerical integration along a stream network
%     CURVATURE           : curvature or 2nd derivative of a STREAMobj
%     DENSIFY             : Increase number of vertices in stream network using splines
%     DIFF                : Differences between adjacent pixels in a stream network
%     DISTANCE            : Compute distances along the stream network
%     DRAINAGEDENSITY     : Drainage density of a stream network
%     EXTEND2DIVIDE       : Grow STREAMobj upstream to extend to the divide
%     EXTRACTCONNCOMPS    : interactive stream network selection
%     EZGETNAL            : Easy handling and retrieval of node-attribute lists
%     FASTSCAPE           : Simulate river incision using the stream power incision model
%     GETLOCATION         : Get locations along a stream network
%     GETNAL              : Get node-attribute list
%     GETVALUE            : Retrieve value from node-attribute list
%     GRADIENT            : Along-stream gradient
%     HILLSLOPEAREA       : Upslope hillslope area for each stream pixel 
%     IDENTIFYFLATS       : identify flat sections in a river profile
%     IMPOSEMIN           : minima imposition (carving) along stream network
%     INFO                : Meta information about STREAMobj
%     INPAINTNANS         : Inpaint missing values (nans) in a node attribute list
%     INTERP              : Interpolate data on STREAMobj (single river only)
%     INTERSECT           : intersect different instances of STREAMobj 
%     INTERSECTLOCS       : Derive locations where two STREAMobj start to have a common network
%     ISEMPTY             : Determine whether a STREAMobj is empty
%     ISEQUAL             : Determine whether two STREAMobjs are equal
%     ISNAL               : Test whether a vector is a node attribute list of a STREAMobj
%     ISSUBGRAPH          : Create stream object (STREAMobj)
%     ISTRUNK             : Determines whether STREAMobj consists of trunk streams
%     KLARGESTCONNCOMPS   : Keep k largest connected components in an instance of STREAMobj
%     KNICKPOINTFINDER    : Find knickpoints in river profiles
%     KSN                 : normalized steepness index
%     LABELREACH          : create node-attribute list with labelled reaches
%     LOESSKSN            : Loess-smoothed river steepness
%     LOWERENV            : Lower envelope of a channel length profile
%     MAPLATERAL          : Map values of regions adjacent to streams to stream network
%     MCHI                : Gradient of stream profile in chi space (M_chi = Ksn)
%     MEANUPSTREAM        : Mean (weighted) upstream  values
%     MINCOSTHYDROCON     : Minimum cost hydrological conditioning
%     MNOPTIM             : Bayesian optimization of the mn ratio
%     MNOPTIMVAR          : Optimize the mn ratio using minimum variance method
%     MODIFY              : Modify instance of STREAMobj to meet user-defined criteria
%     NAL2NAL             : Map one node-attribute list to another 
%     NETDIST             : Distance transform on a stream network
%     NETWORKSEGMENT      : Identify river segments and compute segment geometry
%     ORIENTATION         : Stream orientation
%     PLOT                : Plot instance of STREAMobj
%     PLOT3               : 3D-line plot of a STREAMobj
%     PLOT3D              : 3D plot of a stream network
%     PLOTC               : plot a colored stream network
%     PLOTCATEGORICAL     : Plot categorical variable along a single river
%     PLOTDZ              : plot upstream distance version elevation of a stream network
%     PLOTDZSHADED        : plot upstream distance version elevation of a stream network
%     PLOTSEGMENTGEOMETRY : Plot segment geometry obtained from the function networksegment
%     PLOTSTREAMORDER     : Calculate stream order from STREAMobj
%     QUANTCARVE          : Quantile carving
%     RANDLOCS            : Random locations along the stream network
%     REMOVEEDGEEFFECTS   : Remove potential edge effects due to incomplete basins
%     REMOVESHORTSTREAMS  : Remove first order streams with a length less than specified
%     RMEDGE              : Create stream object (STREAMobj)
%     RMNODE              : Create stream object (STREAMobj)
%     SHAREDSTREAMPOWER   :  Simulation of the shared stream-power model
%     SIDEBRANCHING       : side branching classification according to Tokunaga (1978)
%     SINUOSITY           : Sinuosity coefficient 
%     SLOPEAREA           : slope-area relation of a stream network
%     SMOOTH              : smoothing of node-attribute lists
%     SNAP2STREAM         : Snap locations to nearest stream location
%     SPLIT               : Split drainage network at predefined locations
%     SPLITBYATTRIBUTE    : Create a cell array of STREAMobjs using an attribute
%     STACKEDPLOTDZ       : plot several stacked variables along the stream networks
%     STREAMORDER         : Calculate stream order from STREAMobj
%     STREAMPOI           : Points of interest on the stream network
%     STREAMPROJ          : project stream elevations based on slope-area scaling
%     SUBGRAPH            : Create stream object (STREAMobj)
%     TRANSFORMCOORDS     : transform coordinates of stream network
%     TRIBDIR             : direction of inflow of tributary
%     TRUNCATE            : Shrink river network by removing links at channelheads or outlets
%     TRUNK               : extract trunk stream (longest stream) 
%     UNION               : merge different instances of STREAMobj into a new instance
%     VALIDATEALIGNMENT   : is an instance of STREAMobj is spatially aligned with another object of TopoToolbox
%     WIDENSTREAM         : level elevations adjacent to the stream network
%     WMPLOT              : plot stream network in the webmap browser
%     ZEROBASELEVEL       : Set base level of stream elevation to zero
%
% DIVIDEobj methods
%
%     DIVIDEOBJ           : Create divide object (DIVIDEobj)
%     DIVIDEOBJ2MAPSTRUCT : obtain divide properties from GRIDobj
%     ASYMMETRY           : directional asymmetry of divide segments
%     CLEANEDGES          : Delete divides on the edges of DEM
%     COORD2IND           : convert x and y coordinates to linear index
%     DIST2NODE           : network distance to nodes
%     DIVDIST             : DIVDIST   Assign distance to divide segments
%     DIVNET              : Create divide object (DIVIDEobj)
%     DIVORDER            : Assign order to divide segments
%     GETVALUE            : get grid values adjacent to divides
%     IND2COORD           : convert linear index to x and y coordinates
%     JCTANGLE            : angles between divide segments at junctions
%     JCTCON              : compute junction connectivity
%     PLOT                : plot the divide network 
%     PLOTC               : Create colored plot of drainage divide network
%     REMOVESHORTDIVIDES  : Remove short first-order divides
%     SHRINK              : Shrink divide network
%     SORT                : Sort divide segments by network structure.
% 
% SWATHobj methods
% 
%     SWATHOBJ         : Create swath profile object (SWATHobj)
%     SWATHOBJ2GRIDOBJ : Create a GRIDobj with swath-specific information
%     SWATHOBJ2GDS     : Create a geographic data structure from a SWATHobj
%     SWATHOBJ2TABLE   : Convert SWATHobj to table
%     CONVERT2LATLON   : converts spatial fields in SWATHobj to lat,lon
%     GETOUTLINE       : Get outline of swath
%     GETTRACE         : Get trace of swath
%     MAPSWATH         : obtains Z values along a SWATHobj from an arbitrary GRIDobj
%     PLOT             : Plot instance of SWATHobj
%     PLOTDZ           : Creates distance-elevation plot of a SWATHobj
%     PLOTDZM          : create color-coded distance-elevation plot from SWATHobj and GRIDobj
%     PROFILES         : Calculate profiles from a SWATHobj
%     STAT             : Calculate statistics for swath profile object (SWATHobj)
%     SWATH2LATLON     : Convert spatial fields in SWATHobj to geographic coordinates
%     TIDY             : Remove overlapping points from SWATHobj
%
% PPS methods
%
%     KFUN                      : K-function of a point pattern on a stream network
%     PPS                       : Point patterns on stream networks
%     AGGREGATE                 : Aggregate points in PPS to new point pattern
%     AS                        : Convert PPS object into various data formats 
%     BAYESLOGLINEAR            : Bayesian analysis of a loglinear point process model 
%     CDFTEST                   : Kolmogorov-Smirnov test based on the CDF of a covariate
%     CLUSTER                   : Hierarchical clustering of points in PPS
%     CONNECTIVITY              : River network connectivity according to Flecker et al. (2022)
%     CONVHULL                  : Convex hull around points in PPS
%     CVLOGLINEAR               : Cross-validate a loglinear point process model
%     DENSITY                   : Nonparametric density estimation on network
%     DIAMETER                  : Returns the maximum possible distance in a stream network
%     ECDF                      : Empirical cumulative distribution function of a covariate 
%     EXTENDEDNETWORK           : Extend network to account for duplicate points
%     EXTRACTVALUESAROUNDPOINTS : Extract values around points 
%     FITLOGLINEAR              : fit loglinear model to point pattern
%     GENERATEPOINTS            : Generate non-random points on stream network
%     GETMARKS                  : Extract point marks
%     GFUN                      : G-function (nearest inter-point distance distribution)
%     HASDUPLICATES             : Determines whether there are duplicate points
%     HISTOGRAM                 : Histogram of point pattern on stream network
%     IDW                       : Inverse distance weighted interpolation on stream networks
%     INTENSITY                 : calculate intensity (density) of points on the stream network
%     MNOPTIMKP                 : Find optimal mn ratio based on knickpoint locations
%     MODIFY                    : modify instance of PPS to meet user-defined criteria
%     NETDIST                   : Shortest network distance
%     NPOINTS                   : Number of points in the point pattern
%     PLOT                      : Plot instance of PPS
%     PLOTC                     : Plot a colored stream network and points
%     PLOTDZ                    : plot upstream distance version elevation or covariate of a PPS
%     PLOTEFFECTS               : Plot of slices through a loglinear point process model
%     PLOTPOINTS                : plot points of PPS
%     POINTDISTANCES            : Inter-point distance calculated on stream network
%     POINTS                    : Extract a list of points from the point pattern
%     QUADRATCOUNT              : Quadrat count and chi2 test
%     RANDOM                    : Random realisation of a (inhomogeneous) point process
%     REMOVEDUPLICATES          : Remove duplicate points
%     REMOVEPOINTS              : Remove points in point pattern
%     RHOHAT                    : nonparametric estimation of point pattern dependence on covariate
%     ROC                       : Receiver-operating characteristics of point pattern
%     SHAPEWRITE                : Write point pattern to shapefile
%     SIMULATE                  : Simulate point pattern using random thinning
%     TLENGTH                   : Total length of the stream network
%     VORONOI                   : Nearest neighbor search on a stream network
%     WMPLOT                    : Plot instance of PPS in webmap browswer
%
% Other tools (utitilies)
%
%     compilemexfiles - compile mex-functions that come with TopoToolbox 2
%     coord2ind       - convert xy coordinates to linear index
%     exaggerate      - elevation exaggeration in a 3D surface plot
%     getdistance     - cumulative distance along path defined by vertice coordinates
%     getextent       - get current axis extent
%     interpline      - distribute vertices evenly along line with irregularly spaced vertices
%     ixneighbors     - neighbor indexing in a matrix
%     label2poly      - plot region outlines with polyline
%     landcolor       - colormap for the display of DEMs
%     setextent       - set current axis extent    
%     showmethods     - displays class method names and H1 lines in the command line
%     egm96heights    - read and resample EGM96 geoid heights
%     dpsimplify      - Douglas-Peucker line simplification
%     zonalstats      - Zonal statistics
%
%   ---------------------------------------------------------------------
%     TopoToolbox is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.

