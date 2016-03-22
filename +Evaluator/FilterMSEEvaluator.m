classdef FilterMSEEvaluator < Evaluator.Evaluator
    %FILTEREDDATAEVALUATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        validDataEntry
    end
    
    methods
        function obj = FilterMSEEvaluator(additionalName)
            if (~exist('additionalName', 'var'))
                additionalName = '';
            end
            obj = obj@Evaluator.Evaluator(['mseEvaluator', additionalName], {'endLoop'}, Experiments.StoringType.ACCUMULATE);
        end
        
        function [evaluation] = getEvaluation(obj, data, newData, trial)
            % get data
            
            evaluationData = obj.getEvaluationData(data, trial);
            
            observations = evaluationData.getDataEntry3D(trial.evaluationObservations);
            outputs = evaluationData.getDataEntry3D(trial.evaluationGroundtruth);
            outputs = permute(outputs,[2,3,1]);
            
            inputs = evaluationData.getDataEntry(trial.processedInputs);
            
            valid = ~any(isnan(inputs),2);
                        

            [predictedOutput predictedVariance] = trial.filterLearner.filter.filterData(permute(observations(:,valid,:),[2,3,1]));

            predictedOutput = permute(predictedOutput, [1,3,2]);
            predictedOutput = reshape(predictedOutput, size(predictedOutput,1) *  size(predictedOutput,2), size(predictedOutput,3));
            
            outputs = permute(outputs, [1,3,2]);
            outputs = reshape(outputs, size(outputs,1) *  size(outputs,2), size(outputs,3));
                        
            error = predictedOutput(valid,:) - outputs(valid,:);
            
            evaluation = mean(mean(bsxfun(@rdivide, sum(error.^2, 1) / size(error,1), var(evaluationData.getDataEntry(trial.evaluationGroundtruth))), 2), 3);
%             evaluation = mean(bsxfun(@rdivide, sum(error.^2, 1) / size(error,1), var(outputs)), 2);
        end
    end
    
    methods (Abstract)
        [data] = getEvaluationData(obj, data, trial);                
    end
end

