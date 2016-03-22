classdef TimeDependentRewardFunction < RewardFunctions.RewardFunction
    
    properties

    end
    
    methods
        function obj = TimeDependentRewardFunction(dataManager)
           obj = obj@RewardFunctions.RewardFunction(dataManager);
           
           level = dataManager.getDataManagerDepth('steps') - 1;
           obj.dataManager.addDataEntryForDepth(level, 'finalRewards', 1);
           
           obj.registerTimeDependentRewardFunctions();
                                 
        end
        
        function [vargout] = sampleFinalReward(obj, nextStates, timeSteps, varargin)     
            vargout = obj.sampleFinalRewardInternal(nextStates(end, :), timeSteps(end), varargin{:});
        end
        
        function [] = registerTimeDependentRewardFunctions(obj)
            obj.setRewardInputs('states', 'actions', 'nextStates', 'timeSteps')            
            obj.addDataManipulationFunction('sampleFinalReward', {'nextStates', 'timeSteps'}, {'finalRewards'}, false);           
        end
        
    end
    
    methods (Abstract)
        [vargout] = rewardFunction(obj, states, actions, nextStates, timeSteps) 
        [vargout] = sampleFinalRewardInternal(obj, finalState, timeStep)
           
    end
end