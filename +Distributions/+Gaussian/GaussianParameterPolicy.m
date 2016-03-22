classdef GaussianParameterPolicy <  Distributions.Gaussian.GaussianLinearInFeatures    
    methods
        
        
        
        function obj = GaussianParameterPolicy(dataManager, outputVar, inputVar, policyName)
            if(~exist('inputVar', 'var'))
                outputVar   = 'parameters';
                inputVar    = 'contexts';
                policyName  = 'GaussianParameter';
            end
            
            superargs = {};
            if (nargin >= 1)
                superargs = {dataManager, outputVar, {inputVar}, policyName};
            end
            
            obj = obj@Distributions.Gaussian.GaussianLinearInFeatures(superargs{:});
            if (nargin>=1)
                obj.addDataFunctionAlias('sampleParameter', 'sampleFromDistribution');
            end            
        end                
    end
end
