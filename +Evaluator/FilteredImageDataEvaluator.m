classdef FilteredImageDataEvaluator < Evaluator.Evaluator
    %FILTEREDDATAEVALUATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetObservable, AbortSet)
        numSamplesEvaluation = 100;
        groundtruthName
        observationIndex = 1;
    end
    
    properties
        evaluationData
        extractionFunction = @(a) a;
    end
    
    methods
        function obj = FilteredImageDataEvaluator()
            obj = obj@Evaluator.Evaluator('filteredImageDataEvaluator', {'endLoop'}, Experiments.StoringType.ACCUMULATE);
            obj.linkProperty('numSamplesEvaluation','filteredImageDataEvaluator_numSamplesEvaluation');
            obj.linkProperty('observationIndex','filteredImageDataEvaluator_observationIndex');
            obj.linkProperty('groundtruthName','filteredImageDataEvaluator_groundtruthName');
        end
        
        function [evaluation] = getEvaluation(obj, data, newData, trial)
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
%                 rng(1000);
                sampler.numSamples = obj.numSamplesEvaluation;
                sampler.numInitialSamples = obj.numSamplesEvaluation;
                sampler.createSamples(obj.evaluationData);
                sampler.numSamples = numSamplesTmp;
                sampler.numInitialSamples=initialSamplesTmp;
                rng(seed);
                
                % preprocess evaluation data
                for i = 1:length(trial.scenario.dataPreprocessorFunctions)
                    if not(isa(trial.scenario.dataPreprocessorFunctions{i},'FeatureGenerators.FeatureLearner.PrimaryComponentsAnalysis'))
                        obj.evaluationData = trial.scenario.dataPreprocessorFunctions{i}.preprocessData(obj.evaluationData);
                    end
                end
            end
            
            observations = obj.evaluationData.getDataEntry3D(trial.evaluationObservations);
            
            if length(trial.filterLearner.observations) == 2 && obj.evaluationData.isDataEntry(trial.filterLearner.observations{2})
                obsPoints = obj.evaluationData.getDataEntry(trial.filterLearner.observations{2},1);
            else
                obsPoints = true(1,size(observations,1));
            end
            groundtruth = obj.evaluationData.getDataEntry3D(obj.groundtruthName);
            if not(isempty(trial.evaluationValid))
                valid = logical(obj.evaluationData.getDataEntry(trial.evaluationValid,1));
            else
                valid = true(size(observations,2),1);
            end
            
            observations = observations(:,valid,:);
            groundtruth = groundtruth(:,valid,:);

            varargout = trial.filterLearner.filter.filterData(permute(observations,[2,3,1]),obsPoints);

            if iscell(varargout)
                mu = varargout{1};
                var = varargout{2};
            else
                mu = varargout;
            end
            
            extractedMu = zeros(size(groundtruth));
            for i = 1:size(groundtruth,1)
                extractedMu(i,:) = obj.extractionFunction(mu(:,obj.observationIndex,i)');
            end
            
            % evaluate the model
            evaluation = obj.squaredError(groundtruth,extractedMu) / (length(groundtruth(:)));
            disp(evaluation);
        end

    end
    
    methods (Static)
        function error = squaredError(data, estimates)
            error = (estimates - data).^2;
            error = sum(error(:));
        end
    end
end

