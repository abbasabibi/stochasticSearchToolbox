classdef GoalAttractor < TrajectoryGenerators.TrajectoryTracker.ConstantTrajectoryTracker
        
    properties(SetObservable, AbortSet)    
       pGain = 100;
       dGain = sqrt(100);
       numStepsPerDecision = 2;
       currStep = 1;
    end
    
    methods
              
        function obj = GoalAttractor (dataManager, numParams) 
            obj = obj@TrajectoryGenerators.TrajectoryTracker.ConstantTrajectoryTracker(dataManager, numParams); 
            
            level = obj.dataManager.getDataManagerDepth('steps') - 1;
            obj.dataManager.addDataEntryForDepth(level,'parameters', numParams);
            obj.dataManager.addDataEntryForDepth(level,'contexts', 2); %is this always the same?
            
            obj.addDataManipulationFunction('isActiveStep', {'states', 'nextStates'}, {'isActive'});
            obj.linkProperty('numStepsPerDecision');
            
        end     
              
        function [] = registerTrackingFunction(obj)
            obj.addDataManipulationFunction('getTrackingControl', {'states', 'parameters'}, {'actions'});
            obj.addDataFunctionAlias('sampleAction','getTrackingControl');
        end 
        
         
        function actions = getTrackingControl(obj, states, parameters)
            actions = obj.pGain * (parameters - states(:,1:2:end)) +...
                obj.dGain * (- states(:,2:2:end));
%                 obj.dGain * (parameters(2:2:end)' - states(:,2:2:end));
                
        end
              
        
        %%
        function value = isActiveStep(obj, states, ~)
            if(obj.currStep < obj.numStepsPerDecision)
                value = true(size(states,1),1);
                obj.currStep = obj.currStep +1;
            else
                value = false(size(states,1),1);
                obj.currStep = 1;
            end
              
        end
        
        
        %%
        function value = toReserve(obj)
            value = 50;
        end
        
    end        
    
                  
end