classdef testFlowAlgebra < matlab.perftest.TestCase
    properties
        dem
        fd
        s
    end

    methods (TestClassSetup)
        % Shared setup for the entire test class
        function generate_data(testCase)
            % Seed the random number generator
            rng(5526579, 'twister');

            testCase.dem = GRIDobj(rand(103, 217));
            testCase.fd = FLOWobj(testCase.dem);
        end
    end

    methods (Test)
        function flowacc_weights(testCase)
            W  = ones(testCase.dem.size);
            A0 = flowacc(testCase.fd);
            A1 = flowacc(testCase.fd, W);
            testCase.verifyEqual(A0.Z, A1.Z);
        end

        function flowacc_runoff_ratio(testCase)
            W  = ones(testCase.dem.size);
            R  = ones(testCase.dem.size);
            A0 = flowacc(testCase.fd);
            A1 = flowacc(testCase.fd, W, R);
            testCase.verifyEqual(A0.Z, A1.Z);
        end

        function flowacc_libtt(testCase)
            A0 = flowacc(testCase.fd, uselibtt=false);
            A1 = flowacc(testCase.fd, uselibtt=true);

            testCase.verifyEqual(A1.Z, A0.Z);
        end

        function flowacc_libtt_runoffratio(testCase)
            W = GRIDobj(testCase.dem);
            W.Z = ones(testCase.dem.size);
            A0 = flowacc(testCase.fd, W, 2.5, uselibtt=false);
            A1 = flowacc(testCase.fd, W, 2.5, uselibtt=true);

            testCase.verifyEqual(A1.Z, A0.Z, RelTol=1e-5);
        end

        function dependencemap(testCase)
            L = GRIDobj(testCase.dem);
            L.Z = false(testCase.dem.size);

            [~,i] = max(testCase.dem);
            L.Z(i) = true;
            ix = find(L.Z);
            [x, y] = ind2coord(testCase.fd, ix);

            I0 = dependencemap(testCase.fd, L);
            I1 = dependencemap(testCase.fd, ix);
            I2 = dependencemap(testCase.fd, x, y);
            
            testCase.verifyEqual(I0.Z, I1.Z);
            testCase.verifyEqual(I0.Z, I2.Z);
        end

        function dependencemap_libtt(testCase)
            L = GRIDobj(testCase.dem);
            L.Z = false(testCase.dem.size);
            L.Z(10:30, 10:30) = true;

            I0 = dependencemap(testCase.fd, L, uselibtt=false);
            I1 = dependencemap(testCase.fd, L, uselibtt=true);
            testCase.verifyEqual(I0.Z, I1.Z);
        end
    end
end