classdef QuadraticRewardFunctionSwingUp < RewardFunctions.RewardFunction
    
    properties
           stateCost
           actionCost
           dimStates
           dimActions      
           
           usePerioridicity = false;
    end
    
    methods
        function obj = QuadraticRewardFunctionSwingUp(dataManager)
           obj = obj@RewardFunctions.RewardFunction(dataManager);
           obj.setRewardInputs({'states'},{'actions'});
           
%            %Do we have to do it with the subDataManager?
%            level = dataManager.getDataEntryDepth('states');         
%            obj.dimStates    = dataManager.getSubDataManager.dataEntries('states').numDimensions;
%            obj.dimActions   = dataManager.getSubDataManager.dataEntries('actions').numDimensions;
           
           obj.dimStates    = dataManager.getNumDimensions('states');
           obj.dimActions   = dataManager.getNumDimensions('actions');
           
           obj.stateCost = eye(obj.dimStates);
           obj.actionCost = eye(obj.dimActions);
           
        end
        
        function setStateActionCosts(obj, stateCost, actionCost)
            if(isequal(size(stateCost),[1,1]))

                obj.stateCost = stateCost*eye(obj.dimStates);
            else
                obj.stateCost = stateCost;
            end
            if(isequal(size(actionCost),[1,1]))

                obj.actionCost = actionCost*eye(obj.dimActions);
            else
                obj.actionCost = actionCost;
            end            
           
        end
        
        function [rewards] = rewardFunction(obj, states, actions, varargin)
            height = cos(states(:,1)) - 1;           
            rewards = height * 100 - sum(actions.*(actions*obj.actionCost),2);
            
            diff = (states(:,1) - (-pi / 2));
            diff(diff > pi) = diff(diff > pi) - 2 * pi;
            diff(diff < -pi) = diff(diff < -pi) + 2 * pi;
            diff = diff.^2;
            rewards = rewards - 100 * exp(-diff / (2 * (pi / 8)^2));
        end       
              
    end
    
end