classdef AverageLengthEvaluatorNewSamples < Evaluator.Evaluator
    
    properties
        data
        
    end
    
    properties (SetObservable, AbortSet)
        numSamplesEvaluation = 100;
    end
    
    methods
        function [obj] = AverageLengthEvaluatorNewSamples()
            obj = obj@Evaluator.Evaluator('avgLength', {'endLoop'}, Experiments.StoringType.ACCUMULATE);
            obj.linkProperty('numSamplesEvaluation');
        end
        
        function [evaluation] = getEvaluation(obj, data, newData, trial)
            evaluation = numel(newData.getDataEntry('rewards'))/numel(newData.getDataEntry('iterationNumber'));
            fprintf('avgLength: %f\n', evaluation);
        end       
    end
    
end