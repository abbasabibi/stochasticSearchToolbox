classdef ExpQuadEuclidRewardFunction < RewardFunctions.RewardFunction
    
    properties
           a_factor;
           environment;
           desired_state_ts;
    end
    
    methods
        function obj = ExpQuadEuclidRewardFunction(dataManager, environment)
           obj = obj@RewardFunctions.RewardFunction(dataManager);
           
           
           %obj.dimStates=dataManager.getSubDataManager.dataEntries('states').numDimensions;
           %obj.dimActions=dataManager.getSubDataManager.dataEntries('actions').numDimensions;
           
           obj.a_factor= 1; %factor of euclidean distance
           obj.environment = environment;
        end
        
        function setAFactor(obj, aFactor)
            obj.a_factor = aFactor;          
           
        end
        
        function setDesiredStates(obj, desiredState_ts)
            obj.desired_state_ts = desiredState_ts;
        end
        
        function [rewards] = rewardFunction(obj, states, ~, varargin)   
            theta = states(:,[1,3]);
            [task_space] = obj.environment.getForwardKinematics(theta, 2);
            rewards = exp(-0.5* obj.a_factor^(-2) * sum(bsxfun(@minus, task_space, obj.desired_state_ts).^2,2));
            
            
        end       
              
    end
    
end