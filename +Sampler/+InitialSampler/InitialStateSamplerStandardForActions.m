classdef InitialStateSamplerStandardForActions < Sampler.InitialSampler.InitialStateSampler
    
    properties(SetObservable,AbortSet)
        InitialStateDistributionMinRange = -1;
        InitialStateDistributionMaxRange = 1;
        
        InitialStateDistributionType = 'Gaussian';
    end
    
    methods
        function [obj] = InitialStateSamplerStandardForActions(dataSampler)
            
                        
            obj = obj@Sampler.InitialSampler.InitialStateSampler(dataSampler);
            obj.linkProperty('InitialStateDistributionMinRange');
            obj.linkProperty('InitialStateDistributionMaxRange');
            
            obj.linkProperty('InitialStateDistributionType');    
            
            dimActions = obj.dataManager.getNumDimensions('actions');
            
            level = obj.dataManager.getDataManagerDepth('steps') - 1;
             
            obj.registerOptionalParameter('initContext', false, dimActions, ones(1, dimActions), ones(1, dimActions), 'contexts', level);
%             obj.registerOptionalParameter('StartVel', false, dimActions, ones(1, dimActions), ones(1, dimActions), 'contexts', level);
 
            obj.setIfNotEmpty('initContext',  zeros(1, dimActions));
%             obj.setIfNotEmpty('StartVel',  zeros(1, dimActions));                                   

        end
    
        function [] = registerInitStateFunction(obj)
            obj.setInputArguments('sampleInitState', {'contexts'});            
        end
        
        function [] = setInitStateFromContext(obj, useContext)
            if (useContext)
                obj.setInputArguments('sampleInitState', {'contexts'});
            else
                obj.setInputArguments('sampleInitState', {});
            end
        end
        
        function [states] = sampleInitState(obj, numElements, varargin)
            numDimTaken = 0;
            dimState = obj.dataManager.getNumDimensions('states');
            states = zeros(numElements, dimState);
            if (~isempty(varargin))
                context = varargin{1};
                numDimTaken = min(size(states, 2), size(context,2));
                
                states(:, 1:numDimTaken) = context(:, 1:numDimTaken);                
            end
            
            minRange = obj.InitialStateDistributionMinRange;
            maxRange = obj.InitialStateDistributionMaxRange;
            
            if (numel(minRange) == 1)
                minRange = ones(1, dimState) * minRange;
                maxRange = ones(1, dimState) * maxRange;
            end
            
            minRange = minRange((numDimTaken + 1):end);
            maxRange = maxRange((numDimTaken + 1):end);
            switch (obj.InitialStateDistributionType)
                case 'Gaussian'
                    randFunc    = @randn;
                    width       = (maxRange - minRange) / 2;
                    offset      =  (maxRange + minRange) / 2;
                    
                case 'Uniform'
                    randFunc    = @rand;
                    width       = maxRange - minRange;
                    offset      = minRange;
            end
          
            states(:, (numDimTaken + 1):end) = bsxfun(@plus, bsxfun(@times, randFunc(numElements, dimState - numDimTaken), width), offset);
        end
    end
end