classdef InitialStateSamplerConstant < Sampler.InitialSampler.InitialStateSampler
    
    properties (SetObservable, AbortSet)
        initialState
    end
    
    methods
        function [obj] = InitialStateSamplerConstant(dataSampler)
            obj = obj@Sampler.InitialSampler.InitialStateSampler(dataSampler);
            
            obj.linkProperty('initialState');
        end
    end
    
    methods
        function [states] = sampleInitState(obj, numElements, varargin)
            initState = obj.initialState;
            if size(initState,1) ~= 1
                initState = initState';
            end
            states = repmat(initState,numElements,1);
        end
    end
end