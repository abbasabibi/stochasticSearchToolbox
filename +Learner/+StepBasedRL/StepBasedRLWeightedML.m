classdef StepBasedRLWeightedML < Learner.StepBasedRL.StepBasedRL
    
    properties
        outputWeightName
        additionalInputData = {};
    end
    
    % Class methods
    methods
        function obj = StepBasedRLWeightedML(dataManager, policyLearner)
            obj = obj@Learner.StepBasedRL.StepBasedRL(dataManager, policyLearner);                       
            
            obj.outputWeightName = 'rewardWeighting';
            
            if (~isempty(obj.policyLearner))
                obj.policyLearner.setWeightName(obj.outputWeightName);
            end
            
            obj.dataManager.addDataEntry(['steps.',obj.outputWeightName] , 1);
        end
                
        function [] = setWeightName(obj, outputWeightName)
            obj.outputWeightName = outputWeightName;
            obj.registerWeightingFunction();
        end
        

    end
         

end
