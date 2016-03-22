classdef KldFilteredDataEvaluator < Evaluator.Evaluator
    %FILTEREDDATAEVALUATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetObservable, AbortSet)
        numSamplesEvaluation = 20;
        groundtruthName
        observationIndex = 1;
    end
    
    properties
        evaluationData
    end
    
    methods
        function obj = KldFilteredDataEvaluator()
            obj = obj@Evaluator.Evaluator('kldFilteredDataEvaluator', {'endLoop'}, Experiments.StoringType.ACCUMULATE);
            obj.linkProperty('numSamplesEvaluation');
            obj.linkProperty('observationIndex');
            obj.linkProperty('groundtruthName');
        end
        
        function [KL] = getEvaluation(obj, data, newData, trial)
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
                % initialize mc filter
                trial.mcFilter.sampleShitloadOfData(trial.sampler);
                
                sampler.numSamples = numSamplesTmp;
                sampler.numInitialSamples=initialSamplesTmp;
                rng(seed);
                
                % preprocess evaluation data
                for i = 1:length(trial.scenario.dataPreprocessorFunctions)
                    obj.evaluationData = trial.scenario.dataPreprocessorFunctions{i}.preprocessData(obj.evaluationData);
                end
            end
            
            observations = obj.evaluationData.getDataEntry3D(trial.evaluationObservations{1});
            
            if length(trial.evaluationObservations) == 2 && obj.evaluationData.isDataEntry(trial.evaluationObservations{2})
                obsPoints = data.getDataEntry(trial.evaluationObservations{2},1);
            else
                obsPoints = true(1,size(observations,1));
            end
            
            if not(isempty(trial.evaluationValid))
                valid = logical(obj.evaluationData.getDataEntry(trial.evaluationValid,1));
            else
                valid = true(size(observations,2),1);
            end
            
            observations = observations(:,valid,:);
            obsPoints = obsPoints(valid);

            [mu, var] = trial.filterLearner.filter.filterData(permute(observations,[2,3,1]),obsPoints);
            [mcmu, mcvar] = trial.mcFilter.filterData(permute(observations,[2,3,1]),obsPoints);
            
            % evaluate the model
            KL = obj.kullbackLeiblerDivergence(...
                mcmu(:,trial.evaluationObservationIndex,:), ...
                mcvar(:,trial.evaluationObservationIndex,:), ...
                mu(:,trial.evaluationObservationIndex,:), ...
                var(:,trial.evaluationObservationIndex,:));
            fprintf('KL = %.4f\n',KL);
        end

    end
    
    methods (Static)
        function KL = kullbackLeiblerDivergence(mu1, var1, mu2, var2)
            e = (mu2 - mu1).^2./var2;
            KL = .5 * (var2 .\ var1 + e - size(mu1,2) + log(var2./var1));
            KL = sum(KL(:))/numel(KL);
        end
    end
end

