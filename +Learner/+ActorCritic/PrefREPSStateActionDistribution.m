classdef PrefREPSStateActionDistribution < Learner.EpisodicRL.EpisodicPrefREPS
    properties
        
    end
    
    
     methods (Static)
        function [learner] = CreateFromTrial(trial)
            if (trial.isProperty('stateFeatures') && ~isempty( trial.stateFeatures) )
                if (isprop(trial,'useImportanceSampling') && trial.useImportanceSampling)
                    learner = Learner.ActorCritic.PrefREPSStateActionDistribution(trial.dataManager, trial.policyLearner, trial.qValueName, trial.stateFeatures.getFeatureName(), 'importanceWeights');
                else
                    learner = Learner.ActorCritic.PrefREPSStateActionDistribution(trial.dataManager, trial.policyLearner, trial.qValueName, trial.stateFeatures.getFeatureName());
                end
                %learner = Learner.ActorCritic.REPSStateActionDistribution(trial.dataManager, trial.policyLearner, trial.qValueName, trial.stateFeatures.getFeatureName());
            else
                learner = Learner.ActorCritic.PrefREPSStateActionDistribution(trial.dataManager, trial.policyLearner);
            end 
        end
    end
    
    % Class methods
    methods
        function obj = PrefREPSStateActionDistribution(dataManager, policyLearner, qValueName, stateFeatureName, varargin)            
            if (~exist('qValueName','var'))
                qValueName = 'qValues';
            end
            obj = obj@Learner.EpisodicRL.EpisodicPrefREPS(dataManager, policyLearner, qValueName, 'qValueWeights', stateFeatureName, 'steps', varargin{:});            
        end
    end
end
