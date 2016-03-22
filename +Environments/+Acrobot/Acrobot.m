classdef Acrobot < Environments.TransitionFunction
    
    properties (Access=protected)
        numContext = 4; %start state
        
        initialState = [0 0 0 0]; %TODO: confirm correctness
        
        limitMin = [-pi -4*pi -pi -9*pi];
        limitMax = [pi 4*pi pi 9*pi];
        
        m1 = 1;
        m2 = 1;
        l1 = 1;
        l2 = 1;
        lc1 = 0.5;
        lc2 = 0.5;
        I1 = 1;
        I2 = 1;
        g = 9.8;
        dt = 0.05;
        goalPosition = 1.0;
        
        transitionNoise = 0.2;
    end
    
    methods
        function obj =  Acrobot(sampler)
            obj = obj@Environments.TransitionFunction(sampler,4,1);
            
            obj.dataManager.addDataEntry('contexts', obj.numContext, -ones(obj.numContext,1), ones(obj.numContext,1));
            
            obj.dataManager.setRange('actions', -1, 1);
            
            obj.dataManager.setRange('states', obj.limitMin, obj.limitMax);
            obj.dataManager.setRange('nextStates', obj.limitMin, obj.limitMax);
            
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
            initialState = context(:, 1:4);
        end
        
        function [action] = sampleAction(obj, state)
            action = rand()*2+1;
        end
        
        function [nextState] = transitionFunction(obj, state, torque, varagin)
            nextState = zeros(size(state));
            
            torque(torque < obj.minRangeAction) = obj.minRangeAction;
            torque(torque > obj.maxRangeAction) = obj.maxRangeAction;
                        
            noise = obj.transitionNoise*2*(rand(size(torque))-0.5);
            torque = torque + noise;
                        
            for i=1:4
                d1 = obj.m1 * obj.lc1^2 + obj.m2 * (obj.l1^2+obj.lc2^2+2*obj.l1*obj.lc2*cos(state(:,3))) + obj.I1 + obj.I2;
                d2 = obj.m2 * obj.lc2^2 + obj.l1 * obj.lc2 * cos(state(:,3)) + obj.I2;
                
                phi2 = obj.m2 * obj.lc2 * obj.g * cos(state(:,1)+state(:,3) - pi/2);
                phi1 = -(obj.m2 * obj.l1 * obj.lc2 * state(:,4).^2 .* sin(state(:,3)) - 2 * obj.m2 * obj.l1 * obj.lc2 * state(:,2) .* state(:,4) .* sin(state(:,3))) + (obj.m1 * obj.lc1 + obj.m2 * obj.l2) * obj.g * cos(state(:,1) - pi/2) + phi2;
                
                theta2dd = (torque + (d2./d1) .* phi1 - obj.m2 * obj.l1 * obj.lc2 * state(:,2).^2 .* sin(state(:,3)) - phi2) ./ (obj.m2 * obj.lc2^2 + obj.I2 - (d2.^2)./d1);
                theta1dd = -(d2 .* theta2dd + phi1) ./ d1;
                
                nextState(:,2) = state(:,2) + theta1dd * obj.dt;
                nextState(:,4) = state(:,4) + theta2dd * obj.dt;
                
                nextState(:,1) = state(:,1) + nextState(:,2) * obj.dt;
                nextState(:,3) = state(:,3) + nextState(:,4) * obj.dt;
                
                active = find(obj.isActiveStep(state));
                state(active,:) = nextState(active,:);
            end
            
            nextState = state;
            
            overlimit2 = abs(nextState(:,3))>pi;
            nextState(overlimit2,4) = 0;
            
            overlimit1 = abs(nextState(:,1))>pi;
            nextState(overlimit1,2) = 0;
            
            nextState = bsxfun(@max,nextState,obj.limitMin);
            nextState = bsxfun(@min,nextState,obj.limitMax);
        end
        
        
        function [reward] = sampleReward(obj, context, state, action, nextState)
            reward = -obj.isActiveStep(nextState);
        end
        
        function value = isActiveStep(obj, states)
            firstJointEndHeight = obj.l1 * cos(states(:,1));
            secondJointEndHeight = obj.l2 * sin(pi / 2 - states(:,1) - states(:,3));
            feetH = -(firstJointEndHeight + secondJointEndHeight);
            value = 1-(feetH>obj.goalPosition);
        end
        
    end
    
end

