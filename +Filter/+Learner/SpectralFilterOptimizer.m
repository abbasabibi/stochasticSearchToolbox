classdef SpectralFilterOptimizer < Learner.ParameterOptimization.AbstractHyperParameterOptimizer
    %GENERALIZEDKERNELKALMANFILTEROPTIMIZER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (AbortSet, SetObservable)
        trainEpisodesRatio = .7;
        observationIndex = 1
        groundtruthName
        inputDataEntry
        validityDataEntry
    end
    
    properties
        spectralLearner
        
        trainData
        testData
        wholeData
    end
    
    methods
        function obj = SpectralFilterOptimizer(dataManager, spectralLearner)
            obj = obj@Learner.ParameterOptimization.AbstractHyperParameterOptimizer(dataManager, spectralLearner, 'Spectral_CMAES_optimization', false);
            
            obj.spectralLearner = spectralLearner;
            
            obj.linkProperty('trainEpisodesRatio','spectralOptimizer_trainEpisodesRatio');
            obj.linkProperty('inputDataEntry','spectralOptimizer_inputDataEntry');
            obj.linkProperty('observationIndex','spectralOptimizer_observationIndex');
            obj.linkProperty('groundtruthName','spectralOptimizer_groundtruthName');
            obj.linkProperty('validityDataEntry','spectralOptimizer_validityDataEntry');
        end
    end
    
    % methods from AbstractHyperParameterOptimizer
    methods
        function [] = processTrainingData(obj, data)
            obj.hyperParameterObject.preprocessData(data);
        end
        
        function [] = initializeParameters(obj, data)
            numEpisodes = data.getNumElementsForDepth(1);
            numTrainingEpisodes = round(obj.trainEpisodesRatio * numEpisodes);
            
            obj.trainData = data.cloneDataSubSet(1:numTrainingEpisodes);
            obj.testData = data.cloneDataSubSet(numTrainingEpisodes+1:numEpisodes);
            obj.wholeData = data;
            
%             obj.hyperParameterObject.learnFeatureGenerators(obj.trainData);
%             obj.hyperParameterObject.initializeModel(obj.trainData);
        end
      
        function [funcVal, gradient] = objectiveFunction(obj, params)
            obj.hyperParameterObject.setHyperParameters(params);
            
            observations = obj.testData.getDataEntry3D(obj.hyperParameterObject.filter.state1KernelReferenceSet.inputDataEntryReferenceSet);
            if obj.testData.isDataEntry('obsPoints')
                obsPoints = obj.testData.getDataEntry('obsPoints',1);
            else
                obsPoints = true(1,size(observations,2));
            end
            groundtruth = obj.testData.getDataEntry3D(obj.groundtruthName);
            valid = logical(obj.testData.getDataEntry(obj.validityDataEntry,1));
            valid = all(valid,2);
%             features = obj.testData.getDataEntry3D(obj.inputDataEntry);
            
            observations = observations(:,valid,:);
            groundtruth = groundtruth(:,valid,:);
            obsPoints = obsPoints(valid);
            

            % learn the model
            obj.hyperParameterObject.updateModel(obj.trainData);

%             obj.hyperParameterObject.gkkf.initialMean = obj.hyperParameterObject.gkkf.getEmbeddings(permute(features(:,1,:),[1,3,2]));
            % test the model
%             lastwarn('');
            [mu] = obj.hyperParameterObject.filter.filterData(permute(observations,[2,3,1]),obsPoints);
%             if ~strcmp(lastwarn,'')
%                 funcVal = 1e5;
%                 return
%             end
%             [mu1, var1] = obj.hyperParameterObject.gkkf.outputTransformation(obj.hyperParameterObject.gkkf.initialMean, obj.hyperParameterObject.gkkf.initialCov);
%             mu = [permute(mu1,[3,1,2]); mu];
%             var = [repmat(permute(diag(var1),[2,1,3]),size(var,3)); var];
            
%             testFeatures = obj.testData.getDataEntry(obj.spectralLearner.stateFeatureName);
%             testFeaturesValidIdx = obj.testData.getDataEntry('thetaNoisyWindowsValid');
%             testObservations = obj.testData.getDataEntry('thetaNoisy');
%             validTestObservations = testObservations(logical(testFeaturesValidIdx),:);
%             validTestFeatures = testFeatures(logical(testFeaturesValidIdx),:);
%             validNextTestFeatures = testFeatures(find(testFeaturesValidIdx)+1,:);
%             validTestFeaturesEmbeddings = obj.hyperParameterObject.gkkf.getEmbeddings(validTestFeatures);
%             validNextTestFeaturesEmbeddings = obj.hyperParameterObject.gkkf.getEmbeddings(validNextTestFeatures);
%             condValidTestFeaturesEmbeddings = obj.hyperParameterObject.gkkf.observation(validTestFeaturesEmbeddings,obj.hyperParameterObject.gkkf.initialCov,validTestObservations);
%             sq_error = (validNextTestFeatures - obj.hyperParameterObject.gkkf.outputTransformation(validTestFeaturesEmbeddings)').^2;
            
            
            % evaluate the model
            funcVal = obj.squaredError(groundtruth,permute(mu(:,obj.observationIndex,:),[3,1,2]))/length(groundtruth(:));
%             funcVal = sum(sq_error(:));
%             if isinf(funcVal)
%                 funcVal = 1e10;
%             end
            
        end
        
        function [] = learnFinalModel(obj)
            disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
            disp('best Hyperparameters:');
            disp(obj.hyperParameterObject.getHyperParameters());
            disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
            
            obj.hyperParameterObject.updateKernelReferenceSets(obj.wholeData);
            obj.hyperParameterObject.updateModel(obj.wholeData);
        end
        
        function [] = beforeOptimizationHook(obj)
            disp('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
            disp('Hyperparameters before optimization:');
            disp(obj.hyperParameterObject.getHyperParameters());
            disp('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
            lastwarn('');
        end
        
        function [] = afterOptimizationHook(obj)
            disp('---------------------------------------------------------');
            disp('Hyperparameters after optimization:');
            disp(obj.hyperParameterObject.getHyperParameters());
            disp('---------------------------------------------------------');
        end
        
    end
    
    
    methods (Static)
        function error = squaredError(data, estimates)
            error = (estimates - data).^2;
            error = sum(error(:));
        end
        
        function nll = negLogLikelihood(data, mean, var)
            
        end
    end
end

