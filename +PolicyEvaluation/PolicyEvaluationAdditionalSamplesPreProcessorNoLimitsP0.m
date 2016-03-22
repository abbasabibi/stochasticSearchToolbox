classdef PolicyEvaluationAdditionalSamplesPreProcessorNoLimitsP0 < PolicyEvaluation.PolicyEvaluationPreProcessor
    
    properties(SetObservable,AbortSet)
        PolicyEvaluationAdditionalSampleMultiplier = 1;
        punishmentLimits = 0.01;
    end
    
    properties(SetAccess=protected)
        actionPolicy
        initialWeights = [];
        
        additionalData
        dataManager
        
        printDebug;

    end
    
    methods (Static)
        function obj = CreateFromTrial(trial)
            trial.setprop('useImportanceSampling', false);
            
            obj = PolicyEvaluation.PolicyEvaluationAdditionalSamplesPreProcessorNoLimitsP0(trial.dataManager, trial.policyEvaluationLearner, trial.policyEvaluationFunction, trial.actionPolicy);
            trial.policyLearner.setOutputVariableForLearner('actionsNoLimit');
        end
    end
    
    methods
        %%
        function obj = PolicyEvaluationAdditionalSamplesPreProcessorNoLimitsP0(dataManager, policyEvaluationLearner, valueFunction, actionPolicy)
            
            obj = obj@PolicyEvaluation.PolicyEvaluationPreProcessor(dataManager, policyEvaluationLearner, valueFunction);
            obj.dataManager = dataManager;
            
            obj.dataManager.addDataEntryForDepth(2, 'actionsNoLimit', dataManager.getNumDimensions('actions'), dataManager.getMinRange('actions'), dataManager.getMaxRange('actions'));
            obj.actionPolicy = actionPolicy;
            
            
            obj.linkProperty('PolicyEvaluationAdditionalSampleMultiplier');
            obj.linkProperty('punishmentLimits', 'PolicyEvaluationPunishementLimits');
            obj.printDebug = true;
        end
        
        
        function [] = updateModel(obj, data)
            if isempty(obj.initialWeights)
                obj.initialWeights = obj.actionPolicy.getItemProb();
            end
            obj.policyEvaluationLearner.updateModel(data);
            
            %data.resetFeatureTags();
            if (isempty(obj.additionalData))
                obj.additionalData = obj.dataManager.getDataObject(0);
            end
            
            numSteps = data.getNumElementsForDepth(2);
            obj.additionalData.reserveStorage([1, numSteps * obj.PolicyEvaluationAdditionalSampleMultiplier]);
            obj.additionalData.resetFeatureTags();
           
            states = data.getDataEntry('states');
            additionalStates = repmat(states, obj.PolicyEvaluationAdditionalSampleMultiplier, 1);
            obj.additionalData.setDataEntry('states', additionalStates);
            
            oldWeights = obj.actionPolicy.getItemProb();
            obj.actionPolicy.setItemProb(obj.initialWeights);
            actionsNoLimit = obj.actionPolicy.callDataFunctionOutput('sampleAction', obj.additionalData);
            obj.actionPolicy.setItemProb(oldWeights);
            
            obj.additionalData.setDataEntry('actionsNoLimit', actionsNoLimit);
            obj.additionalData.setDataEntry('actions', actionsNoLimit);            
            
            obj.valueFunction.callDataFunction('getExpectation', obj.additionalData);
            
            %Data bounding hack to make outside the bound data worse
            
            qValues = obj.additionalData.getDataEntry('qValues');
            punishmentUpper = sum(max(bsxfun(@minus, actionsNoLimit, obj.dataManager.getMaxRange('actions')), 0).^2, 2);
            qValues = qValues - punishmentUpper * obj.punishmentLimits;
            
            punishmentLower = sum(min(bsxfun(@minus, actionsNoLimit, obj.dataManager.getMinRange('actions')), 0).^2, 2);
            qValues = qValues - punishmentLower * obj.punishmentLimits;
            obj.additionalData.setDataEntry('qValues', qValues);
            
%             if (obj.printDebug)
%                 minStates = min(states);
%                 maxStates = max(states);
%                 
%                 Plotter.PlotterFunctions.plotOutputFunctionSlice2D(obj.valueFunction, 1, 2, minStates, maxStates, [0, 0, 0], 50);
%             end
            
            obj.updateLearner(obj.additionalData);
        end
    end
end

