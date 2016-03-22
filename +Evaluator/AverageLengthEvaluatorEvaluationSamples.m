classdef AverageLengthEvaluatorEvaluationSamples < Evaluator.Evaluator
    
    properties
        data
        
    end
    
    properties (SetObservable, AbortSet)
        numSamplesEvaluation = 100;
        numStepsEvaluation;
        numTimeSteps;
    end
    
    methods
        function [obj] = AverageLengthEvaluatorEvaluationSamples(stepCount)
            obj = obj@Evaluator.Evaluator('avgLengthEval', {'endLoop'}, Experiments.StoringType.ACCUMULATE);
            obj.numStepsEvaluation = stepCount;
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
                obj.numTimeSteps = sampler.stepSampler.isActiveSampler.toReserve();
                sampler.stepSampler.isActiveSampler.setNumTimeSteps(obj.numStepsEvaluation);
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
                sampler.stepSampler.isActiveSampler.setNumTimeSteps(obj.numTimeSteps);
            end
            
            evaluation = numel(obj.data.getDataEntry('rewards'))/numel(obj.data.getDataEntry('iterationNumber'));
            fprintf('avgLengthEval: %f\n', evaluation);
            obj.data = [];
        end       
    end
    
end