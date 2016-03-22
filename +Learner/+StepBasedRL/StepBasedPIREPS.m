classdef StepBasedPIREPS < Learner.StepBasedRL.StepBasedFromEpisodicLearner
    
    properties
        dynamicalSystem
    end

     methods (Static)
        function [learner] =  CreateFromTrial(trial)
            %trial.transitionFunction.enableTransitionProbabilities(true);
            if (trial.isProperty('stateFeatures') && ~isempty( trial.stateFeatures))
                learner = Learner.StepBasedRL.StepBasedPIREPS(trial.dataManager, trial.transitionFunction, trial.policyLearner, trial.actionPolicy,  trial.stateFeatures.getFeatureName());
            else
                learner = Learner.StepBasedRL.StepBasedPIREPS(trial.dataManager, trial.transitionFunction, trial.policyLearner, trial.actionPolicy);
            end                       
        end
    end
    
    % Class methods
    methods
        function obj = StepBasedPIREPS(dataManager, dynamicalSystem, policyLearner, policy, stateFeatureName)   
            learnerInit = @(dataManager_) Learner.EpisodicRL.EntropyREPS(dataManager_, [], [], 'rewardsToCome', 'rewardWeighting', [], 'logProbTrajectory', 'logProbTrajectory');
            
            obj = obj@Learner.StepBasedRL.StepBasedFromEpisodicLearner(dataManager, policyLearner, learnerInit);  
            
            obj.dynamicalSystem = dynamicalSystem;
            policy.setAdditionalNoiseProvider(dynamicalSystem);
            
            obj.addDataPreprocessor(DataPreprocessors.DataProbabilitiesPreprocessor(dataManager, policy));
            obj.addDataPreprocessor(DataPreprocessors.TrajectoryProbabilityPreprocessor(dataManager, dynamicalSystem));
            
            
            if (exist('stateFeatureName', 'var'))
               for i = 1:length(obj.LearnerPerTimeStep)
                   obj.LearnerPerTimeStep{i}.setStateFeatureName(stateFeatureName);
               end
            end
        end
        
        function [] = setStateFeatureName(obj, featureName)
            for i = 1:length(obj.LearnerPerTimeStep)
                obj.LearnerPerTimeStep{i}.setStateFeatureName(featureName);
            end
        end
                       
        function [] = updateModel(data)
            obj.updateModel@Learner.StepBasedRL.StepBasedFromEpisodicLearner(data);                      
        end
    end

end
