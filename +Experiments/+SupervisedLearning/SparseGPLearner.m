classdef SparseGPLearner < Experiments.SupervisedLearning.SupervisedLearner
    
    properties
    end
    
    methods
        function obj = SparseGPLearner()
            obj = obj@Experiments.SupervisedLearning.SupervisedLearner('sparseGP');
        end
                
        function [] = setupFunctionApproximator(obj, trial)
        
            initializer = @Kernels.GPs.GaussianProcess.CreateSquaredExponentialGP;
            GPcomposite = Kernels.GPs.CompositeOutputModel(dataManager, 'outputs', current_data_pipe{1}, initializer);
            
        end
        
        function [] = setupLearningAlgorithm(obj, trial)
            learnerInitializer = @Kernels.Learner.GPHyperParameterLearnerTestSetLikelihood.CreateWithStandardReferenceSet;
            GPcompositeLearner = Kernels.GPs.CompositeOutputModelLearner(dataManager, GPcomposite, learnerInitializer);
        
            
        end
        
        
        
    end
    
end


