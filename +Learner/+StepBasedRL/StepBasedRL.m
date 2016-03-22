classdef StepBasedRL < Learner.RLLearner & Data.DataManipulator
    
    properties                                
        policyLearner;
    end
    
    % Class methods
    methods
        function obj = StepBasedRL(dataManager, policyLearner)
            obj = obj@Learner.RLLearner();
            obj = obj@Data.DataManipulator(dataManager);
                     
            if (exist('policyLearner', 'var'))
                obj.policyLearner = policyLearner;
            end
            obj.addDataPreprocessor(DataPreprocessors.RewardToComePreprocessor(dataManager));
        end
        
        
        function [] = updateModel(obj, data)
            % iterate over episodes            
            obj.preparePolicyUpdate(data);
            if (~isempty(obj.policyLearner))
                obj.policyLearner.updateModel(data);
            end                  
        end        
        
    end
    
    methods(Abstract)
        [] = preparePolicyUpdate(obj, data);
    end        
end
