classdef PolicyEvaluationPreProcessor < Learner.Learner
    
    properties(SetObservable,AbortSet)
        learners = {};
    end
    
    properties(SetAccess=protected)
        policyEvaluationLearner
        valueFunction
    end
    
    methods (Static)
        function obj = CreateFromTrial(trial)
            obj = PolicyEvaluation.PolicyEvaluationPreProcessor(trial.dataManager, trial.policyEvaluationLearner, trial.policyEvaluationFunction);
        end
    end
    
    methods
        %%
        function obj = PolicyEvaluationPreProcessor(dataManager, policyEvaluationLearner, valueFunction)
            
            obj = obj@Learner.Learner();
            dataManager.addDataEntry(['steps.', valueFunction.outputVariable], 1);
            %obj = obj@FeatureGenerators.FeatureGenerator(dataManager, valueFunction.inputVariables{1}, ['~', valueFunction.outputVariable], ':', valueFunction.dimOutput);
            
            obj.policyEvaluationLearner = policyEvaluationLearner;
            obj.valueFunction = valueFunction;
        end
        
        function [] = addLearner(obj, learner)
            obj.learners = [obj.learners, learner];
            if (~iscell(obj.learners))
                obj.learners = {obj.learners};
            end
        end
        
        function [] = updateLearner(obj, data)
            for i = 1:length(obj.learners)
                obj.learners{i}.updateModel(data);
            end
        end
        
         
        function [] = printMessage(obj, data)
            for i = 1:length(obj.learners)
                obj.learners{i}.printMessage(data);
            end
        end
        
        function [qValueName] = getQValueName(obj)
            qValueName = obj.valueFunction.getOutputVariable();
        end
        
        
        function [] = updateModel(obj, data)
            obj.policyEvaluationLearner.updateModel(data);
            obj.valueFunction.callDataFunction('getExpectation', data);
            obj.updateLearner(data);
        end
    end
end

