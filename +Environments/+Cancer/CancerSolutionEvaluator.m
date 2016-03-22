classdef CancerSolutionEvaluator < Evaluator.Evaluator
    
    properties
        data
        
    end
    
    properties (SetObservable, AbortSet)
        numSamplesEvaluation = 200;
    end
    
    methods
        function [obj] = CancerSolutionEvaluator()
            obj = obj@Evaluator.Evaluator('rewardEval', {'preLoop', 'endLoop'}, Experiments.StoringType.ACCUMULATE);
            obj.linkProperty('numSamplesEvaluation');
        end
        
        function [evaluation] = getEvaluation(obj, data, newData, trial)
            if (isempty(obj.data))
                obj.data = trial.dataManager.getDataObject(0);
            end
            
            numSamplesTmp = trial.sampler.numSamples;
            numSamplesTmpInit = trial.sampler.numInitialSamples;
            
            seed = rng;
            rng(1000);
            trial.sampler.numSamples = 1;
            trial.sampler.numInitialSamples = 1;
            result = zeros(obj.numSamplesEvaluation,3);
            for i=1:obj.numSamplesEvaluation
                trial.sampler.createSamples(obj.data);
                result(i,:) = obj.data.getDataEntry('cancerEval');
            end
            
            trial.sampler.numSamples = numSamplesTmp;
            trial.sampler.numInitialSamples = numSamplesTmpInit;
            rng(seed);
            
            evaluation = mean(result);
            disp(evaluation);
            obj.data = [];
        end
    end
    
end