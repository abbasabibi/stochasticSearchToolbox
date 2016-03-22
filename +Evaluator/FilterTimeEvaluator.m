classdef FilterTimeEvaluator < Evaluator.Evaluator
    %FILTEREDDATAEVALUATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetObservable, AbortSet)
    end
    
    properties
    end
    
    methods
        function obj = FilterTimeEvaluator()
            obj = obj@Evaluator.Evaluator('filterTimeEvaluator', {'endLoop'}, Experiments.StoringType.ACCUMULATE);
        end
        
        function [evaluation] = getEvaluation(obj, data, newData, trial)
            if not(iscell(trial.evaluationObservations))
                trial.evaluationObservations = {trial.evaluationObservations};
            end
            observations = data.getDataEntry3D(trial.evaluationObservations{1});
            
            if length(trial.evaluationObservations) == 2 && data.isDataEntry(trial.evaluationObservations{2})
                obsPoints = data.getDataEntry(trial.evaluationObservations{2},1);
            else
                obsPoints = true(1,size(observations,1));
            end
            if not(isempty(trial.evaluationValid))
                valid = logical(data.getDataEntry(trial.evaluationValid,1));
                valid = all(valid,2);
            else
                valid = true(size(observations,2),1);
            end
            
            observations = observations(:,valid,:);
            
            % learn model
%             trial.filterLearner.initialized = false;
            tic;
            trial.filterLearner.initializeModel(data);
            trial.filterLearner.updateModel(data);
            learnTime = toc;

            tic;
            trial.filterLearner.filter.filterData(permute(observations,[2,3,1]),obsPoints);
            filterTime = toc;
            
            evaluation = [learnTime filterTime];
            
            fprintf('learnTime = %.4f  filterTime = %.4f\n',learnTime, filterTime);
        end

    end
end

