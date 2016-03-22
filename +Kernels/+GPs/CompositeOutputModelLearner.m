
classdef CompositeOutputModelLearner < Learner.Learner
    %Gaussian Process Policy  Selecting actions according to GP
    %   GP fitted on weighted samples
    %   conditioned on S, policy is a Gaussian
    
    properties (SetObservable, AbortSet)
       
    end
    
    properties
        compositeOutputModel
        compositeOutputModelLearner
        
        weightName
    end
    
    methods
        function obj = CompositeOutputModelLearner(dataManager, compositeOutputModel, outputModelLearnerInitializer)
            
            obj = obj@Learner.Learner();
            
            obj.compositeOutputModel = compositeOutputModel;
            for i = 1:compositeOutputModel.getNumModels()
                obj.compositeOutputModelLearner{i} = outputModelLearnerInitializer(dataManager, compositeOutputModel.getOutputModel(i));
            end            
        end
        
         
        function [sumVal] = sumCompositeLearnerFunctions(obj, functionName, varargin)
            sumVal = 0;
            
            for i = 1:length(obj.compositeOutputModelLearner)
               sumVal = sumVal + obj.compositeOutputModelLearner{i}.(functionName)(varargin{:});
            end
        end
        
        function updateModel(obj, data)
            for i = 1:length(obj.compositeOutputModelLearner)
                obj.compositeOutputModelLearner{i}.updateModel(data);
            end                                    
        end      
        
        
        function [] = setInputVariablesForLearner(obj, varargin)
            for i = 1:length(obj.compositeOutputModelLearner)
                obj.compositeOutputModelLearner{i}.setInputVariablesForLearner(varargin{:});
            end
        end
        
        
        function [] = setOutputVariableForLearner(obj, varargin)
            for i = 1:length(obj.compositeOutputModelLearner)
                obj.compositeOutputModelLearner{i}.setOutputVariableForLearner(varargin{:});
            end
        end
        
        function [] = setWeightName(obj, weightName)
            obj.weightName = {weightName};
            for i = 1:length(obj.compositeOutputModelLearner)
                obj.compositeOutputModelLearner{i}.setWeightName(weightName);
            end     
        end    
        
        function [isWeight] = isWeightedLearner(obj)
            isWeight = ~isempty(obj.weightName);
        end
        
        function [weightName] = getWeightName(obj)
            weightName = obj.weightName;
        end
    end
end

