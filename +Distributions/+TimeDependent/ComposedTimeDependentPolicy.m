classdef ComposedTimeDependentPolicy < Distributions.TimeDependent.ComposedTimeDependentDistribution
    properties (SetAccess = protected)
    end
    
    properties (SetObservable,AbortSet)
    end
    
    methods
        %%
        function obj = ComposedTimeDependentPolicy(dataManager, distributionInitializer)
            
            superargs = {};
            if (nargin > 1)
                superargs = {dataManager, distributionInitializer};
            end
            obj = obj@Distributions.TimeDependent.ComposedTimeDependentDistribution(superargs{:});
            %obj.addDataFunctionAlias('sampleAction', 'sampleFromDistribution');
        end
        
          
        function [] = setAdditionalNoiseProvider(obj, additionalNoiseProvider)
            for i = 1:obj.numModels
                obj.distributionPerTimeStep{i}.setAdditionalNoiseProvider(additionalNoiseProvider);
            end 
        end
        
        function dist = getDistributionForTimeStep(obj, timeStep) 
            dist = obj.distributionPerTimeStep{timeStep};
        end
        
    end    
    
end