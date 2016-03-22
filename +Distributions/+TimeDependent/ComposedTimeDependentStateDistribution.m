classdef ComposedTimeDependentStateDistribution < Distributions.TimeDependent.ComposedTimeDependentDistribution
    %%% not necessary yet... delete?
    properties (SetAccess = protected)
    end
    
    properties (SetObservable,AbortSet)
    end
    
    methods
        %%
        function obj = ComposedTimeDependentStateDistribution(dataManager, distributionInitializer)            
            superargs = {};
            if (nargin > 1)
                superargs = {dataManager, distributionInitializer};
            end
            obj = obj@Distributions.TimeDependent.ComposedTimeDependentDistribution(superargs{:});
        end
        
        function dist = getDistributionForTimeStep(obj, timeStep) 
            dist = obj.distributionPerTimeStep{timeStep};
        end
        
    end    
    
end