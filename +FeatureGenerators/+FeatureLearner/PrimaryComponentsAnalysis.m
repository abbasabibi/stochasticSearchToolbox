classdef PrimaryComponentsAnalysis < Learner.Learner & Data.DataManipulator
    %PRIMARYCOMPONENTSANALYSIS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (AbortSet, SetObservable)
        normalizeEigenVectors = true;
    end
    
    properties
        linearTransformFeatureGen
    end
    
    methods (Static)
        function pcaLearner = createFromTrial(trial,featureGenerator)
            pcaLearner = FeatureGenerators.FeatureLearner.PrimaryComponentsAnalysis(trial.(featureGenerator));
        end
    end
    
    methods
        function obj = PrimaryComponentsAnalysis(linearTransformFeatureGen)
            obj = obj@Learner.Learner();
            obj = obj@Data.DataManipulator(linearTransformFeatureGen.getDataManager());
            
            obj.linearTransformFeatureGen = linearTransformFeatureGen;
            
            obj.linkProperty('normalizeEigenVectors',[obj.linearTransformFeatureGen.featureName '_normalizeEigenVectors']);
            
            obj.addDataManipulationFunction('computePcaTransformationMatrix', linearTransformFeatureGen.featureVariables, {});
        end
        
        function obj = computePcaTransformationMatrix(obj, data)
            index = not(any(isnan(data),2));
            % perform pca on data
            [V,D] = eig(cov(data(index,:)));
            
            if obj.normalizeEigenVectors
                V = V * diag(diag(D).^-.5);
            end
            
            V = V(:,end:-1:end-obj.linearTransformFeatureGen.getNumFeatures()+1);
            
            % update linear transform feature generator
            obj.linearTransformFeatureGen.setM(V);
        end
        
        function updateModel(obj, data)
            obj.callDataFunction('computePcaTransformationMatrix',data);
        end
        
        function data = preprocessData(obj, data)
            obj.callDataFunction('computePcaTransformationMatrix',data);
        end
    end
    
end

