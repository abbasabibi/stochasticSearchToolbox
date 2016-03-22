classdef testKernelReferenceSetLearner < matlab.unittest.TestCase
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
            dm.addDataEntry('weights', 1);
            
            dm.finalizeDataManager();

            obj.dataManager = dm;
        end
    end
    methods(Test)
        function testRefSet(obj)
            kernel= Kernels.ExponentialQuadraticKernel(obj.dataManager, 2,'sqexp');
            krs = Kernels.KernelReferenceSet(obj.dataManager, kernel, 'states');
            krsl = Kernels.Learner.RandomKernelReferenceSetLearner(obj.dataManager, krs);
            
            nsamples = 40;
            dimstates = 2;
            newData = obj.dataManager.getDataObject(nsamples);
            states = randn(nsamples,dimstates);
            newData.setDataEntry('states', states);
            weights = rand(nsamples,1);
            newData.setDataEntry('weights', weights);
            
            % test without weights
            krsl.callDataFunction('setReferenceSet', newData );
            
            obj.verifyEqual(sortrows(krs.getReferenceSet), sortrows(states));
            

            % test with weights
            minRelWeight= 0.5;
            krsl.minRelWeight = minRelWeight; %extreme value for testing
            krsl.setWeightName('weights');
            
            krsl.callDataFunction('setReferenceSet', newData );
            
            obj.verifyEqual(sortrows(krs.getReferenceSet), sortrows(states(weights > minRelWeight*max(weights),:) ));
        end
        
    end
end

