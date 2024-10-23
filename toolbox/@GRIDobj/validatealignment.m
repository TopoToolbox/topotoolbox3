function tf = validatealignment(GRID1,GRID2)

%VALIDATEALIGNMENT Checks validity that two GRIDobj are spatially aligned
%
% Syntax
%
%     tf = validatealignment(GRID1,GRID2)
%     validatealignment(GRID1,GRID2)
%
% Description
%
%     Returns true if instances of GRIDobj are spatially aligned. When the
%     function returns false and is called without output argument, the
%     function returns an error message.
%
%     Sometimes, validatealignment will return false (or an error) although
%     two GRIDobj should be perfectly aligned, e.g. because they were both
%     exported with the same geometry using GIS. However, slight
%     differences in georeferencing may still occur. In this case, consider
%     resampling one GRIDobj to the extent and location of the other
%     GRIDobj using the function GRIDobj/resample.
%
% Input arguments
%
%     GRID1 instance of GRIDobj
%     GRID2 instance of GRIDobj or matrix
%
% Output arguments
% 
%     tf    true or false
%
% See also: GRIDobj, GRIDobj/isProjected, GRIDobj/isGeographic,
%           GRIDobj/resample
%   
% Author:  Wolfgang Schwanghart (schwangh[at]uni-potsdam.de)
% Date: 18. October, 2024 

% check if geometric properties of a FLOWobj and GRIDobj instance are equal
if isa(GRID2,'GRIDobj')
    TF = isequal(GRID1.size,GRID2.size) && isequal(GRID1.wf,GRID2.wf);
else
    TF = isequal(GRID1.size,size(GRID2));
end

if nargout == 1
    tf = TF;
else
    if ~TF
        if isa(GRID2,'GRIDobj')
            error('TopoToolbox:incorrectinput',...
                ['The two GRIDobj instances do not align each other. Make sure that \n' ...
                'both instances have the same spatial reference. Both variables \n' ...
                'are deemed to have the same reference if their properties ''size'' \n' ...
                'and ''wf'' are both equal.']);
        else
            error('TopoToolbox:incorrectinput',...
                ['GRIDobj and input matrix do not align each other. Make sure that \n' ...
                'both instances have the same spatial reference. Both variables \n' ...
                'are deemed to have the same reference if the GRIDobj''s property \n' ...
                '''size'' and size(A) is equal.']);
        end
    end
end
