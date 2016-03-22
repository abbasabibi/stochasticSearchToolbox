classdef DummyLearner < Learner.Learner
    
    properties
        iteration = 0;
    end
    
    % Class methods
    methods
        function obj = DummyLearner(varargin)
            obj = obj@Learner.Learner(varargin{:});
        end
        
        
        function obj = updateModel(obj, data)
            obj.iteration = obj.iteration + 1;
        end
        
        function [] = printMessage(obj, data, trial)
            fprintf('Dummy Learner Iteration %d\n', obj.iteration);
        end
        
    end
end
