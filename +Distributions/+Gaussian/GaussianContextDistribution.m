classdef GaussianContextDistribution <  Distributions.Gaussian.GaussianLinearInFeatures    
    methods
        
        function obj = GaussianContextDistribution(dataManager)
            superargs = {};
            if (nargin >= 1)
                superargs = {dataManager, 'contexts', '', 'GaussianContext'};
            end
            
            obj = obj@Distributions.Gaussian.GaussianLinearInFeatures(superargs{:});
            obj.addDataFunctionAlias('sampleContext', 'sampleFromDistribution');
        end                
    end
end
