classdef FourierKernelFeatures < FeatureGenerators.FeatureGenerator & Learner.ParameterOptimization.HyperParameterObject
    properties
        kernel
        randomStream
        featureTag = 1
       
    end
    
    methods
        function [obj] = FourierKernelFeatures(dataManager, kernel, numFeatures, featureVariables, featurename)
            if(~exist('featurename','var'))
                featurename = kernel.kernelName;
            end
            %featureVariables = kernel.featureVariables;
            %stateIndices = kernel.stateIndices;
            obj = obj@FeatureGenerators.FeatureGenerator(dataManager, featureVariables, featurename, ':', numFeatures);

            obj.kernel = kernel;
            
            obj.randomStream = RandStream('mt19937ar','Seed',101);
            
                        
        end
        
        function [features] = getFeaturesInternal(obj, ~, inputMatrix)
            %make sure we always start with the same rng
            obj.randomStream.reset();
            
            %get numfeatures by dim matrix
            %w = obj.kernel.getFourierSamples(obj.numFeatures, obj.randomStream);
            projected = obj.kernel.getFourierProjection(obj.numFeatures, obj.randomStream, inputMatrix);
            % get numfeature by 1 vector
            b = obj.randomStream.rand(obj.numFeatures,1 ) * 2*pi;
            
            features = sqrt(2/obj.numFeatures) * cos(bsxfun(@plus, projected, b')); 
                        

        end
        
        function setHyperParameters(obj, params)
            obj.kernel.setHyperParameters(params);
        end
        
        function params = getHyperParameters(obj)
            params = obj.kernel.getHyperParameters();
        end
        
        function [numParameters] = getNumHyperParameters(obj)
            numParameters = obj.kernel.getNumHyperParameters();
        end
        
        function [featureTag] = getFeatureTag(obj)
            featureTag = obj.kernel.getKernelTag();
        end
        
        function [isValid] = isValidFeatureTag(obj, featureTags)
            isValid = featureTags == obj.featureTag;
        end
        
        function setExternalReferenceSet(obj, refset)
            %dummy to use it instead of kernel
        end
        function setReferenceSet(obj, data,list)
            %dummy to use it instead of kernel
        end
    end
    
end


