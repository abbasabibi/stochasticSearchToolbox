classdef DirectDistribution < Learner.Learner
    
    properties
        distribution;
        qFunction;
    end
    
    
    methods (Static)
        function [learner] = CreateFromTrial(trial)
            learner = Learner.DirectDistribution(trial.dataManager, trial.actionPolicy, trial.policyEvaluationFunction);
        end
    end
    
    % Class methods
    methods
        function obj = DirectDistribution(dataManager, distribution, qFunction)
            obj.distribution = distribution;
            obj.qFunction = qFunction;
        end
        
        function obj = updateModel(obj, data)
            obj.distribution.setParameterVector(obj.qFunction.getParameterVector());     
        end
    end
end

