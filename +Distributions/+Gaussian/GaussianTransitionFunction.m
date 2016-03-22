classdef GaussianTransitionFunction <  Distributions.Gaussian.GaussianLinearInFeatures    
    methods
        
        function obj = GaussianTransitionFunction(dataManager)
            superargs = {};
            if (nargin >= 1)
                superargs = {dataManager, 'nextStates', {{'states', 'restrictedActions'}}, 'GaussianTransition'};
            end
            
            obj = obj@Distributions.Gaussian.GaussianLinearInFeatures(superargs{:});
            obj.addDataFunctionAlias('sampleNextState', 'sampleFromDistribution');            
        end                
    end
end
