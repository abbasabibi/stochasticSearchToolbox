classdef NextActionCurrentPolicy < FeatureGenerators.FeatureGenerator  
    
    properties
        actionPolicy;
        actionName;
        stateActionFeatures;
    end
        
    
    methods (Static)
        function [obj] = CreateFromTrial(trial)
            obj = PolicyEvaluation.NextStateActionFeaturesCurrentPolicy(trial.dataManager, trial.stateActionFeatures, trial.nextStateFeatures.outputName, trial.actionName, trial.actionPolicy);
        end
    end
        
    
    % Class methods
    methods
        function obj = NextActionCurrentPolicy(dataManager, actionName, actionPolicy, nextStateFeaturesName)
            
            numFeatures = dataManager.getNumDimensions(actionName);
           
            obj = obj@FeatureGenerators.FeatureGenerator(dataManager, nextStateFeaturesName, '~nextActions', ':', numFeatures);
            %obj = obj@FeatureGenerators.FeatureGenerator(dataManager, nextStateFeaturesName, actionName);

            obj.actionName = actionName;
            obj.actionPolicy = actionPolicy;
        end
               
        function [nextActions] = getFeaturesInternal(obj, numElements, nextStates)
            
            nextActions = obj.actionPolicy.sampleFromDistribution(size(nextStates,1), nextStates);                        
            minRange = obj.dataManager.getMinRange(obj.actionName);
            maxRange = obj.dataManager.getMaxRange(obj.actionName);
            
            nextActions = bsxfun(@min, bsxfun(@max, nextActions, minRange), maxRange);             
        end

    end
end
