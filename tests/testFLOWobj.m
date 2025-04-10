classdef testFLOWobj < matlab.unittest.TestCase
%TESTREADFLOWobj Tests FLOWobj functions
   
    properties      
        url = 'https://raw.githubusercontent.com/TopoToolbox/DEMs/master/';
        currentFolder = pwd
        tempFolder = fullfile(tempdir,'tt3_testdir')
    end

    properties(ClassSetupParameter)
        graphics = {true};
    end

    properties (TestParameter)
        files = {'kedarnath','kunashiri','perfectworld','taalvolcano','tibet'};
    end

    methods (TestClassSetup)
        function readFiles(testCase, graphics)

            % Create a folder in the temporary directory
            if ~exist(testCase.tempFolder,"file")
                mkdir(testCase.tempFolder)
            end
            
            % add path with tests to path
            p = mfilename('fullpath');
            [p,~] = fileparts(p);
            addpath(genpath(p))

            testCase.currentFolder = cd(testCase.tempFolder);
            % Now we should be in the test folder

            
            % Check whether the test files are already downloaded
            for r = 1:numel(testCase.files)
                % provide absolute paths
                fn = [testCase.files{r} '.tif'];
                if ~(exist(fullfile(testCase.tempFolder,fn),'file') == 2)
                    websave(fullfile(testCase.tempFolder,fn),fullfile(testCase.url,fn));
                end
            end 
        end
    end

    methods(TestClassTeardown)
        function goBack(testCase)
            cd(testCase.currentFolder)
        end
    end

    % Tests start here ---------------------------------------------------
    methods (Test, ParameterCombination = 'exhaustive')
        % Test methods

        function create_FLOWobj(testCase, files, graphics)
				
            % Read example DEM
            fn  = fullfile(testCase.tempFolder,[files '.tif']);
            DEM = GRIDobj(fn);
            
            FD  = FLOWobj(DEM,'multi');
            A   = flowacc(FD);
            if graphics
                figure; imagesc(log(A)); pause(2); close
            end
            verifyInstanceOf(testCase,FD,'FLOWobj')
        end

        
    end
end
