classdef DiscreteActionNextStateFeaturesCurrentPolicy < PolicyEvaluation.DiscreteActionStateFeatureGenerator
    
    properties
        actionPolicy
    end
        
    
    methods (Static)
        function [obj] = CreateFromTrial(trial)
            obj = PolicyEvaluation.DiscreteActionNextStateFeaturesCurrentPolicy(trial.dataManager, trial.nextStateFeatures.outputName, trial.discActionName, trial.actionPolicy);
        end
    end
        
    
    % Class methods
    methods
        function obj = DiscreteActionNextStateFeaturesCurrentPolicy(dataManager, nextStateFeatures, actionName, actionPolicy)
            obj = obj@PolicyEvaluation.DiscreteActionStateFeatureGenerator(dataManager, nextStateFeatures, actionName);

            obj.actionPolicy = actionPolicy;
            obj.setIsPerEpisodeCallFunction();
        end
               
        function [stateFeaturesActions] = getFeaturesInternal(obj, numElements, nextStateFeatures, actions)
            
            actions = obj.actionPolicy.sampleFromDistribution(size(nextStateFeatures,1), nextStateFeatures);                        
            
            stateFeaturesActions = obj.getFeaturesInternal@PolicyEvaluation.DiscreteActionStateFeatureGenerator(numElements, nextStateFeatures, actions);                
        end

    end
end
