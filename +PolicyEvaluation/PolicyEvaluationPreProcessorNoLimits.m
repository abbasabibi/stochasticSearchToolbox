classdef PolicyEvaluationPreProcessorNoLimits < PolicyEvaluation.PolicyEvaluationPreProcessor
    
    properties(SetObservable,AbortSet)
        punishmentLimits = 0.01;
    end
    
    properties(SetAccess=protected)
       
        additionalData
        dataManager
        
        printDebug;

    end
    
    methods (Static)
        function obj = CreateFromTrial(trial)
            obj = PolicyEvaluation.PolicyEvaluationPreProcessorNoLimits(trial.dataManager, trial.policyEvaluationLearner, trial.policyEvaluationFunction, trial.actionPolicy);
            trial.policyLearner.setOutputVariableForLearner('actionsNoLimit');
        end
    end
    
    methods
        %%
        function obj = PolicyEvaluationPreProcessorNoLimits(dataManager, policyEvaluationLearner, valueFunction, actionPolicy)
            
            obj = obj@PolicyEvaluation.PolicyEvaluationPreProcessor(dataManager, policyEvaluationLearner, valueFunction);
            obj.dataManager = dataManager;
            
            obj.dataManager.addDataEntryForDepth(2, 'actionsNoLimit', dataManager.getNumDimensions('actions'), dataManager.getMinRange('actions'), dataManager.getMaxRange('actions'));
  
            obj.linkProperty('punishmentLimits', 'PolicyEvaluationPunishementLimits');
            obj.printDebug = true;
        end
        
        
        function [] = updateModel(obj, data)
            obj.policyEvaluationLearner.updateModel(data);
            
            %data.resetFeatureTags();
            if (isempty(obj.additionalData))
                obj.additionalData = obj.dataManager.getDataObject(0);
            end
            
            numSteps = data.getNumElementsForDepth(2);
            obj.additionalData.reserveStorage([1, numSteps]);
            obj.additionalData.resetFeatureTags();
           
            states = data.getDataEntry('states');
            obj.additionalData.setDataEntry('states', states);
            
            actions = data.getDataEntry('actions');
            obj.additionalData.setDataEntry('actionsNoLimit', actions);
            obj.additionalData.setDataEntry('actions', actions);            
            
            obj.valueFunction.callDataFunction('getExpectation', obj.additionalData);
            
            %Data bounding hack to make outside the bound data worse
            
            qValues = obj.additionalData.getDataEntry('qValues');
            punishmentUpper = sum(max(bsxfun(@minus, actions, obj.dataManager.getMaxRange('actions')), 0).^2, 2);
            qValues = qValues - punishmentUpper * obj.punishmentLimits;
            
            punishmentLower = sum(min(bsxfun(@minus, actions, obj.dataManager.getMinRange('actions')), 0).^2, 2);
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

