classdef ReturnEvaluatorDecisionStages < Evaluator.Evaluator
    
    properties
        data
        isActiveStepSampler = [];
        sampler = [];
    end
    
    properties (SetObservable, AbortSet)
        numSamplesEvaluation    = 100;
        numStepsEvaluation      = 50;
        
    end
    
    methods
        function [obj] = ReturnEvaluatorDecisionStages(numSamplesEvaluation, numStepsEvaluation, sampler)
            obj = obj@Evaluator.Evaluator('rewardEval', {'endLoop'}, Experiments.StoringType.ACCUMULATE);
            obj.numSamplesEvaluation    = numSamplesEvaluation;
            obj.numStepsEvaluation      = numStepsEvaluation;
            if(exist('sampler','var'))
                obj.sampler = sampler;
            end
        end
        
        function [evaluation] = getEvaluation(obj, data, newData, trial)
            
            if(isempty(obj.isActiveStepSampler))
                obj.isActiveStepSampler = Sampler.IsActiveStepSampler.IsActiveNumSteps(trial.dataManager, 'decisionSteps');
                obj.isActiveStepSampler.numTimeSteps = obj.numStepsEvaluation;
            end
            
            if(isempty(obj.sampler))
                currSampler = trial.sampler;
            else
                currSampler = obj.sampler;
            end

            oldSampler = currSampler.stageSampler.isActiveSampler;
            

            currSampler.stageSampler.setIsActiveSampler(obj.isActiveStepSampler);

            
            if (isprop(trial,'evaluationSampler') && ~isempty(trial.evaluationSampler))
                sampler = trial.evaluationSampler;
            else
                sampler = currSampler;
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

            
            evaluation = mean(obj.data.getDataEntry('rewards'));
            msg = 'rewardEval:';
            fprintf('%50s %.3g\n', msg, evaluation);            
%             fprintf('rewardEval: %f\n', evaluation);
            obj.data = [];
            
            assert(evaluation > -5);
            
            currSampler.stageSampler.setIsActiveSampler(oldSampler);
        end
        
   
        
        
    end
    
end