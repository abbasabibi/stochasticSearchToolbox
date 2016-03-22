classdef KernelBasedFeatureGenerator < FeatureGenerators.FeatureGenerator & Kernels.KernelReferenceSet & Learner.ParameterOptimization.HyperParameterObject
    properties
        externalReferenceSet
    end
    
    properties (AbortSet, SetObservable)
        maxSizeReferenceSet = 300;
    end
    
    methods
        function [obj] = KernelBasedFeatureGenerator(dataManager, kernel, featureVariables, featureName)
            
            if (~iscell(featureVariables))
                featureVariables = {featureVariables};
            end
            
            if (~exist('featureName','var'))
                featureName = ['~', kernel.kernelName];
                for i = 1:length(featureVariables)
                    featureName = [featureName, upper(featureVariables{i}(1)), featureVariables{i}(2:end)];
                end
            end
            
            if (numel(featureVariables) > 1)
                featureVariables = {featureVariables};
            end
            
            maxSizeReferenceSet = 300;
            if (Common.Settings().hasProperty('maxSizeReferenceSet'))
                maxSizeReferenceSet = Common.Settings().getProperty('maxSizeReferenceSet');
            end
            obj = obj@Kernels.KernelReferenceSet(dataManager, kernel, featureVariables);            
            obj = obj@FeatureGenerators.FeatureGenerator(dataManager, featureVariables, featureName, ':', maxSizeReferenceSet);
                                    
            obj.linkProperty('maxSizeReferenceSet');
            
        end
        
        function [features] = getFeaturesInternal(obj, ~, inputMatrix)
            if (~isempty(obj.getReferenceSet()))
                grammatrix = obj.getKernelVectors(inputMatrix)';
            else
                grammatrix = [];
            end
            
            if(size(grammatrix,2) > obj.getNumFeatures())
                warning('KernelBasedFeatures:numFeatures','amount of features not supported')
                features = grammatrix(:,1:obj.getNumFeatures());
            else
                zerofeatures = zeros(size(inputMatrix,1), obj.getNumFeatures()-size(grammatrix,2));
                features = [grammatrix, zerofeatures];
            end
        end
        
        function [featureTag] = getFeatureTag(obj)
            if ~isempty(obj.externalReferenceSet)
                featureTag = obj.kernel.getKernelTag() + obj.externalReferenceSet.getKernelReferenceSetTag();
            else
                featureTag = obj.kernel.getKernelTag() + obj.getKernelReferenceSetTag();
            end
        end
        
        function [isValid] = isValidFeatureTag(obj, featureTags)
            isValid = featureTags == obj.getFeatureTag();
        end
        
        function [numParams] = getNumHyperParameters(obj)
            numParams = obj.kernel.getNumHyperParameters();
        end
        
        function [] = setHyperParameters(obj, params)
            obj.kernel.setHyperParameters(params);
        end
        
        function [params] = getHyperParameters(obj)
            params = obj.kernel.getHyperParameters();
        end
        
        function [expParameterTransformMap] = getExpParameterTransformMap(obj)
            expParameterTransformMap = obj.kernel.getExpParameterTransformMap();
        end
        
        function [referenceSet] = getReferenceSet(obj)
            if(~isempty(obj.externalReferenceSet))
                referenceSet = obj.externalReferenceSet.getReferenceSet();
            else
                referenceSet = obj.referenceSet;
            end
            
        end
        
        function [referenceSetIndices] = getReferenceSetIndices(obj)
            if(~isempty(obj.externalReferenceSet))
                referenceSetIndices = obj.externalReferenceSet.getReferenceSetIndices();
            else
                referenceSetIndices = obj.referenceSetIndices;
            end
        end
        
        function setExternalReferenceSet(obj, external)
            obj.externalReferenceSet = external;
        end
        
    end
    
end


