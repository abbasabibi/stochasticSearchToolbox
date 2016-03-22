classdef CEOKernelKalmanFilterOptimizer < Learner.ParameterOptimization.AbstractHyperParameterOptimizer
    %GENERALIZEDKERNELKALMANFILTEROPTIMIZER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (AbortSet, SetObservable)
        trainEpisodesRatio = .7;
        observationIndex = 1
        groundtruthName
        inputDataEntry
        validityDataEntry
        internalObjective = 'mse';
    end
    
    properties
        ceokkfLearner
        
        trainData
        testData
        wholeData
    end
    
    methods
        function obj = CEOKernelKalmanFilterOptimizer(dataManager, ceokkfLearner)
            obj = obj@Learner.ParameterOptimization.AbstractHyperParameterOptimizer(dataManager, ceokkfLearner, 'CEOKKF_CMAES_optimization', false);
            
            obj.ceokkfLearner = ceokkfLearner;
            
            obj.linkProperty('trainEpisodesRatio','ceokkfOptimizer_trainEpisodesRatio');
            obj.linkProperty('inputDataEntry','ceokkfOptimizer_inputDataEntry');
            obj.linkProperty('observationIndex','ceokkfOptimizer_observationIndex');
            obj.linkProperty('groundtruthName','ceokkfOptimizer_groundtruthName');
            obj.linkProperty('validityDataEntry','ceokkfOptimizer_validityDataEntry');
            obj.linkProperty('internalObjective','ceokkfOptimizer_internalObjective');
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
            
            obj.hyperParameterObject.learnFeatureGenerators(obj.trainData);
        end
      
        function [funcVal, gradient] = objectiveFunction(obj, params)
            obj.hyperParameterObject.setHyperParameters(params);
            
            observations = obj.testData.getDataEntry3D(obj.ceokkfLearner.kernelReferenceSet.inputDataEntryReferenceSet);
            if obj.testData.isDataEntry('obsPoints')
                obsPoints = obj.testData.getDataEntry('obsPoints',1);
            else
                obsPoints = true(1,size(observations,1));
            end
            groundtruth = obj.testData.getDataEntry3D(obj.groundtruthName);
            
            if not(isempty(obj.validityDataEntry))
                valid = logical(obj.testData.getDataEntry3D(obj.validityDataEntry));
                valid = all(all(valid,3),1);
            else
                valid = true(size(observations,2),1);
            end
            
            observations = observations(:,valid,:);
            groundtruth = groundtruth(:,valid,:);
            obsPoints = obsPoints(valid);
            
            lastwarn('');
            funcVal = 0;
            
            % learn the model
            obj.hyperParameterObject.updateModel(obj.trainData);

            % test the model
            [mu, var] = obj.hyperParameterObject.filter.filterData(permute(observations,[2,3,1]),obsPoints);

            if ~strcmp(lastwarn,'')
                funcVal = 1e5;
            end
                        
            % evaluate the model
            switch obj.internalObjective
                case 'mse'
                    funcVal = funcVal + obj.squaredError(groundtruth,permute(mu(:,obj.observationIndex,:),[3,1,2]))/length(groundtruth(:));
                    if exist('muMonitoring','var')
                        fprintf(' %f ',obj.squaredError(groundtruthMonitoring,muMonitoring)/length(groundtruthMonitoring(:)));
                    end
                case 'llh'
                    funcVal = funcVal - obj.logLikelihood(groundtruth,permute(mu(:,obj.observationIndex,:),[3,1,2]),permute(var(:,obj.observationIndex,obj.observationIndex,:),[4,1,2,3]));
                    if exist('muMonitoring','var')
                        fprintf(' %f ',-obj.logLikelihood(groundtruthMonitoring,muMonitoring,varMonitoring));
                    end
                case 'euclidean'
                    funcVal = funcVal + obj.meanEuclideanDistance(groundtruth,permute(mu(:,obj.observationIndex,:),[3,1,2]));
                    if exist('muMonitoring','var')
                        fprintf(' %f ',obj.meanEuclideanDistance(groundtruthMonitoring,muMonitoring));
                    end
            end
        end
        
        function [] = learnFinalModel(obj)
            disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
            disp('best Hyperparameters:');
            disp(obj.hyperParameterObject.getHyperParameters());
            disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
            
%             obj.hyperParameterObject.updateKernelReferenceSets(obj.wholeData);
            obj.hyperParameterObject.updateModel(obj.wholeData);
        end
        
        function [] = beforeOptimizationHook(obj)
            disp('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
            disp('Hyperparameters before optimization:');
            disp(obj.hyperParameterObject.getHyperParameters());
            disp('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
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
        
        function llh = logLikelihood(data, mean, var)
            error = reshape(permute(mean - data,[1,3,2]),size(mean,1),[]);
            vars = mat2cell(reshape(permute(var(1,:,:,:),[3,4,2,1]),size(var,3),[]),size(var,3),size(var,4)*ones(1,size(var,2)));
            Q = blkdiag(vars{:});
            small_ind = find(diag(Q) < .0001);
            Q(sub2ind(size(Q),small_ind,small_ind)) = .0001;
            sq_error = (error / Q) .* error;
            llh = -.5 * sum(sq_error(:)) - .5 * (size(mean,3) * log(2 * pi) + log(det(Q)));
        end
        
        function error = meanEuclideanDistance(data, estimates)
            error = (estimates - data).^2;
            error = sqrt(sum(error,3));
            error = sum(error(:))./numel(error);
        end
    end
end


