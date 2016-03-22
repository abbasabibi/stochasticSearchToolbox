classdef DiscreteActionNextStateFeatures < PolicyEvaluation.DiscreteActionStateFeatureGenerator
    
    properties
        actionPolicy
    end
        
    
    methods (Static)
        function [obj] = CreateFromTrial(trial)
            obj = PolicyEvaluation.DiscreteActionNextStateFeatures(trial.dataManager, trial.nextStateFeatures.outputName, trial.actionName, trial.actionPolicy);
        end
    end
        
    
    % Class methods
    methods
        function obj = DiscreteActionNextStateFeatures(dataManager, nextStateFeatures, actionName, actionPolicy)
            obj = obj@PolicyEvaluation.DiscreteActionStateFeatureGenerator(dataManager, nextStateFeatures, actionName);

            obj.actionPolicy = actionPolicy;
            obj.setIsPerEpisodeCallFunction();
        end
               
        function [stateFeaturesActions] = getFeaturesInternal(obj, numElements, nextStateFeatures, actions)

            numFeatures = size(nextStateFeatures,2);
            lastAction = obj.actionPolicy.sampleFromDistribution(1, nextStateFeatures(end,:));
            
            actions = [actions(2:end); lastAction];
            
            %actions = actions(2:end);
            %stateFeatures = nextStateFeatures(1:end-1,:);
            
            stateFeaturesActions = obj.getFeaturesInternal@PolicyEvaluation.DiscreteActionStateFeatureGenerator(numElements, nextStateFeatures, actions);                
            %stateFeaturesActions = [stateFeaturesActions;zeros(1,obj.numActions*obj.dimSample)];
        end

    end
end
