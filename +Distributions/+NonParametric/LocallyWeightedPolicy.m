classdef LocallyWeightedPolicy < Distributions.NonParametric.LocallyWeightedGaussian
    %LOCALLYWEIGHTEDPOLICY
    % policy based on the locally weighted gaussian regressor
    
    
    methods
        function obj = LocallyWeightedPolicy(dataManager, kernel)

            obj = obj@Distributions.NonParametric.LocallyWeightedGaussian(dataManager, kernel, 'actions', 'states');

            obj.addDataFunctionAlias('sampleAction', 'sampleFromDistribution');
        end
        

      

    end
    
end

