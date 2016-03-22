classdef BicycleBalance < Environments.TransitionFunction %& Sampler.IsActiveStepSampler.IsActiveStepSampler
    properties (Access=protected)
        numContext = 4; %start state
        
        actions = [-2,0;2,0;0,-0.02;0,0.02;0,0]
        initialState = [0 0 0 0];
    end
    
    methods
        function obj =  BicycleBalance(sampler)
            obj@Environments.TransitionFunction(sampler, 4, 2)
            
            obj.dataManager.addDataEntry('contexts', obj.numContext, -ones(obj.numContext,1), ones(obj.numContext,1));
            
            obj.dataManager.setRange('actions', [-2 -0.02], [2 0.02]);
            
            obj.dataManager.setRange('states', [0 0 0 0], [100 100 100 100]);
            obj.dataManager.setRange('nextStates', [0 0 0 0], [100 100 100 100]);
            
            obj.dataManager.addDataEntry('steps.rewards', 1, -Inf, Inf);
            
            obj.addDataManipulationFunction('sampleContext', {}, {'contexts'});
            obj.addDataManipulationFunction('sampleAction', {'states'}, {'actions'});
            obj.addDataManipulationFunction('sampleReward', {'contexts', 'states', 'actions', 'nextStates'}, {'rewards'});
            obj.addDataManipulationFunction('sampleInitState', {'contexts'}, {'states'});
        end
        
        function [] = setInitialStates(obj, initStates)
            obj.initialState = initStates;
        end
        
        function [context] = sampleContext(obj, numElements)
            indexInitialState = randi([1,size(obj.initialState,1)], numElements , 1);
            context = obj.initialState(indexInitialState,:);
        end
        
        function [initialState] = sampleInitState(obj, context)
            initialState = context;
        end
        
        function [action] = sampleAction(obj, state)
            action = randi([1,size(obj.actions,1)],size(state,1) , 1);
        end
        
        
        function [reward] = sampleReward(obj, a, b, c, d)
            old_omega = a(:,1);
            omega = d(:,1);
            reward = (old_omega*15/pi).^2 -(omega*15/pi).^2;   
            %reward =  -(omega*15/pi).^2;   
            
            fallen = abs(omega(:,1)) >= pi/15;
            reward = reward - fallen * 100;
        end
        
        function [nextState] = transitionFunction(obj, state, action, varargin)
            data = [state,action];
            nextState = cell2mat(cellfun(@(data)(obj.applyDynamics(data)), num2cell(data, 2), 'UniformOutput', false));
        end
        
        function [nextState] = applyDynamics(obj, data)
            state = data(1:4);
            action = data(5:6);
            [nextS, ~, ~] = Environments.BicycleBalance.bicycle(state,action,0.02);
            nextState = nextS(1:4);
        end
        
        function value = isActiveStep(obj, states)
            value = abs(states(:,1)) < pi/15;
        end
    end
    
end

