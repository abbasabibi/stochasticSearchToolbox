classdef CloneLinearTransformFeatureGenerator < Learner.Learner
    %CLONELINEARTRANSFORMFEATURELEARNER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        linearTransformFeatureGenerator
        baseLinearTransformFeatureGenerator
    end
    
    methods
        function obj = CloneLinearTransformFeatureGenerator(linearTransformFeatureGen, baseLinearTransformFeatureGen)
            obj = obj@Learner.Learner();
            
            obj.linearTransformFeatureGenerator = linearTransformFeatureGen;
            obj.baseLinearTransformFeatureGenerator = baseLinearTransformFeatureGen;
        end
        
        function obj = updateModel(obj, ~)
            obj.linearTransformFeatureGenerator.setM(obj.baseLinearTransformFeatureGenerator.M);
        end
    end
    
end

