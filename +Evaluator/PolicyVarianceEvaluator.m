classdef PolicyVarianceEvaluator < Evaluator.Evaluator
    %FILTEREDDATAEVALUATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function obj = PolicyVarianceEvaluator(additionalName)
            if (~exist('additionalName', 'var'))
                additionalName = '';
            end
            obj = obj@Evaluator.Evaluator(['policyVariance', additionalName], {'endLoop'}, Experiments.StoringType.ACCUMULATE);
        end
        
        function [evaluation] = getEvaluation(obj, data, newData, trial)
            [meanPol, stdPol] = trial.actionPolicy.callDataFunctionOutput('getExpectationAndSigma', data);
            evaluation = mean(stdPol);
        end
    end
    
end

