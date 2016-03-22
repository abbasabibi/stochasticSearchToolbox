classdef TimeDependentLearner < Learner.Learner
    
    properties (SetObservable)
        learnersPerTimeStep;
        numLearners
    end
    
    % Class methods
    methods
        function obj = TimeDependentLearner(dataManager, composedTimeDependentDistribution, learnerInitializer)
            obj = obj@Learner.Learner();
            
            obj.linkProperty('numLearners', 'numTimeSteps');
            
            for i = 1:obj.numLearners
                obj.learnersPerTimeStep{i} = learnerInitializer(dataManager, composedTimeDependentDistribution.distributionPerTimeStep{i});
            end
        end
        
        function obj = updateModel(obj, data)
            for i = 1:obj.numLearners
                obj.learnersPerTimeStep{i}.callDataFunction('learnFunction', data, :, i);
            end
        end
        
        function obj = updateModelForTimeStep(obj, data, t)
            obj.learnersPerTimeStep{t}.callDataFunction('learnFunction', data, :, t);
        end
        
        function obj = setWeightName(obj, weightName)
            for i = 1:obj.numLearners
                obj.learnersPerTimeStep{i}.setWeightName(weightName);
            end
        end
        
        function [] = setInputVariablesFromMapping(obj)
            for i = 1:obj.numLearners
                obj.learnersPerTimeStep{i}.setInputVariablesFromMapping();
            end                                   
        end
        
        function [] = setInputVariablesForLearner(obj, varargin)
            for i = 1:obj.numLearners
                obj.learnersPerTimeStep{i}.setInputVariablesForLearner(varargin);
            end
        end
        
        function [] = setOutputVariableForLearner(obj, outputVariable)
            for i = 1:obj.numLearners
                obj.learnersPerTimeStep{i}.setOutputVariableForLearner(outputVariable);
            end
        end
        
        function [outputVariable] = getOutputVariable(obj)
            outputVariable = obj.learnersPerTimeStep{1}.getOutputVariable();
        end
        
    end
end
