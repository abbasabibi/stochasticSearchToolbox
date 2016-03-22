classdef SupervisedLearningMSEEvaluator < Evaluator.Evaluator
    %FILTEREDDATAEVALUATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function obj = SupervisedLearningMSEEvaluator(additionalName)
            if (~exist('additionalName', 'var'))
                additionalName = '';
            end
            obj = obj@Evaluator.Evaluator(['mseEvaluator', additionalName], {'endLoop'}, Experiments.StoringType.ACCUMULATE);
        end
        
        function [evaluation] = getEvaluation(obj, data, newData, trial)
            % get data
            
            evaluationData = obj.getEvaluationData(data, trial);
            
            predictedOutput = trial.functionApproximator.callDataFunctionOutput('getExpectationAndSigma', evaluationData);
            
            inputs = evaluationData.getDataEntry(trial.functionApproximator.inputVariables{1});
            outputs = evaluationData.getDataEntry(trial.functionApproximator.outputVariable);
            
            valid = ~any(isnan(inputs),2);
            
            error = predictedOutput(valid,:) - outputs(valid,:);
            
            evaluation = mean(bsxfun(@rdivide, sum(error.^2, 1) / size(error,1), var(outputs)), 2);
        end
    end
    
    methods (Abstract)
        [data] = getEvaluationData(obj, data, trial);                
    end
end

