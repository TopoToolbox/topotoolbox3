function publishtthelp2html

%PUBLISHTTHELP2HTML Publish TopoToolbox mlx help files to html
%
% Syntax
%
%     publishtthelp2html
%
% Description
%
%     HTML files for the documentation of TopoToolbox are published from
%     mlx-files that reside in the mlxfiles-directory. This function
%     publishes and overwrites all HTML-files.
%
% See also: publish
%
% Author: Wolfgang Schwanghart (w.schwanghart[at]geo.uni-potsdam.de)
% Date: 8. November, 2017

% determine the location of this function
fileloc = which('publishtthelp2html.m');
docdir = fileparts(fileloc);

% list all mlx files
files = dir(fullfile(docdir,'mlxfiles/*.mlx'));

[~,~] = mkdir(fullfile(docdir,"html"));

% h = waitbar(0,'Please wait');

% and publish them
for r = 1:numel(files)
    disp(['Exporting ' files(r).name]);
    [~,name,~] = fileparts(files(r).name);
    export(fullfile(docdir,'mlxfiles',files(r).name), ...
        fullfile(docdir,'html',name), ...
        Format="html", Run=true);
end

% Copy the helptoc.xml file
copyfile(fullfile(docdir,"helptoc.xml"),fullfile(docdir,"html"));

% Build the search database for the documentation files
builddocsearchdb(fullfile(docdir,'html'));