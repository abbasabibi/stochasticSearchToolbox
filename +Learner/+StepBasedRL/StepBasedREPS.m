classdef StepBasedREPS < Learner.StepBasedRL.StepBasedFromEpisodicLearner
    
    properties
        
    end
    
    methods (Static)
        function [learner] =  CreateFromTrial(trial, qValueName, learnerDataName)
            if(~exist('qValueName', 'var'))
                qValueName = 'rewardsToCome';
            end
            
            if(~exist('learnerDataName', 'var'))
                learnerDataName = [];
            end
            
            if (trial.isProperty('stateFeatures')  && ~isempty( trial.stateFeatures))
                learner = Learner.StepBasedRL.StepBasedREPS(trial.dataManager, trial.policyLearner, trial.stateFeatures.getFeatureName(), qValueName, learnerDataName);
            else
                learner = Learner.StepBasedRL.StepBasedREPS(trial.dataManager, trial.policyLearner, [], qValueName, learnerDataName);
            end
        end
    end
    
    % Class methods
    methods
        function obj = StepBasedREPS(dataManager, policyLearner, stateFeatureName, qValueName, learnerDataName)
            if(~exist('qValueName', 'var'))
                qValueName = 'rewardsToCome';
            end
            disp(qValueName);
            
            
            initializer = @(dataManager_) Learner.EpisodicRL.EpisodicREPS(dataManager_, [], qValueName, 'rewardWeighting');
            obj = obj@Learner.StepBasedRL.StepBasedFromEpisodicLearner(dataManager, policyLearner, initializer);
            
            if(exist('learnerDataName', 'var') && ~isempty(learnerDataName))
                obj.dataNameLearner = learnerDataName;
            end
            
            if (exist('stateFeatureName', 'var') && ~isempty(stateFeatureName))
                obj.setStateFeatureName(stateFeatureName);
            end
        end
        
        function [] = setStateFeatureName(obj, featureName)
            for i = 1:length(obj.LearnerPerTimeStep)
                obj.LearnerPerTimeStep{i}.setStateFeatureName(featureName);
            end
        end
        
    end
    
end
