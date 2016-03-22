classdef SquaredFeatures < FeatureGenerators.FeatureGenerator & FeatureGenerators.FeaturesFromMeanAndVariance
    % The SquaredFeatures is a FeatureGenerators.FeatureGenerator that
    % sends the input data into the identity and squared mapping.
    % \f[
    %	\boldsymbol{X} \rightarrow  [\boldsymbol{X},\boldsymbol{X}^2]
    % \f]
    properties
        useOffset = false;
        indexForCov
    end
    
    methods (Static)
        function [obj] = CreateStateFeaturesFromTrial(trial, useOffset, inputVars)
            if (~exist('useOffset','var'))
                useOffset = false;
            end
            if (~exist('inputVars','var'))
                inputVars = 'states';
            end

            obj = FeatureGenerators.SquaredFeatures(trial.dataManager, inputVars, ':', useOffset);
        end
        
        function [obj] = CreateContextFeaturesFromTrial(trial, useOffset)
            if (~exist('useOffset','var'))
                useOffset = false;
            end
            obj = FeatureGenerators.SquaredFeatures(trial.dataManager, 'contexts', ':', useOffset);
        end
        
    end
    
    methods
        function [obj] = SquaredFeatures(dataManager, featureVariables, stateIndices, useOffset, featureName)
            if (~exist('stateIndices', 'var') || isempty(stateIndices) )
                stateIndices = ':';
            end
            
            if (~exist('useOffset', 'var'))
                useOffset = false;
            end
            
            if (~iscell(featureVariables))
                featureVariables = {featureVariables};
            end
            
            if (~exist('featureName','var'))
                featureName = ['~', 'Squared'];
                for i = 1:length(featureVariables)
                    featureName = [featureName, upper(featureVariables{i}(1)), featureVariables{i}(2:end)];
                end
            end
            
            if (numel(featureVariables) > 1)
                featureVariables = {featureVariables};
            end
            
            obj = obj@FeatureGenerators.FeatureGenerator(dataManager, featureVariables, featureName, stateIndices);
            obj = obj@FeatureGenerators.FeaturesFromMeanAndVariance();
            
            obj.useOffset = useOffset;
            obj.registerFeatureInData();
            
        end
        
        function [features] = getFeaturesInternal(obj, numElements, inputMatrix)
            
            if (nargin == 3 && ~isempty(inputMatrix))
                
                features = zeros(size(inputMatrix,1), obj.getNumFeatures);
                
                index = 0;
                if (obj.useOffset)
                    features(:,1) = 1;
                    index = 1;
                end
                
                features(:, index +  (1:obj.dimSample)) = inputMatrix(:,1:obj.dimSample);
                
                index = index + obj.dimSample + 1;
                for i = 1:obj.dimSample
                    features(:, index : (index + obj.dimSample - i)) = bsxfun(@times, inputMatrix(:, i:obj.dimSample), inputMatrix(:, i));
                    index = index + obj.dimSample - i + 1;
                end
            else
                features = zeros(numElements, 0);
            end
        end
        
        function [numFeatures] = getNumFeatures(obj)
            numFeatures = 2 * obj.dimSample + obj.dimSample * (obj.dimSample - 1 ) / 2;
            if (obj.useOffset)
                numFeatures = numFeatures + 1;
            end
        end
        
        function [features] = getFeaturesFromMeanAndVariance(obj, mean, covarianceMatrices)
            [features] = getFeatures(obj, size(mean,1), mean);
            
            covaranceMatricesAsVectors =  covarianceMatrices(:,:);
            
            index = obj.dimSample;
            if (obj.addOffset)
                index = index + 1;
            end
            
            features(:, index + 1:end) = features(:, index + 1:end) + covaranceMatricesAsVectors(:,obj.indexForCov);
            
        end
        
        function [] = setStateIndices(obj, indices)
            obj.setStateIndices@FeatureGenerators.FeatureGenerator(indices);
            obj.indexForCov = [];
            index = 0;
            for i = 1:obj.dimSample
                obj.indexForCov = [obj.indexForCov, index + (i:obj.dimSample)];
                index = index + obj.dimSample;
            end
        end
        
    end
    
end


