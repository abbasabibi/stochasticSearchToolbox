classdef FilterMSETestEvaluator < Evaluator.FilterMSEEvaluator
    %FILTEREDDATAEVALUATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetObservable, AbortSet)
        numSamplesEvaluation = 100;
    end
    
    properties
        evaluationData
        fileNameTest
    end
    
    methods
        function obj = FilterMSETestEvaluator()
            obj = obj@Evaluator.FilterMSEEvaluator('Test');
        end
        
        function [data] = getEvaluationData(obj, data, trial)
            
            sampler = Sampler.SamplerFromFile(trial.dataManager, trial.fileNameTest);
            
            dataManager = sampler.getDataManager;
            obj.evaluationData = dataManager.getDataObject(0);
            
            seed = rng();
            sampler.numImitationEpisodes = obj.numSamplesEvaluation;
            sampler.createSamples(obj.evaluationData);
            rng(seed);
            
            % preprocess evaluation data
            for i = 1:length(trial.scenario.dataPreprocessorFunctions)
                obj.evaluationData = trial.scenario.dataPreprocessorFunctions{i}.preprocessData(obj.evaluationData);
            end
            data = obj.evaluationData;
        end
    end
    
    methods (Static)
        
    end
end

