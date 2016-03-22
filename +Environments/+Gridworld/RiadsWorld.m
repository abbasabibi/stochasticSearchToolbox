classdef RiadsWorld < Environments.Gridworld.GenericGridWorld
    
    properties (Access=protected)
        riadActions = [0,0;0,-1;1,0;0,1;-1,0] %1=stay
        normalizer;
    end
    
    properties (SetObservable)
        discountFactor;
        numTimeSteps;
    end
    
    methods
        function obj =  RiadsWorld(sampler)
            map = {1/16,1/8,1/4,1/2,1;
                1/32,1/16,1/8,1/4,1/2;
                1/64,1/32,1/16,1/8,1/4;
                1/128,1/64,1/32,1/16,1/8;
                1/256,1/128,1/64,1/32,1/16};
            initialState = [3,3];
            
            obj = obj@Environments.Gridworld.GenericGridWorld(sampler, map, initialState);
            
            obj.linkProperty('numTimeSteps');
            obj.linkProperty('discountFactor');
            
            obj.normalizer = norm(cell2mat(obj.map),2);
            obj.normalizer = obj.normalizer * (1 - power(obj.discountFactor, obj.numTimeSteps+ 1)) / (1 - obj.discountFactor);
        end
        
        function [reward] = sampleReward(obj, context, state, action, nextState)
            reward = cell2mat(obj.map(transpose(obj.getIndexByGrid(nextState))))/obj.normalizer;
        end
        
        function [nextState] = transitionFunction(obj, state, action, varargin)
            noiseAction = action.*(randi(2,size(action))-1);
            noiseAction(noiseAction==0)=1;
            nextState = obj.transitionFunction@Environments.Gridworld.GenericGridWorld(state,noiseAction,varargin);
        end
        
        function [actions] = getActions(obj)
            actions = obj.riadActions;
        end
        
    end
    
end

