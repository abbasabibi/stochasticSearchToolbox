classdef BalancingRewardFunction < RewardFunctions.RewardFunction & Sampler.IsActiveStepSampler.IsActiveNumSteps
    
    properties
                      
                               
    end
    
    properties (SetObservable, AbortSet)
        actionCosts
    end
    
    methods
        function obj = BalancingRewardFunction(dataManager)
           obj = obj@RewardFunctions.RewardFunction(dataManager);
           obj = obj@Sampler.IsActiveStepSampler.IsActiveNumSteps(dataManager, 'timeSteps');
           obj.registerRewardFunction();
           obj.setRewardInputs({'jointPositions'},{'nextStates'}, {'actions'});
                      
           dimActions = dataManager.getNumDimensions('actions');
           obj.actionCosts = ones(1, dimActions) * 10^-4;
           obj.linkProperty('actionCosts');           
        end
        
      
        
        function [rewards] = rewardFunction(obj, jointPositions, nextStates, actions, varargin)        
                        
            jointPositions = mod(jointPositions, 2 * pi); 
            jointPositions(jointPositions > pi) = jointPositions(jointPositions  > pi) - 2 * pi;
            
            rewards = -sum(jointPositions.^2,2);                                    
            rewards = rewards - sum(bsxfun(@times, actions.^2, obj.actionCosts),2);
            
            fallen = obj.isFallen(nextStates);
            rewards = rewards - 100 * fallen;
        end 
        
        function [fallen] = isFallen(obj, nextStates)
            fallen = any(abs(nextStates(:, 1:2:end)) > pi / 4, 2); 
        end
        
        function [isActive] = isActiveStep(obj, nextStates, timeSteps)
            isActive = obj.isActiveStep@Sampler.IsActiveStepSampler.IsActiveNumSteps(nextStates, timeSteps);
            isActive = and(isActive, ~ obj.isFallen(nextStates));
        end
              
    end
    
end