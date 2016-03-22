classdef testKernelGradients < matlab.unittest.TestCase
    %TESTKERNELGRADIENTS Summary of this class goes here
    %   Detailed explanation goes here
    
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
        function testSqexp(obj)
            kernel = Kernels.ExponentialQuadraticKernel(obj.dataManager, 2,'sqexp');
            states = randn(100,2);
            
            kernel.setHyperParameters(rand(2,1));
            gana = kernel.getKernelDerivParam(states);
            gfd =  obj.FDgradient(kernel, states);
            
            obj.verifyEqual(gana, gfd, 'AbsTol',1e-3);
        end
        
        function testLin(obj)
            kernel = Kernels.LinearKernel(obj.dataManager, 2,'lin');
            states = randn(100,2);
            
            kernel.setHyperParameters(rand(2,1));
            gana = kernel.getKernelDerivParam(states);
            gfd =  obj.FDgradient(kernel, states);
            
            obj.verifyEqual(gana, gfd, 'AbsTol',1e-3);
        end
        function testRatQuat(obj)
            kernel = Kernels.LinearKernel(obj.dataManager, 2,'ratquat');
            states = randn(100,2);
            
            kernel.setHyperParameters(rand(2,1));
            gana = kernel.getKernelDerivParam(states);
            gfd =  obj.FDgradient(kernel, states);
            
            obj.verifyEqual(gana, gfd, 'AbsTol',1e-3);
        end    
        
        function testProduct(obj)
            kernel1 = Kernels.PeriodicKernel(obj.dataManager, 2,'periodic', 2*pi);
            kernel2 = Kernels.ExponentialQuadraticKernel(obj.dataManager, 2,'sqexp');
            kernel = Kernels.ProductKernel(obj.dataManager, 3, {kernel2, kernel1}, {[1,2],[2,3]}, 'product');
            states = randn(100,3);
            
            kernel.setHyperParameters(rand(4,1));
            gana = kernel.getKernelDerivParam(states);
            gfd =  obj.FDgradient(kernel, states);
            
            obj.verifyEqual(gana, gfd, 'AbsTol',1e-3);
        end  
        
        function testPeriodic(obj)
            kernel = Kernels.PeriodicKernel(obj.dataManager, 2,'periodic', 2*pi);
            states = randn(100,2);
            
            kernel.setHyperParameters(rand(2,1));
            gana = kernel.getKernelDerivParam(states);
            gfd =  obj.FDgradient(kernel, states);
            
            obj.verifyEqual(gana, gfd, 'AbsTol',1e-3);
        end
        
        function testSquared(obj)
            kernel1 = Kernels.PeriodicKernel(obj.dataManager, 2,'periodic', 2*pi);
            kernel = Kernels.SquaredKernel(obj.dataManager, kernel1, 'squared');
            states = randn(100,2);
            
            kernel.setHyperParameters(rand(2,1));
            gana = kernel.getKernelDerivParam(states);
            gfd =  obj.FDgradient(kernel, states);
            
            obj.verifyEqual(gana, gfd, 'AbsTol',1e-3);
        end
        
        function testSum(obj)
            kernel1 = Kernels.PeriodicKernel(obj.dataManager, 2,'periodic', 2*pi);
            kernel2 = Kernels.ExponentialQuadraticKernel(obj.dataManager, 2,'sqexp');
            kernel = Kernels.SumKernel(obj.dataManager, 3, {kernel2, kernel1}, {[1,2],[2,3]}, 'sum');
            states = randn(100,3);
            
            kernel.setHyperParameters(rand(4,1));
            gana = kernel.getKernelDerivParam(states);
            gfd =  obj.FDgradient(kernel, states);
            
            obj.verifyEqual(gana, gfd, 'AbsTol',1e-3);
        end
        

    end
    
    methods
        function g = FDgradient(obj, kernel, data)
            params = kernel.getHyperParameters;
            eps = 1e-6;
            g = zeros(size(data, 1), size(data, 1), kernel.getNumHyperParameters());
            
            for i = 1:numel(params)
                
                kernel.setHyperParameters(params(:) - (1:numel(params)==i)'*eps);
                gn = kernel.getGramMatrix(data,data);
                
                kernel.setHyperParameters(params(:) + (1:numel(params)==i)'*eps);
                gp = kernel.getGramMatrix(data,data);
                
                g(:,:,i) = (gp-gn)/(2*eps);
            end
            
            kernel.setHyperParameters(params);
            
        end
    end
end

