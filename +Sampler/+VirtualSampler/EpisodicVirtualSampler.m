classdef EpisodicVirtualSampler < Sampler.EpisodeSampler & Learner.Learner
    properties (Access = protected)
        
       
        minReward = -Inf;
                
    end
    
    methods
        function [obj] = EpisodicVirtualSampler( dataManager, episodeSampler)
            if (~Common.Settings().hasProperty('numSamplesVirtual'))
                Common.Settings().setProperty('numSamplesVirtual', 0);
            end
   
            if (~Common.Settings().hasProperty('numInitialSamplesVirtual'))
                Common.Settings().setProperty('numInitialSamplesVirtual', 0);
            end

            
            obj = obj@Sampler.EpisodeSampler(dataManager, 'Virtual');
            obj = obj@Learner.Learner();            
            
            contextPolicy = episodeSampler.contextDistribution;
            parameterPolicy = episodeSampler.parameterPolicy;
            
            obj.dataManager.addDataEntry('isVirtualSample', 1);
            obj.dataManager.addDataEntry('isInitialVirtualSample', 1);
            
            if (~isempty(contextPolicy))
                obj.setContextSampler(contextPolicy);
            end
            
            if (~isempty(parameterPolicy))
                obj.setParameterPolicy(parameterPolicy);
            end
            
            obj.addDataManipulationFunction('sampleReturn', {'parameters'}, {'returns', 'isVirtualSample', 'isInitialVirtualSample'});
            obj.setReturnFunction(obj);
        end
        
        function [append] = appendNewSamples(obj)
            append = false;
        end
               
        function [] = addedData(obj, data, newSampleIndices)
            obj.minReward = min(data.getDataEntry('returns'));
        end
        
        function [returns, isVirtualSample, isInitialVirtualSample] = sampleReturn(obj, parameters)
            numSamples = size(parameters,1);
            
            returns = ones(numSamples,1) * obj.minReward;
            isVirtualSample = true(numSamples,1);
            if (obj.iterIdx == 1)
                isInitialVirtualSample = true(numSamples,1);
            else
                isInitialVirtualSample = false(numSamples,1);
            end
        end
    end
    
end