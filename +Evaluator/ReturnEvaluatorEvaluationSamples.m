classdef ReturnEvaluatorEvaluationSamples < Evaluator.Evaluator
    
    properties
        data
        
    end
    
    properties (SetObservable, AbortSet)
        numSamplesEvaluation = 100;
        numStepsEvaluation;
    end
    
    methods
        function [obj] = ReturnEvaluatorEvaluationSamples()
            obj = obj@Evaluator.Evaluator('rewardEval', {'endLoop'}, Experiments.StoringType.ACCUMULATE);
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
            
            if(~isempty(obj.numStepsEvaluation))
                numStepsTmp = Common.Settings().getProperty('numTimeSteps');
                Common.Settings().setProperty('numTimeSteps',obj.numStepsEvaluation)
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
            if(~isempty(obj.numStepsEvaluation))
                Common.Settings().setProperty('numTimeSteps',numStepsTmp)
            end
            
            evaluation = mean(obj.data.getDataEntry('returns'));
            fprintf('rewardEval: %f\n', evaluation);
            obj.data = [];
        end
        
   
        
        
    end
    
end