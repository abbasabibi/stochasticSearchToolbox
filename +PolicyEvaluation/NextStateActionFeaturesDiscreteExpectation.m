classdef NextStateActionFeaturesDiscreteExpectation < FeatureGenerators.FeatureGenerator
    
    properties
        actionPolicy;
        actionName;
        stateActionFeatures;
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
                obj = PolicyEvaluation.NextStateActionFeaturesDiscreteExpectation(trial.dataManager, trial.stateActionFeatures, nextStateFeaturesName, trial.actionName, trial.actionPolicy);
            else
                obj = PolicyEvaluation.NextStateActionFeaturesDiscreteExpectation(trial.dataManager, trial.nextStateActionFeaturesInternal, nextStateFeaturesName, trial.actionName, trial.actionPolicy);
            end
        end
    end
    
    
    % Class methods
    methods
        function obj = NextStateActionFeaturesDiscreteExpectation(dataManager, stateActionFeatures, nextStateFeaturesName, actionName, actionPolicy)
            
            numFeatures = stateActionFeatures.getNumFeatures();
            %nextActionFeatures = PolicyEvaluation.NextActionCurrentPolicy(dataManager, actionName, actionPolicy, nextStateFeaturesName);
            obj = obj@FeatureGenerators.FeatureGenerator(dataManager, {nextStateFeaturesName}, '~nextStateActionFeatures', ':', numFeatures);
            obj.actionName = actionName;
            obj.actionPolicy = actionPolicy;
            obj.stateActionFeatures = stateActionFeatures;
            obj.setIsPerEpisodeCallFunction();
        end
        
        function [stateFeaturesActions] = getFeaturesInternal(obj, numElements, nextStates, nextActions)   
            nextActions = ones(size(nextStates,1),1);
            stateFeaturesActions = bsxfun(@times,obj.stateActionFeatures.getFeaturesInternal(numElements, [nextStates, nextActions]),exp(obj.actionPolicy.getDataProbabilities(nextStates,nextActions)));   
            for i=2:obj.actionPolicy.numItems
                nextActions = i*ones(size(nextStates,1),1);
                stateFeaturesActions = stateFeaturesActions + bsxfun(@times,obj.stateActionFeatures.getFeaturesInternal(numElements, [nextStates, nextActions]),exp(obj.actionPolicy.getDataProbabilities(nextStates,nextActions)));
            end
        end
        
        function [featureTag] = getFeatureTag(obj)
            featureTag = obj.stateActionFeatures.getFeatureTag();
        end
        
        function [isValid] = isValidFeatureTag(obj, featureTags)
            isValid = featureTags == obj.getFeatureTag();
        end
        
    end
end
