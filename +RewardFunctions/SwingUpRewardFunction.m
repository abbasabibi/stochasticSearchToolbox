classdef SwingUpRewardFunction < RewardFunctions.RewardFunction
    
    properties
                      
           taskSpaceFeatureGenerator;                      
    end
    
    properties (SetObservable, AbortSet)
        actionCosts
    end
    
    methods
        function obj = SwingUpRewardFunction(dataManager, planarKinematics)
           obj = obj@RewardFunctions.RewardFunction(dataManager);
           obj.taskSpaceFeatureGenerator = Environments.Misc.PlanarKinematicsEndEffPositionFeature(dataManager, planarKinematics);                     
           
           obj.setRewardInputs({'endEffPositions'},{'actions'});
                      
           dimActions = dataManager.getNumDimensions('actions');
           obj.actionCosts = ones(1, dimActions) * 10^-4;
           obj.linkProperty('actionCosts');           
        end
        
      
        
        function [rewards] = rewardFunction(obj, endEffPositions, actions, varargin)        
                        
            rewards = -sum(endEffPositions.^2,2);                                    
            rewards = rewards - sum(bsxfun(@times, actions.^2, obj.actionCosts),2);
        end       
              
    end
    
end