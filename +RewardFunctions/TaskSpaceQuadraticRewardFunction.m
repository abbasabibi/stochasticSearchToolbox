classdef TaskSpaceQuadraticRewardFunction < RewardFunctions.RewardFunction
    
    properties
           stateCost
           actionCost
           dimStates
           dimActions
           posFeatures
           planarKinematics
           desiredPosition
           velFeatures
    end
    
    methods
        function obj = TaskSpaceQuadraticRewardFunction(dataManager,planarKinematics)
           % Task space quadratic reward for planar robots
           
           obj = obj@RewardFunctions.RewardFunction(dataManager);
           obj.posFeatures = Environments.Misc.PlanarKinematicsEndEffPositionFeature(dataManager, planarKinematics);
           obj.velFeatures = Environments.Misc.PlanarKinematicsEndEffVelocityFeature(dataManager, planarKinematics);
           obj.planarKinematics = planarKinematics;
           obj.dimStates=2; %planar, so always x-y
           obj.dimActions=dataManager.getSubDataManager.dataEntries('actions').numDimensions;
           
           obj.stateCost = eye(obj.dimStates);
           obj.actionCost = eye(obj.dimActions);
           obj.setRewardInputs({'endEffPositions'},{'actions'})
           obj.desiredPosition = [0,0];
        end
        
        function setStateActionCosts(obj, stateCost, actionCost)
            if(isequal(size(stateCost),[1,1]))

                obj.stateCost = stateCost*eye(obj.dimStates);
            elseif(numel(stateCost)==2 )
                obj.stateCost = diag(stateCost);
            else
                obj.stateCost = stateCost;
            end
            if(isequal(size(actionCost),[1,1]))

                obj.actionCost = actionCost*eye(obj.dimActions);
            else
                obj.actionCost = actionCost;
            end            
           
        end
        
        function setDesiredPosition(obj, despos)
            obj.desiredPosition = despos;
        end
        
        function [rewards] = rewardFunction(obj, endEffPosition, actions, varargin) 
            %jointPositions = states(:, 1:2:end);
            %endEffPosition = obj.planarKinematics.getForwardKinematics(jointPositions);
            relEEPosition = bsxfun(@minus, endEffPosition, obj.desiredPosition);
            
            rewards = -sum(relEEPosition.*(relEEPosition*obj.stateCost),2);
            rewards = rewards - sum(actions.*(actions*obj.actionCost),2);
        end       
              
    end
    
end