classdef IsActiveEnvironment < Sampler.IsActiveStepSampler.IsActiveStepSampler
    %ISACTIVENUMSTEPS is active until numSteps is reached
    
    properties(SetObservable,AbortSet)
        sampler1, sampler2;
    end
    
    methods
        function obj = IsActiveEnvironment(dataManager,sampler1,sampler2)
            obj = obj@Sampler.IsActiveStepSampler.IsActiveStepSampler(dataManager);
            obj.sampler1=sampler1;
            obj.sampler2=sampler2;
        end
        
        function isActive = isActiveStep(obj, nextStates, timeSteps)
            isActive = obj.sampler1.isActiveStep(nextStates, timeSteps) & obj.sampler2.isActiveStep(nextStates);
        end
        
        function numTimeSteps = toReserve(obj)
            numTimeSteps = obj.sampler1.toReserve();
        end
        
        function [] = setNumTimeSteps(obj,steps)
            obj.sampler1.setNumTimeSteps(steps);
        end
    end
    
end

