classdef StepBasedPower < Learner.StepBasedRL.StepBasedFromEpisodicLearner
    
    properties
        
    end
    
    methods (Static)
        function [learner] =  CreateFromTrial(trial)
            learner = Learner.StepBasedRL.StepBasedPower(trial.dataManager, trial.policyLearner);
        end
        
        function [learner] =  CreateFromTrialKnowsNoise(trial)        
            trial.transitionFunction.registerControlNoiseInData();
            learner = Learner.StepBasedRL.StepBasedPower(trial.dataManager, trial.policyLearner);
            learner.addDataPreprocessor(DataPreprocessors.NoiseActionPreprocessor(trial.dataManager));           
            trial.policyLearner.setOutputVariableForLearner('actionsWithNoise');
        end        
    end
    
    % Class methods
    methods
        function obj = StepBasedPower(dataManager, policyLearner)
            initializer = @(dataManager_) Learner.EpisodicRL.EpisodicPower(dataManager_, [], 'rewardsToCome', 'rewardWeighting');
            obj = obj@Learner.StepBasedRL.StepBasedFromEpisodicLearner(dataManager, policyLearner, initializer);            
        end                     
    end
    
end
