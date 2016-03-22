classdef SequentialResetSampler < Sampler.Sampler
    properties (Access = protected)
    end
    
    properties(SetObservable,AbortSet)

    end
    
    methods
        
        function [obj] = SequentialResetSampler(dataManager, samplerName)
            obj = obj@Sampler.Sampler(dataManager, samplerName);
        end
                                                                    
        function [] = createSamples(obj, data, varargin)
            layerIndex = varargin;
            
            reservedStorage = toReserve();
            data.reserveStorage(reservedStorage, layerIndex{:});
            
            activeIndex = layerIndex;
            activeIndex{length(varargin) + 1} = 1;
            
            
            obj.initSamples(data, activeIndex{:});
            
            it = 1;
            while(numel(activeIndex{end-1}) >= 1)
                if( it > reservedStorage)
                    reservedStorage = reservedStorage*2;
                    data.reserveStorage(reservedStorage, activeIndex{1:end-1}); 
                end
                
                activeIndex{end} = it ;
                activeIndex = obj.createSamplesForStep(data, activeIndex{:});
                obj.endTransition(data, activeIndex);                
                it = it + 1;
            end     
            adjustReservedStorage();
            
            
        end
                               
        function [numSamples] = getNumSamples(obj, data, index)
            numSamples = obj.numTimeSteps;
        end
    end
    
    methods (Abstract, Access=protected)        
         numSamples = toReserve(obj)
         [] = endTransition(obj, data, varargin)
         [] = initSamples(obj, data, varargin)
         [] = createSamplesForStep(obj, data, varargin)
         [] = adjustReservedStorage(obj, data, varargin)
         [ActiveIdxs] = selectActiveIdxs(obj, data, varargin)
    end
        
end