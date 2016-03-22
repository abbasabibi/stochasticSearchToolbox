classdef ClassicMountainCar < Environments.TransitionFunction
    
    properties (Access=protected)
        numContext = 2; %start state
                   
        initialState = [-0.5 0]; %TODO: confirm correctness
        goalPosition = 0.5;
        
        limitPosition = [-1.2 0.6];
        limitVelocity = [-0.07 0.07];
        
        accelFactor = 0.001;
        gravityFactor = -0.0025;
        hillPeakFreq = 3.0;
        
        transitionNoise = 0.2;
    end
    
    methods
        function obj =  ClassicMountainCar(sampler)
            obj = obj@Environments.TransitionFunction(sampler,2,1);
            
            obj.dataManager.addDataEntry('contexts', obj.numContext, -ones(obj.numContext,1), ones(obj.numContext,1));
            
            obj.dataManager.setRange('actions', -1, 1);
            
            obj.dataManager.setRange('states', [obj.limitPosition(1),obj.limitVelocity(1)], [obj.limitPosition(2),obj.limitVelocity(2)]);
            obj.dataManager.setRange('nextStates', [obj.limitPosition(1),obj.limitVelocity(1)], [obj.limitPosition(2),obj.limitVelocity(2)]);
            
            obj.dataManager.addDataEntry('steps.rewards', 1, -1, 1);
            
            
            obj.addDataManipulationFunction('sampleContext', {}, {'contexts'});
            obj.addDataManipulationFunction('sampleAction', {'states'}, {'actions'});
            obj.addDataManipulationFunction('sampleReward', {'contexts', 'states', 'actions', 'nextStates'}, {'rewards'});
            obj.addDataManipulationFunction('sampleInitState', {'contexts'}, {'states'});
            
        end
        
        function [context] = sampleContext(obj, numElements)
            context = repmat(obj.initialState,[numElements 1]);
        end
        
        function [initialState] = sampleInitState(obj, context)
            initialState = context(:, 1:2);
        end
        
        function [action] = sampleAction(obj, state)
            action = rand()*2+1;
        end
        
        function [nextState] = transitionFunction(obj, state, action, varagin)
            %transition
            noise = 2*obj.accelFactor*obj.transitionNoise*(randn(size(action))-0.5);
            nextVelocity = state(:,2)+noise+action*obj.accelFactor+cos(obj.hillPeakFreq*state(:,1))*obj.gravityFactor;
            nextState = [state(:,1)+nextVelocity,nextVelocity];
            %limits
            nextState = [min(obj.limitPosition(2),nextState(:,1)),min(obj.limitVelocity(2),nextState(:,2))];
            %nextState = [max(obj.limitPosition(1),nextState(:,1)),max(obj.limitVelocity(1),nextState(:,2))];
            nextState = [nextState(:,1),max(obj.limitVelocity(1),nextState(:,2))];
            %stop at end
            %nextState = [nextState(:,1),(1-(nextState(:,1)==obj.limitPosition(1))).*nextState(:,2)];
        end
        
        
        function [reward] = sampleReward(obj, context, state, action, nextState)
            reward = (nextState(:,1)>obj.goalPosition)-1;
        end
        
        function value = isActiveStep(obj, states)
            value = 1-(states(:,1)>obj.goalPosition);
        end
        
    end
    
end

