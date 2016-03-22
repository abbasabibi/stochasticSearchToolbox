classdef testFourierProjection < matlab.unittest.TestCase
    %TESTFOURIERPROJECTION test class for the random fourier
    %projection of kernels
    
    properties
        dataManager
    end
    
    methods(TestMethodSetup)
        function initializeRNG(~)
            
            rng(3);

        end
        
        function initDataManager(obj)
            dm = Data.DataManager('steps');
            dm.addDataEntry('states', 2);
            dm.finalizeDataManager();
            
            obj.dataManager = dm;
        end
    end
    methods(Test)
        function testExponentialQuadratic(obj)


            states = randn(100,2);
            kernel = Kernels.ExponentialQuadraticKernel(obj.dataManager, 2,'expquad');
            
            
            g = kernel.getGramMatrix(states, states);
            
            randStream = RandStream('mt19937ar','Seed',101);
            nprojections = 80;
            rp = kernel.getFourierProjection(nprojections, randStream, states);
            b= rand(nprojections,1)*2*pi;
            phi = sqrt(2/nprojections)*cos(bsxfun(@plus, rp, b'));
            
            obj.verifyLessThanOrEqual(median(median( abs(g-phi*phi'))), 0.1);
            
        end
        
        function testExponentialQuadraticBandwidths(obj)


            states = randn(100,2);
            kernel = Kernels.ExponentialQuadraticKernel(obj.dataManager, 2,'expquad');
            
            kernel.bandWidth = [0.5, 2];
            
            g = kernel.getGramMatrix(states, states);
            

            randStream = RandStream('mt19937ar','Seed',101);
            nprojections = 80;
            rp = kernel.getFourierProjection(nprojections, randStream, states);
            b= rand(nprojections,1)*2*pi;
            phi = sqrt(2/nprojections)*cos(bsxfun(@plus, rp, b'));
            
            obj.verifyLessThanOrEqual(median(median( abs(g-phi*phi'))), 0.1);            
        end
        
        function testPeriodic(obj)
            
            states = randn(100,2);
            kernel = Kernels.PeriodicKernel(obj.dataManager, 2,'periodic',2*pi);
            
            
            g = kernel.getGramMatrix(states, states);
            
            randStream = RandStream('mt19937ar','Seed',101);
            nprojections = 80;
            rp = kernel.getFourierProjection(nprojections, randStream, states);
            b= rand(nprojections,1)*2*pi;
            phi = sqrt(2/nprojections)*cos(bsxfun(@plus, rp, b'));
            
            obj.verifyLessThanOrEqual(median(median( abs(g-phi*phi'))), 0.1);            
        end
        
        function testProduct(obj)
            states = randn(100,1);
            states = sort(states);
            kernel1 = Kernels.PeriodicKernel(obj.dataManager, 1,'periodic',2*pi);
            kernel2 = Kernels.ExponentialQuadraticKernel(obj.dataManager, 1,'expquad');
            
            kernel = Kernels.ProductKernel(obj.dataManager, 1, {kernel1, kernel2}, {1, 1}, 'product' );
            

            g = kernel.getGramMatrix(states, states);
            
            randStream = RandStream('mt19937ar','Seed',101);
            nprojections =80;
            rp = kernel.getFourierProjection(nprojections, randStream, states);
            b= rand(nprojections,1)*2*pi;
            phi = sqrt(2/nprojections)*cos(bsxfun(@plus, rp, b'));
            
            obj.verifyLessThanOrEqual(median(median( abs(g-phi*phi'))), 0.1);  
        end
        
        function testProductIndices(obj)
            states = randn(100,2);
            states = sort(states);
            kernel1 = Kernels.PeriodicKernel(obj.dataManager, 1,'periodic',2*pi);
            kernel2 = Kernels.ExponentialQuadraticKernel(obj.dataManager, 1,'expquad');
            
            kernel = Kernels.ProductKernel(obj.dataManager, 1, {kernel1, kernel2}, {1, 2}, 'product' );
            

            g = kernel.getGramMatrix(states, states);
            
            randStream = RandStream('mt19937ar','Seed',101);
            nprojections =80;
            rp = kernel.getFourierProjection(nprojections, randStream, states);
            b= rand(nprojections,1)*2*pi;
            phi = sqrt(2/nprojections)*cos(bsxfun(@plus, rp, b'));
            
            obj.verifyLessThanOrEqual(median(median( abs(g-phi*phi'))), 0.1);  
        end
    end
end

