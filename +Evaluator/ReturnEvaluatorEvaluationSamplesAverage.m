classdef ReturnEvaluatorEvaluationSamplesAverage < Evaluator.Evaluator
   
    properties
        data
       
    end
    
    properties (SetObservable, AbortSet)
            numSamplesEvaluation = 100;
    end
    
    methods
        function [obj] = ReturnEvaluatorEvaluationSamplesAverage()
            obj = obj@Evaluator.Evaluator('rewardEval', {'preLoop', 'endLoop'}, Experiments.StoringType.ACCUMULATE);          
            obj.linkProperty('numSamplesEvaluation');
        end                        
        
        function [evaluation] = getEvaluation(obj, data, newData, trial)
            if (isprop(trial,'evaluationSampler') && ~isempty(trial.evaluationSampler))
                sampler = trial.evaluationSampler;
            else
                sampler = trial.sampler;
            end
            dataManager = sampler.getDataManager;
            
            if (isempty(obj.data))
                obj.data = dataManager.getDataObject(0);
            end
            
            numSamplesTmp = sampler.numSamples;
            initialSamplesTmp = sampler.numInitialSamples;
            seed = rng;
            rng(1000);
            sampler.numSamples = obj.numSamplesEvaluation;
            sampler.numInitialSamples = obj.numSamplesEvaluation;
            sampler.createSamples(obj.data);
            sampler.numSamples = numSamplesTmp;
            sampler.numInitialSamples=initialSamplesTmp;
            rng(seed);
            
            evaluation = sum(obj.data.getDataEntry('returns'))/obj.data.getNumElementsForDepth(2);     
            fprintf('rewardEval: %f\n', evaluation);
            obj.data = [];
        end
        
        
    end   
    
end