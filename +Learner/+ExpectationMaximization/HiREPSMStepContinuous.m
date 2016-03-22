classdef HiREPSMStepContinuous < Learner.ExpectationMaximization.ExpectationMaximization
    %ESTEP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        
        
        function obj = HiREPSMStepContinuous(dataManager, mixtureModel, mixtureModelLearner, varargin)
            obj = obj@Learner.ExpectationMaximization.ExpectationMaximization(dataManager, mixtureModel, mixtureModelLearner, varargin{:});
            
            outputVar   = obj.mixtureModel.getOutputVariable();
            subManager  = dataManager.getDataManagerForEntry(outputVar);
        end
        
        
        
        
        function [] = MStep(obj, data, EMData)
            
           
            
            
        end
        
        
  
        
    end
    
end