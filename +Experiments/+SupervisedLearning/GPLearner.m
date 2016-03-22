classdef GPLearner < Experiments.SupervisedLearning.SupervisedLearner
    
    properties
    end
    
    methods
        function obj = GPLearner()
            obj = obj@Experiments.SupervisedLearning.SupervisedLearner('sparseGP');
        end
        
         function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.SupervisedLearning.SupervisedLearner(trial);
                        
            trial.setprop('kernel', @Kernels.GPs.GaussianProcess.CreateSquaredExponentialGP);
            
            trial.setprop('functionApproximator');
            
            trial.setprop('learningAlgorithm', @Kernels.Learner.GPHyperParameterLearnerTestSetLikelihood.CreateWithStandardReferenceSet);            
            
        end
                
        function [] = setupFunctionApproximator(obj, trial)
                    
            trial.functionApproximator = Kernels.GPs.CompositeOutputModel(trial.dataManager, trial.processedOutputs, trial.processedInputs, trial.kernel);
            
        end
        
        function [] = setupLearningAlgorithm(obj, trial)
            trial.learningAlgorithm = Kernels.GPs.CompositeOutputModelLearner(trial.dataManager, trial.functionApproximator, trial.learningAlgorithm);                    
        end
        
                
    end
    
end


