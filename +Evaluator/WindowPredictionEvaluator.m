classdef WindowPredictionEvaluator < Evaluator.Evaluator
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
        function obj = WindowPredictionEvaluator()
            obj = obj@Evaluator.Evaluator('windowPredictionEvaluator', {'endLoop'}, Experiments.StoringType.ACCUMULATE);
            obj.linkProperty('numSamplesEvaluation');
            obj.linkProperty('observationIndex');
            obj.linkProperty('groundtruthName');
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
            
            if not(iscell(trial.evaluationObservations))
                trial.evaluationObservations = {trial.evaluationObservations};
            end
            observations = obj.evaluationData.getDataEntry3D(trial.evaluationObservations{1});
            
            if length(trial.evaluationObservations) == 2 && obj.evaluationData.isDataEntry(trial.evaluationObservations{2})
                obsPoints = obj.evaluationData.getDataEntry(trial.evaluationObservations{2},1);
            else
                obsPoints = true(1,size(observations,1));
            end
            groundtruth = obj.evaluationData.getDataEntry3D(trial.evaluationGroundtruth);
            if not(isempty(trial.evaluationValid))
                valid = logical(obj.evaluationData.getDataEntry(trial.evaluationValid,1));
                valid = all(valid,2);
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
            
            % evaluate the model
            switch trial.evaluationMetric
                case 'mse'
                    evaluation = obj.squaredError(groundtruth,permute(mu(:,trial.evaluationObservationIndex,:),[3,1,2])) ./ (numel(groundtruth)/size(groundtruth,3));
                    fprintf('MSE = %.4f\n',evaluation);
                case 'euclidean'
                    evaluation = obj.euclideanDistances(groundtruth, permute(mu(:,trial.evaluationObservationIndex,:),[3,1,2]),trial.filterLearner.filter.windowSize);
                    fprintf('MED = %.4f\n',evaluation);
            end
        end

    end
    
    methods (Static)
        function error = squaredError(data, estimates)
            error = (estimates - data).^2;
            error = reshape(sum(sum(error,1),2),1,[],1);
        end
        
        function error = euclideanDistances(data, estimates, window_size)
            out_dim = size(data,3)/window_size;
            data = reshape(data,[],out_dim,window_size);
            estimates = reshape(estimates,[],out_dim,window_size);
            error = (estimates - data).^2;
            error = sum(sqrt(sum(error,2)),1)./size(error,1);
            error = reshape(error,1,window_size);
        end
    end
end

