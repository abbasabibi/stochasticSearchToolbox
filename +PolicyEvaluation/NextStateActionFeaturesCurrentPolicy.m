classdef NextStateActionFeaturesCurrentPolicy < FeatureGenerators.FeatureGenerator
    
    properties
        actionPolicy;
        actionName;
        stateActionFeatures;
        nextActionFeatures
    end
    
    
    methods (Static)
        function [obj] = CreateFromTrial(trial)
            nextStateFeaturesName = 'nextStates';
            if (~isempty(trial.policyInputVariables))
                if strcmp(trial.policyInputVariables,'useStateFeatures')
                    nextStateFeaturesName = trial.nextStateFeatures.outputName;
                end
            end
            if (isprop(trial,'nextStateActionInputVariables') && ~isempty(trial.nextStateActionInputVariables))
                nextStateFeaturesName = trial.nextStateActionInputVariables;
            end
            if isempty(trial.findprop('nextStateActionFeaturesInternal'))
                obj = PolicyEvaluation.NextStateActionFeaturesCurrentPolicy(trial.dataManager, trial.stateActionFeatures, nextStateFeaturesName, trial.actionName, trial.actionPolicy);
            else
                obj = PolicyEvaluation.NextStateActionFeaturesCurrentPolicy(trial.dataManager, trial.nextStateActionFeaturesInternal, nextStateFeaturesName, trial.actionName, trial.actionPolicy);
            end
        end
    end
    
    
    % Class methods
    methods
        function obj = NextStateActionFeaturesCurrentPolicy(dataManager, stateActionFeatures, nextStateFeaturesName, actionName, actionPolicy)
            
            numFeatures = stateActionFeatures.getNumFeatures();
            nextActionFeatures = PolicyEvaluation.NextActionCurrentPolicy(dataManager, actionName, actionPolicy, actionPolicy.inputVariables{1});
            obj = obj@FeatureGenerators.FeatureGenerator(dataManager, {nextStateFeaturesName, 'nextActions'}, '~nextStateActionFeatures', ':', numFeatures);
            obj.nextActionFeatures = nextActionFeatures;
            obj.actionName = actionName;
            obj.actionPolicy = actionPolicy;
            obj.stateActionFeatures = stateActionFeatures;
            obj.setIsPerEpisodeCallFunction();
            obj.setIsSparse(stateActionFeatures.isSparse());
        end
        
        function [stateFeaturesActions] = getFeaturesInternal(obj, numElements, nextStates, nextActions)         
            stateFeaturesActions = obj.stateActionFeatures.getFeaturesInternal(numElements, [nextStates, nextActions]);           
        end
        
        function [featureTag] = getFeatureTag(obj)
            featureTag = obj.stateActionFeatures.getFeatureTag();
        end
        
        function [isValid] = isValidFeatureTag(obj, featureTags)
            isValid = featureTags == obj.getFeatureTag();
        end
        
    end
end
