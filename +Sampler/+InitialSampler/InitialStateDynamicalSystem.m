classdef InitialStateDynamicalSystem < Sampler.InitialSampler.InitialStateSampler & Data.OptionalParameterInterface
    
    properties(SetObservable,AbortSet)
    end
    
    methods
        function [obj] = InitialStateDynamicalSystem(dataSampler)
            
            obj = obj@Sampler.InitialSampler.InitialStateSampler(dataSampler);
            numJoints = obj.dataManager.getNumDimensions('jointPositions');
            
            obj.registerOptionalParameter('StartPos', false, numJoints, -3.14 * ones(1, numJoints), 3.14 * ones(1, numJoints), 'contexts');
            obj.registerOptionalParameter('StartVel', false, numJoints, -10 * ones(1, numJoints), 10 * ones(1, numJoints), 'contexts');
 
            obj.setIfNotEmpty('StartPos',  zeros(1, numJoints));
            obj.setIfNotEmpty('StartVel',  zeros(1, numJoints));   
            
            obj.registerInitStateFunction();
        end
            
        function [states] = sampleInitState(obj, numElements, varargin)
            obj.inputParameterDeMux(varargin);
            numJoints = obj.dataManager.getNumDimensions('jointPositions');
            
            states = zeros(numElements, obj.getDataManager.getNumDimensions('states'));
            if (size(obj.StartPos,1) == 1 && numElements > 1)
                states(:, 1:2:2  * numJoints) = repmat(obj.StartPos, numElements, 1);
            else
                states(:, 1:2: 2 * numJoints) = obj.StartPos;
            end
            
            if (size(obj.StartVel,1) == 1 && numElements > 1)
                states(:, 2:2: 2 * numJoints) = repmat(obj.StartVel, numElements, 1);
            else
                states(:, 2:2: 2 * numJoints) = obj.StartVel;
            end
        end
    end
end