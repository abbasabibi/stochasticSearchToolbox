classdef StepBasedPIREPSLambda < Learner.StepBasedRL.StepBasedFromEpisodicLearner
    
    properties

    end

     methods (Static)
        function [learner] =  CreateFromTrial(trial)
            trial.rewardFunction.useSeperateStateActionReward(true);
                       
            if (trial.isProperty('stateFeatures') && ~isempty( trial.stateFeatures))
                learner = Learner.StepBasedRL.StepBasedPIREPSLambda(trial.dataManager, trial.transitionFunction, trial.policyLearner, trial.actionPolicy,  trial.stateFeatures.getFeatureName());
            else
                learner = Learner.StepBasedRL.StepBasedPIREPSLambda(trial.dataManager, trial.transitionFunction, trial.policyLearner, trial.actionPolicy);
            end                                   
        end
    end
    
    % Class methods
    methods
        function obj = StepBasedPIREPSLambda(dataManager, dynamicalSystem, policyLearner, policy, stateFeatureName)   

            learnerInit = @(dataManager_) Learner.EpisodicRL.EntropyREPS(dataManager_, [], [], 'pathCostsToCome', 'rewardWeighting', 'logProbTrajectory', 'logProbTrajectory');
            
            obj = obj@Learner.StepBasedRL.StepBasedFromEpisodicLearner(dataManager, policyLearner, learnerInit);  
                       
            policy.setAdditionalNoiseProvider(dynamicalSystem);
            
            obj.addDataPreprocessor(DataPreprocessors.PathIntegralPreprocessor(dataManager, dynamicalSystem));
            obj.addDataPreprocessor(DataPreprocessors.DataProbabilitiesPreprocessor(dataManager, policy));
            obj.addDataPreprocessor(DataPreprocessors.TrajectoryProbabilityPreprocessor(dataManager, dynamicalSystem));
            obj.addDataPreprocessor(DataPreprocessors.NoiseActionPreprocessor(dataManager));
            
            obj.policyLearner.setOutputVariableForLearner('actionsWithNoise');
            
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
                       
        
    end

end
