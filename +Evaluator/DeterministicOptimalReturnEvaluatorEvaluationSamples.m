classdef DeterministicOptimalReturnEvaluatorEvaluationSamples < Evaluator.Evaluator
    
    properties
        data
        
    end
    
    properties (SetObservable, AbortSet)
        numSamplesEvaluation = 100;
    end
    
    methods
        function [obj] = DeterministicOptimalReturnEvaluatorEvaluationSamples()
            obj = obj@Evaluator.Evaluator('rewardEvalOptimalPolicy', {'endLoop'}, Experiments.StoringType.ACCUMULATE);
            obj.linkProperty('numSamplesEvaluation');
        end
        
        function [evaluation] = getEvaluation(obj, data, newData, trial)
            if (isempty(obj.data))
                obj.data = trial.dataManager.getDataObject(0);
            end
            
            if ~isprop(trial,'optimalPolicyEvaluationLearner')
                trial.setprop('optimalPolicyEvaluationFunction', @Functions.ValueFunctions.LinearQFunction);
                trial.setprop('optimalPolicyEvaluationLearner', @PolicyEvaluation.LeastSquaresTDQLearning.CreateFromTrialLearnQFunction);
                
                trial.optimalPolicyEvaluationFunction = trial.optimalPolicyEvaluationFunction(trial.dataManager, trial.featurePreprocessor.outputName, 'optimalqValues');
                trial.optimalPolicyEvaluationLearner = trial.optimalPolicyEvaluationLearner(trial, trial.optimalPolicyEvaluationFunction);
            end
            
            numSamplesTmp = trial.sampler.numSamples;
            
            seed = rng;
            rng(1000);
            
            trial.optimalPolicyEvaluationLearner.updateModel(data);
            
            oldSampler = trial.sampler.getStepSampler.samplerPools('Policy').samplerList{1}.objHandle;
            
            %newPolicy = Distributions.Discrete.DeterministicMaxDistribution(trial.dataManager,oldSampler.outputVariable,oldSampler.inputVariables,'deterministicOptimalPolicy');    
            newPolicy = Distributions.Discrete.EgreedyByQDistribution(trial.dataManager,oldSampler.outputVariable,oldSampler.inputVariables,'optimalPolicy',trial.optimalPolicyEvaluationFunction,0);
            newPolicy.addDataFunctionAlias('sampleAction', 'sampleFromDistribution');
                        
            trial.sampler.setActionPolicy(newPolicy);
            
            trial.sampler.numSamples = obj.numSamplesEvaluation;
            trial.sampler.createSamples(obj.data);
            trial.sampler.numSamples = numSamplesTmp;
            
            trial.sampler.setActionPolicy(oldSampler);
            
            rng(seed);
            
            evaluation = mean(obj.data.getDataEntry('returns'));
            fprintf('rewardEvalOptimalPolicy: %f\n', evaluation);
            obj.data = [];
        end
        
        
    end
    
end