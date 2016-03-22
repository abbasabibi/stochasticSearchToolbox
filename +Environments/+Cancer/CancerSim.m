classdef CancerSim < Environments.TransitionFunction %& Sampler.IsActiveStepSampler.IsActiveStepSampler
    
    properties (Access=protected)
        minDosage = 0.1;
        maxDosage = 1;
        a1 = 0.15;
        a2 = 0.1;
        b1 = 1.2;
        b2 = 1.2;
        d1 = 0.5;
        d2 = 0.5;
        c0 = -4;
        c1 = 1;
        c2 = 1;
    end
        
    methods
        function obj =  CancerSim(sampler, map, initialState)
            obj@Environments.TransitionFunction(sampler, 3, 1)
            %obj@Sampler.IsActiveStepSampler.IsActiveStepSampler(sampler.dataManager)
            obj.dataManager.addDataEntry('contexts', 3, [0 0 0], [Inf(1,2),1]);
       
            obj.dataManager.setRange('actions', obj.minDosage, obj.maxDosage);
            
            obj.dataManager.setRange('states', [0 0 0], [Inf(1,2),1]);
            obj.dataManager.setRange('nextStates', [0 0 0], [Inf(1,2),1]);
            
            obj.dataManager.addDataEntry('steps.rewards', 1, 0, Inf);
            
            obj.addDataManipulationFunction('sampleContext', {}, {'contexts'});
            obj.addDataManipulationFunction('sampleAction', {'states'}, {'actions'});
            obj.addDataManipulationFunction('sampleReward', {'contexts', 'states', 'actions', 'nextStates'}, {'rewards'});
            obj.addDataManipulationFunction('sampleInitState', {'contexts'}, {'states'});
        
            obj.setInputArguments('transitionFunction',{'states', 'actions','contexts'});
        end
        
        function [] = setInitialStates(obj, initStates)
            obj.initialState = initStates;
        end
        
        function [context] = sampleContext(obj, numElements)
            context = [rand(1,2)*2, 0]; %size, tox, dead
            context = repmat(context,numElements,1); %same start for each patient in each iteration
        end
        
        function [initialState] = sampleInitState(obj, context)
            initialState = context(:, :);
        end
        
        function [action] = sampleAction(obj, state)
            action = rand(size(state,1),1)*(obj.maxDosage-obj.minDosage)+obj.minDosage;
        end
        
        
        function [reward] = sampleReward(obj, context, state, action, nextState)
            reward = ~nextState(:,3);
        end
                
        function [nextState] = transitionFunction(obj, state, action, context, varargin)
            deltaSize = (obj.a1*max(state(:,2), context(:,2))-obj.b1*(action-obj.d1)).*(state(:,2)>0);
            sizeNew = max(0,state(:,1)+deltaSize);
            deltaTox = obj.a2*max(sizeNew, context(:,1))+obj.b2*(action-obj.d2);
            tox = max(0,state(:,2)+deltaTox);
            pDead = (1-exp(-(exp(obj.c0+obj.c1*sizeNew+obj.c2*tox))));
            nextState = [sizeNew,tox,pDead>rand(size(pDead,1),1)];
        end
        
        function value = isActiveStep(obj, states)
            value = ~states(:,3);
        end

    end
    
end

