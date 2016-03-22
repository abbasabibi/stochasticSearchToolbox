classdef EpisodicContextualLearningTask < Common.IASObject & Data.DataManipulator
    
    properties(SetObservable,AbortSet)
        sampleInitContextFunc = 0; 
    end
    
    properties
        
        
        
        minRangeContext
        maxRangeContext
        
        dimContext
    end
    
    methods
        function obj = EpisodicContextualLearningTask( episodeSampler, dimContext)
           obj = obj@Common.IASObject();
           obj = obj@Data.DataManipulator(episodeSampler.getDataManagerForSampler());
           
           obj.dimContext = dimContext;
           obj.dataManager.addDataEntry('contexts', dimContext);
           obj.dataManager.addDataEntry('returns', 1);           
           
           obj.linkProperty('sampleInitContextFunc');
           obj.addDataManipulationFunction('sampleContext', {}, {'contexts'});
           
                                      
        end
        
        function [] = initObject(obj)
           obj.initObject@Common.IASObject();
           [obj.minRangeContext, obj.maxRangeContext] = obj.dataManager.getRange('contexts');
           obj.dimContext = obj.dataManager.getNumDimensions('contexts');
        end
                       
        function [states] = sampleContext(obj, numSamples, varargin)
          
            if (obj.dataManager.getNumDimensions('contexts') > 0)
                switch obj.sampleInitContextFunc
                    case 0
                        states = sampleStatesUniform(obj, numSamples);
                    case 1
                        states = sampleStatesGaussian(obj, numSamples);
                end
            else
                states = zeros(numSamples, 0);
            end

        end
              
        %%
        function [states] = sampleStatesUniform(obj, numSamples)
            minRange = obj.dataManager.getMinRange('contexts');
            maxRange = obj.dataManager.getMaxRange('contexts');
            
            states = bsxfun(@plus, rand(numSamples, size(minRange,2)) .*  ... 
               repmat(maxRange - minRange, numSamples, 1), minRange);
        end
         
        %%
        function [states] = sampleStatesGaussian(obj, numSamples)
            
            minRange = obj.dataManager.getMinRange('contexts');
            maxRange = obj.dataManager.getMaxRange('contexts');
            
            states = repmat((minRange + maxRange) / 2,numSamples,1) + ... 
                    randn(numSamples, obj.dimState) .* repmat((maxRange - minRange)/ 2, numSamples, 1);
            
        end
         
      
         

    end
    
end