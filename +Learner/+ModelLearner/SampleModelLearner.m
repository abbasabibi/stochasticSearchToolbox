classdef SampleModelLearner < Learner.Learner & FeatureGenerators.FeatureGenerator
    %SampleModelLearner doesn't actually learn a model, just returns
    % observed transtions
    
    properties(SetObservable,AbortSet)

        resetProb
        refstates
        refnstates
        refstates1
        featureextractor
        featureVar
        nextFeatureVar
        featureTag=0
        currentInputFeatures
        nextInputFeatures
    end
    
    methods
        function obj = SampleModelLearner(dataManager, stateIndices, featureextractor, ~, ~, resetProbName)
            featureVariable     = featureextractor.outputName;
            numFeatureslocal    = featureextractor.getNumFeatures();
%             currentInputFeature =
%             featureextractor.featureVariables{1}{1}; Check for double or
%             single cell
            currentInputFeature = featureextractor.featureVariables{1};            
            nextInputFeature    = ['next' upper(currentInputFeature(1)) currentInputFeature(2:end)];
            obj = obj@FeatureGenerators.FeatureGenerator(dataManager, {[featureVariable]}, 'SampleModel', stateIndices,numFeatureslocal);

            obj = obj@Learner.Learner();
            obj.featureVar=featureVariable;
            obj.nextFeatureVar=['next' upper(featureVariable(1)) featureVariable(2:end)];
            
            obj.featureextractor=featureextractor;
            
            if(~exist('resetProbName','var') || isempty(resetProbName) )
                resetProbName = 'resetProbTimeSteps';
            end

            obj.linkProperty('resetProb', resetProbName);
            obj.currentInputFeatures = currentInputFeature;
            obj.nextInputFeatures = nextInputFeature;
        end
        
        function [features] = getFeaturesInternal(obj, numFeatures, inputMatrix)
            if( isequal(inputMatrix, obj.refstates))
                features = (1-obj.resetProb) * obj.refnstates;
                features = bsxfun(@plus, features, obj.resetProb * mean(obj.refstates1));
            else
                features = zeros(size(inputMatrix,1), obj.numFeatures);
                assert(false, 'Cannot predict for unknown states!')
            end            

        end
        
        
        function [numFeatures] = getNumFeatures(obj)
            numFeatures = obj.numFeatures;
        end
        
        function [featureTag] = getFeatureTag(obj)
            featureTag = obj.featureTag;
        end
     
        function [isValid] = isValidFeatureTag(obj, featureTags)
            isValid = featureTags == obj.featureTag;
        end

        
        function obj = updateModel(obj, data)
            obj.featureTag  = obj.featureTag + 1; 
            obj.refstates   = data.getDataEntry(obj.featureVar);
            obj.refnstates  = data.getDataEntry(obj.nextFeatureVar);
            obj.refstates1  = data.getDataEntry(obj.featureVar,:,1);
        end
    end
    
end

