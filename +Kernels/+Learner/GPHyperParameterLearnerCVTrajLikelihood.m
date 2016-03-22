classdef GPHyperParameterLearnerCVTrajLikelihood < Kernels.Learner.GPHyperParameterLearnerLOOCVLikelihood
% leave-one-out CV for whole trajectories
    
    
    methods (Static)
        function [kernelLearner] = CreateFromTrial(trial, gpName)
            kernelLearner = Kernels.Learner.GPHyperParameterLearnerLOOCVLikelihood(trial.dataManager, trial.(gpName));
        end
        
        function [kernelLearner] = CreateWithStandardReferenceSet(dataManager, GP)
            referenceSetLearner = Kernels.Learner.RandomKernelReferenceSetLearner(dataManager, GP);
            kernelLearner = Kernels.Learner.GPHyperParameterLearnerCVTrajLikelihood(dataManager, GP, referenceSetLearner);
            kernelLearner.HyperParametersOptimizer = 'FMINUNC';
        end
    end
    
    
    methods
        function obj = GPHyperParameterLearnerCVTrajLikelihood(dataManager, gp, gpReferenceSetLearner)
            obj = obj@Kernels.Learner.GPHyperParameterLearnerLOOCVLikelihood(dataManager, gp, gpReferenceSetLearner);
            
        end
        
        function [] = processTrainingData(obj, data)
            %todo - fold per training TRAJECTORY
            obj.processTrainingData@Kernels.Learner.GPHyperParameterLearner(data);
            
            n_samples_per_episode = cat(1, data.getDataStructureForLayer(2).numElements );
            n_episodes = data.getDataStructure.numElements;
            episode_per_sample = cell2mat(arrayfun(@(n,i) repmat(i,n,1), n_samples_per_episode, (1:n_episodes)', 'UniformOutput', false));
            
            episode_per_sample_reference = episode_per_sample(obj.gpReferenceSetLearner.kernelReferenceSet.getReferenceSetIndices);
            validationSets = arrayfun(@(i) find(episode_per_sample_reference == i),      1:n_episodes, 'UniformOutput', false);
            
            
            
            %startval = cumsum([0, n_samples_per_episode(1:end-1)'])+1;
            %endval   = cumsum(n_samples_per_episode');
            

            %validationSets = arrayfun(@(s, e) s:e, startval, endval, 'UniformOutput', false);
            obj.validationSetIndices = validationSets;
        end
        

        
                        
    end
    
end

