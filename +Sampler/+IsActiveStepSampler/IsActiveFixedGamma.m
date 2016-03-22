classdef IsActiveFixedGamma < Sampler.IsActiveStepSampler.IsActiveStepSampler
    %ISACTIVENUMSTEPS is active until numSteps is reached
    
    properties(SetObservable,AbortSet)
        resetProb = 0.1;
        resetProbName 
    end
    
    methods
        function obj = IsActiveFixedGamma(dataManager, nameSteps)
            if (~exist('nameSteps', 'var'))
                nameSteps = 'timeSteps';
            end
            obj@Sampler.IsActiveStepSampler.IsActiveStepSampler(dataManager, nameSteps);
            obj.resetProbName = ['resetProb', upper(nameSteps(1)), nameSteps(2:end)];
            obj.linkProperty('resetProb', obj.resetProbName );
        end
        
        function isActive = isActiveStep(obj, ~, timeSteps)
            isActive = rand(size(timeSteps)) > obj.resetProb;
        end
        function numTimeSteps = toReserve(obj)
            numTimeSteps = ceil((1-obj.resetProb)/obj.resetProb);
        end
    end
    
end

