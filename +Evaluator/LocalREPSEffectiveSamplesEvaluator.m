

classdef LocalREPSEffectiveSamplesEvaluator < Evaluator.Evaluator
    
    properties
        initial;
    end
    methods
        function [obj] = LocalREPSEffectiveSamplesEvaluator()
            obj = obj@Evaluator.Evaluator('EffectiveSamples', {'endLoop'}, Experiments.StoringType.ACCUMULATE);
            obj.initial = true;
        end
        
        function [evaluation] = getEvaluation(obj, data, newData, trial)
            if(obj.initial)     
                obj.initial = false;
                ind=find(ismember(trial.evalParameters,'settings.numSamplesEpisodes'));
                value = trial.evalValues{ind};
                evaluation = zeros(1,value);
            else
                weights = trial.parameterPolicy.kernel.getKernelVector(newData.getDataEntry('contexts'));
                evaluation = sum(weights,2)';
                fprintf('EffectiveSamples: %s\n', mat2str(evaluation));
            end
        end
        
    end
    
end
