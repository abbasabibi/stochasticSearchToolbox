classdef QuadraticRewardFunctionSwingUpFiniteHorizon < RewardFunctions.TimeDependent.TimeDependentRewardFunction & RewardFunctions.RewardFunctionSeperateStateActionInterface
    
    properties
        stateCost;
        
        dimStates
        dimActions
        
        
        period  = 2 * pi;
        
    end
    
    properties (SetObservable, AbortSet)
        usePeriodicity = false;
        actionCost = 10^-3;
        discountFactor = 0.995;
    end
    
    methods
        function obj = QuadraticRewardFunctionSwingUpFiniteHorizon(dataManager)
            obj = obj@RewardFunctions.TimeDependent.TimeDependentRewardFunction(dataManager);
            %obj.setRewardInputs({'states'},{'actions'});
            
            obj.dimStates=dataManager.getSubDataManager.dataEntries('states').numDimensions;
            obj.dimActions=dataManager.getSubDataManager.dataEntries('actions').numDimensions;
            
            obj.stateCost = diag(repmat([10, 0], 1, obj.dimStates / 2));
            obj.actionCost = eye(obj.dimActions);
            
            obj.linkProperty('usePeriodicity', 'usePeriodicReward');
            obj.linkProperty('actionCost', 'uFactor');
            obj.linkProperty('discountFactor');            
            
        end
        
        function setStateCosts(obj, stateCost)
            if(isequal(size(stateCost),[1,1]))
                
                obj.stateCost = stateCost*eye(obj.dimStates);
            else
                obj.stateCost = stateCost;
            end
        end
        
        function [rewardsState] = sampleFinalRewardInternal(obj, finalStates, timeSteps, varargin)
            if obj.usePeriodicity
                s = mod(finalStates(:,1),obj.period);
                s(s>pi) = s(s>pi)-2*pi;
                finalStates(:,1) = s;
            else
                %finalStates(abs(finalStates(:,1)) > pi, 1) = pi;
            end
            index = or(finalStates(:,1) > pi, finalStates(:,1) < -  pi);
            finalStates(index, 1) = pi;

            rewardsState = -sum(finalStates.*(finalStates*obj.stateCost),2) / (1 - obj.discountFactor) .* obj.discountFactor .^(timeSteps - 1);
        end
        
        function [rewards, rewardsState, rewardsAction] = rewardFunction(obj, states, actions, nextStates, timeSteps,varargin)
            %rewardPenalty = - (abs(states(:,1)) > 7 / 4 * pi) * 0;
            
            if obj.usePeriodicity
                s = mod(states(:,1),obj.period);
                s(s>pi) = s(s>pi)-2*pi;
                states(:,1) = s;
            end
            
            index = or(states(:,1) > pi, states(:,1) < -  pi );
            states(index, 1) = pi;
            
            rewardsState = -sum(states.*(states*obj.stateCost),2);
            rewardsAction = - sum(actions.*(actions*obj.actionCost),2);
            
            rewards = obj.discountFactor .^ timeSteps .* (rewardsState + rewardsAction);
        end
        
    end
    
end