classdef InitialContextSamplerStandard < Sampler.InitialSampler.InitialContextSampler
    
    properties(SetObservable,AbortSet)
        InitialContextDistributionWidth = 1;
        InitialContextDistributionType = 'Gaussian';
    end
    
    methods
        function [obj] = InitialContextSamplerStandard(dataSampler)
            
            obj = obj@Sampler.InitialSampler.InitialContextSampler(dataSampler);
                        
            obj.linkProperty('InitialContextDistributionWidth');
            obj.linkProperty('InitialContextDistributionType');
            
        end
    
        function [contexts] = sampleContext(obj, numElements)
            
            minRange = obj.dataManager.getMinRange('contexts');
            maxRange = obj.dataManager.getMaxRange('contexts');
            
            dimContext = obj.dataManager.getNumDimensions('contexts');
            switch (obj.InitialContextDistributionType)
                case 'Gaussian'
                    contexts = bsxfun(@plus, bsxfun(@times, randn(numElements, dimContext), (maxRange - minRange) * obj.InitialContextDistributionWidth), (maxRange + minRange) / 2);

                case 'Uniform'
                    contexts = bsxfun(@plus, bsxfun(@times, rand(numElements, dimContext), (maxRange - minRange) * obj.InitialContextDistributionWidth), minRange);
            end
            
        end
    end
end