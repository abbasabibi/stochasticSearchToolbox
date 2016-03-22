classdef GPPolicyVarianceEvaluator < Evaluator.Evaluator
    %FILTEREDDATAEVALUATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function obj = GPPolicyVarianceEvaluator(additionalName)
            if (~exist('additionalName', 'var'))
                additionalName = '';
            end
            obj = obj@Evaluator.Evaluator(['GPpolicyVariance', additionalName], {'endLoop'}, Experiments.StoringType.ACCUMULATE);
        end
        
        function [evaluation] = getEvaluation(obj, data, newData, trial)
            evaluation = [];
            for i = 1:length(trial.actionPolicy.outputModels)
                evaluation = [evaluation, trial.actionPolicy.outputModels{i}.GPRegularizer,  trial.actionPolicy.outputModels{i}.GPPriorVariance];
            end
        end
    end
    
end

