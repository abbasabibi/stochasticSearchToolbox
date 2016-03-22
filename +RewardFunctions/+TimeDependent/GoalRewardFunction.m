classdef GoalRewardFunction < RewardFunctions.TimeDependent.TimeDependentRewardFunction & RewardFunctions.RewardFunctionSeperateStateActionInterface
    
    properties(SetObservable, AbortSet)
        goalPos
    end
    
    properties
        stateFeatures       = 'states';
        nextStateFeatures   = 'nextStates';
        actionName          = 'actions';
    end
    
    
    methods
        function obj = GoalRewardFunction (dataManager, goalPos, stateFeatures, nextStateFeatures, parameterName)
            
            obj = obj@RewardFunctions.TimeDependent.TimeDependentRewardFunction(dataManager);
            obj = obj@RewardFunctions.RewardFunctionSeperateStateActionInterface();    
            
            if (exist('stateFeatures', 'var'))
                obj.stateFeatures = stateFeatures ;
            end

            if (exist('nextStateFeatures', 'var'))
                obj.nextStateFeatures = nextStateFeatures;
            end
            
            if (exist('parameterName', 'var'))
                obj.actionName = parameterName ;
            end

            
            obj.goalPos = goalPos;
                        
            obj.linkProperty('goalPos');
                                    
            obj.registerTimeDependentRewardFunctions();
        end        

        function [] = registerTimeDependentRewardFunctions(obj) 
            obj.setRewardInputs(obj.stateFeatures, obj.actionName, 'timeSteps', obj.additionalParameters{:});            
            obj.addDataManipulationFunction('sampleFinalReward', {obj.nextStateFeatures, 'timeSteps', obj.additionalParameters{:}}, {'finalRewards'}, false);  
        end
                        
        function [reward, stateReward, actionReward] = rewardFunction(obj, states, actions, timeSteps, varargin)
           reward = ones(size(states,1),1);            
        end
        
        function [vargout] = sampleFinalRewardInternal(obj, finalStates, timeSteps, varargin)
            vargout = 0;
        end
        
    end
end
