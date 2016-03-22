classdef FilterStdDevEvaluator < Evaluator.Evaluator
    %FILTEREDDATAEVALUATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetObservable, AbortSet)
        numSamplesEvaluation = 100;
        groundtruthName
        observationIndex = 1;
    end
    
    properties
        evaluationData
    end
    
    methods
        function obj = FilterStdDevEvaluator()
            obj = obj@Evaluator.Evaluator('filterStdDevEvaluator', {'endLoop'}, Experiments.StoringType.ACCUMULATE);
            obj.linkProperty('numSamplesEvaluation','filterStdDevEvaluator_numSamplesEvaluation');
            obj.linkProperty('observationIndex','filterStdDevEvaluator_observationIndex');
            obj.linkProperty('groundtruthName','filterStdDevEvaluator_groundtruthName');
        end
        
        function evaluation = getEvaluation(obj, data, newData, trial)
            % get data
            if (isempty(obj.evaluationData))
                if (isprop(trial,'evaluationSampler') && ~isempty(trial.evaluationSampler))
                    sampler = trial.evaluationSampler;
                else
                    sampler = trial.sampler;
                end
                dataManager = sampler.getDataManager;
                obj.evaluationData = dataManager.getDataObject(0);
                
                numSamplesTmp = sampler.numSamples;
                initialSamplesTmp = sampler.numInitialSamples;
                seed = rng;
                rng(1000);
                sampler.numSamples = obj.numSamplesEvaluation;
                sampler.numInitialSamples = obj.numSamplesEvaluation;
                sampler.createSamples(obj.evaluationData);
                sampler.numSamples = numSamplesTmp;
                sampler.numInitialSamples=initialSamplesTmp;
                rng(seed);
                
                % preprocess evaluation data
                for i = 1:length(trial.scenario.dataPreprocessorFunctions)
                    obj.evaluationData = trial.scenario.dataPreprocessorFunctions{i}.preprocessData(obj.evaluationData);
                end
            end
            
            groundtruth = obj.evaluationData.getDataEntry3D(trial.evaluationGroundtruth);
            observations = obj.evaluationData.getDataEntry3D(trial.evaluationObservations);
            
            if length(trial.filterLearner.observations) == 2 && obj.evaluationData.isDataEntry(trial.filterLearner.observations{2})
                obsPoints = obj.evaluationData.getDataEntry(trial.filterLearner.observations{2},1);
            else
                obsPoints = true(1,size(observations,1));
            end
            if not(isempty(trial.evaluationValid))
                valid = logical(obj.evaluationData.getDataEntry(trial.evaluationValid,1));
            else
                valid = true(size(observations,2),1);
            end
            
            observations = observations(:,valid,:);
            groundtruth = groundtruth(:,valid,:);

            [mu, var] = trial.filterLearner.filter.filterData(permute(observations,[2,3,1]),obsPoints);
            
            % evaluate the model
            [inOneP, inTwoP, inThreeP] = obj.percentageOutside2Std(groundtruth,permute(mu(:,obj.observationIndex,:),[3,1,2]),permute(var(:,obj.observationIndex,:),[3,1,2]));
            evaluation = [inOneP inTwoP inThreeP];
        end

    end
    
    methods (Static)
        function [inOneP, inTwoP, inThreeP] = percentageOutside2Std(data, mean, var)
            error = abs(mean - data);
            stdDev = sqrt(var);
            inOne = error < stdDev;
            inTwo = error < 2 * stdDev;
            inThree = error < 3 * stdDev;
            inOneP = sum(inOne(:)) / numel(data);
            inTwoP = sum(inTwo(:)) / numel(data);
            inThreeP = sum(inThree(:)) / numel(data);
        end
    end
end

