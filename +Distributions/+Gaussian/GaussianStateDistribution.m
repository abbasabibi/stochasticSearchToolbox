classdef GaussianStateDistribution <  Distributions.Gaussian.GaussianLinearInFeatures    
    methods
        
        function obj = GaussianStateDistribution(dataManager)
            superargs = {};
            if (nargin >= 1)
                superargs = {dataManager, 'states', '', 'GaussianState'};
            end
            
            obj = obj@Distributions.Gaussian.GaussianLinearInFeatures(superargs{:});
            obj.addDataFunctionAlias('sampleInitState', 'sampleFromDistribution');
        end                
    end
end
