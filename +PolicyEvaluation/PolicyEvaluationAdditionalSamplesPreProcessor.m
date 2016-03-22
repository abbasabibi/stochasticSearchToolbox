classdef PolicyEvaluationAdditionalSamplesPreProcessor < PolicyEvaluation.PolicyEvaluationPreProcessor
    
    properties(SetObservable,AbortSet)
        PolicyEvaluationAdditionalSampleMultiplier = 1;
    end
    
    properties(SetAccess=protected)
        actionPolicy
        
        additionalData
        dataManager
        
        printDebug;
    end
    
    methods (Static)
        function obj = CreateFromTrial(trial)
            trial.setprop('useImportanceSampling', false);
            
            obj = PolicyEvaluation.PolicyEvaluationAdditionalSamplesPreProcessor(trial.dataManager, trial.policyEvaluationLearner, trial.policyEvaluationFunction, trial.actionPolicy);
        end
    end
    
    methods
        %%
        function obj = PolicyEvaluationAdditionalSamplesPreProcessor(dataManager, policyEvaluationLearner, valueFunction, actionPolicy)
            
            obj = obj@PolicyEvaluation.PolicyEvaluationPreProcessor(dataManager, policyEvaluationLearner, valueFunction);
            obj.dataManager = dataManager;
            
            obj.actionPolicy = actionPolicy;
            
            
            obj.linkProperty('PolicyEvaluationAdditionalSampleMultiplier');
            obj.printDebug = true;
        end
        
        
        function [] = updateModel(obj, data)
            obj.policyEvaluationLearner.updateModel(data);
            
            data.resetFeatureTags();
            if (isempty(obj.additionalData))
                obj.additionalData = obj.dataManager.getDataObject(0);
            end
            
            numSteps = data.getNumElementsForDepth(2);
            obj.additionalData.reserveStorage([1, numSteps * obj.PolicyEvaluationAdditionalSampleMultiplier]);
            obj.additionalData.resetFeatureTags();
           
            states = data.getDataEntry('states');
            additionalStates = repmat(states, obj.PolicyEvaluationAdditionalSampleMultiplier, 1);
            obj.additionalData.setDataEntry('states', additionalStates);
            obj.actionPolicy.callDataFunction('sampleAction', obj.additionalData);
            obj.valueFunction.callDataFunction('getExpectation', obj.additionalData);
            
            
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

