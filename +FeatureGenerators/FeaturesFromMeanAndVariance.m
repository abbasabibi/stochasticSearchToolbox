classdef FeaturesFromMeanAndVariance < Common.IASObject
    properties
    end
    
    methods
        function [obj] = FeaturesFromMeanAndVariance()
            obj = obj@Common.IASObject();                        
        end
                
    end
    
    methods (Abstract)
        [features] = getFeaturesFromMeanAndVariance(obj, meanStates, covaranceMatrices);        
    end
    
end


