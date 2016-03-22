classdef QuadraticRewardFunction < RewardFunctions.RewardFunction & RewardFunctions.RewardFunctionSeperateStateActionInterface
    
    properties
        stateCost
        
        dimStates
        dimActions
        
        usePerioridicity = false;
        period  = 2 * pi;
    end
    
    properties (SetObservable, AbortSet)
        usePeriodicity = false;
        actionCost = 10^-3;
    end
    
    methods
        function obj = QuadraticRewardFunction(dataManager)
            obj = obj@RewardFunctions.RewardFunction(dataManager);
            obj.setRewardInputs({'states'},{'actions'});
            
            obj.dimStates=dataManager.getSubDataManager.dataEntries('states').numDimensions;
            obj.dimActions=dataManager.getSubDataManager.dataEntries('actions').numDimensions;
            
            obj.stateCost = eye(obj.dimStates);
            obj.actionCost = eye(obj.dimActions);
            
            obj.linkProperty('usePeriodicity', 'usePeriodicReward');
            obj.linkProperty('actionCost', 'uFactor');
            
            
        end
        
        function setStateCosts(obj, stateCost)
            if(isequal(size(stateCost),[1,1]))
                
                obj.stateCost = stateCost*eye(obj.dimStates);
            else
                obj.stateCost = stateCost;
            end
            
            
        end
        
        function setActionCosts(obj, actionCost)
            if(isequal(size(actionCost),[1,1]))
                
                obj.actionCost = actionCost*eye(obj.dimActions);
            else
                obj.actionCost = actionCost;
            end
        end
        
        function setStateActionCosts(obj, stateCost, actionCost)
            obj.setActionCosts(actionCost);
            obj.setStateCosts(stateCost);
        end
        
        function [rewards, rewardsState, rewardsAction] = rewardFunction(obj, states, actions, varargin)
            if obj.usePerioridicity
                s = mod(states(:,1),obj.period);
                s(s>pi) = s(s>pi)-2*pi;
                states(:,1) = s;
            end
            rewardsState = -sum(states.*(states*obj.stateCost),2);
            rewardsAction = - sum(actions.*(actions*obj.actionCost),2);
            
            rewards = rewardsState + rewardsAction;
        end
        
    end
    
end