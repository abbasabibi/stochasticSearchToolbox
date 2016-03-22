classdef BasisFunctionsFeatures < FeatureGenerators.FeatureGenerator & Learner.Learner
    
    properties
        basis
        baseFeature
        basisName
    end
    
    methods
        function obj =  BasisFunctionsFeatures(dataManager, baseFeature, basisName, stateIndices, featureName)
            if (~exist('stateIndices', 'var'))
                stateIndices = ':';
            end
            if (~exist('featureName', 'var'))
                featureName = 'Basis';
            end
            featureVariables = baseFeature.featureVariables;
            cnt = dataManager.getNumDimensions(baseFeature.outputName)*dataManager.getNumDimensions(basisName);
            
            obj = obj@FeatureGenerators.FeatureGenerator(dataManager, [featureVariables,basisName], featureName, stateIndices, cnt);
            obj.baseFeature = baseFeature;
            
            obj.basisName = basisName;
        end
        
        function [features] = getFeaturesInternal(obj, numElements, inputMatrix, basis)
            if(~exist('basis', 'var'))
                basis = obj.basis;
            end
            featureMatrix = obj.baseFeature.getFeaturesInternal(numElements, inputMatrix);
            curbasis = basis(1:numElements,:);
            f = repmat(featureMatrix,1,size(curbasis,2));
            b = kron(curbasis,ones(1,size(featureMatrix,2)));
            features = f.*b;
        end
        
        function obj = updateModel(obj, data)
            obj.basis = data.getDataEntry(obj.basisName);
        end
        
    end
    
end

