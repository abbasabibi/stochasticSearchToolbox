classdef GeneralizedKernelKalmanFilterOptimizerThetaExtraction < Learner.ParameterOptimization.AbstractHyperParameterOptimizer
    %GENERALIZEDKERNELKALMANFILTEROPTIMIZER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (AbortSet, SetObservable)
        trainEpisodesRatio = .7;
        observationIndex = 1
        groundtruthName
%         inputDataEntry
        validityDataEntry = '';
        internalObjective = 'mse';
        testMethod = 'filter';
        
        monitoringIndex = [];
        monitoringGroundtruthName;
        
        
        preprocessTrainingDataEnabled = true;
    end
    
    properties
        gkkfLearner
        
        trainData
        testData
        wholeData
    end
    
    methods
        function obj = GeneralizedKernelKalmanFilterOptimizerThetaExtraction(dataManager, gkkfLearner, optimizationName)
            if not(exist('optimizationName','var'))
                optimizationName = 'GKKF_CMAES_optimization';
            end
            
            obj = obj@Learner.ParameterOptimization.AbstractHyperParameterOptimizer(dataManager, gkkfLearner, optimizationName, false);
            
            obj.gkkfLearner = gkkfLearner;
            
            obj.linkProperty('trainEpisodesRatio',[obj.optimizationName '_trainEpisodesRatio']);
%             obj.linkProperty('inputDataEntry',[obj.optimizationName '_inputDataEntry']);
            obj.linkProperty('observationIndex',[obj.optimizationName '_observationIndex']);
            obj.linkProperty('groundtruthName',[obj.optimizationName '_groundtruthName']);
            obj.linkProperty('validityDataEntry',[obj.optimizationName '_validityDataEntry']);
            obj.linkProperty('internalObjective',[obj.optimizationName '_internalObjective']);
            obj.linkProperty('testMethod',[obj.optimizationName '_testMethod']);
            obj.linkProperty('preprocessTrainingDataEnabled',[obj.optimizationName '_preprocessTrainingDataEnabled']);
            obj.linkProperty('monitoringIndex',[obj.optimizationName '_monitoringIndex']);
            obj.linkProperty('monitoringGroundtruthName',[obj.optimizationName '_monitoringGroundtruthName']);
        end
    end
    
    % methods from AbstractHyperParameterOptimizer
    methods
        function [] = processTrainingData(obj, data)
            if obj.preprocessTrainingDataEnabled
                obj.hyperParameterObject.preprocessData(data);
            end
        end
        
        function [] = initializeParameters(obj, data)
            numEpisodes = data.getNumElementsForDepth(1);
            numTrainingEpisodes = round(obj.trainEpisodesRatio * numEpisodes);
            
            obj.trainData = data.cloneDataSubSet(1:numTrainingEpisodes);
            obj.testData = data.cloneDataSubSet(numTrainingEpisodes+1:numEpisodes);
            obj.wholeData = data;
            
%             obj.hyperParameterObject.learnFeatureGenerators(obj.trainData);
%             if not(obj.hyperParameterObject.initialized)
                obj.hyperParameterObject.initializeModel(obj.trainData);
%             end
        end
      
        function [funcVal, gradient] = objectiveFunction(obj, params)
            gradient = [];
            obj.hyperParameterObject.setHyperParameters(params);

            lastwarn('');
            funcVal = 0;
            
            % learn the model
            obj.hyperParameterObject.updateModel(obj.trainData);
            
            % test the model
            switch obj.testMethod
                case 'filter'
                    observations = obj.testData.getDataEntry3D(obj.gkkfLearner.obsFeatureName);
                    if obj.testData.isDataEntry('obsPoints')
                        obsPoints = obj.testData.getDataEntry('obsPoints',1);
                    else
                        obsPoints = true(1,size(observations,2));
                    end
                    groundtruth = obj.testData.getDataEntry3D(obj.groundtruthName);
                    
                    if not(isempty(obj.validityDataEntry))
                        valid = logical(obj.testData.getDataEntry3D(obj.validityDataEntry));
                        valid = all(valid,1);
                    else
                        valid = true(size(observations,2),1);
                    end

                    observations = observations(:,valid,:);
                    groundtruth = groundtruth(:,valid,:);
                    [mu, var] = obj.hyperParameterObject.filter.filterData(permute(observations,[2,3,1]),obsPoints);
                    mu(:,111,:) = reshape(FeatureGenerators.PictureFeatureExtractors.extractTheta(reshape(permute(mu(:,1:100,:),[2,1,3]),10,10,size(mu,1),size(mu,3)),false),[],1,10);
                    
                    if not(isempty(obj.monitoringIndex))
                        muMonitoring = permute(mu(:,obj.monitoringIndex,:),[3,1,2]);
                        varMonitoring = permute(var(:,obj.monitoringIndex,:),[3,1,2]);
                        
                        groundtruthMonitoring = obj.testData.getDataEntry3D(obj.monitoringGroundtruthName);
                        groundtruthMonitoring = groundtruthMonitoring(:,valid,:);
                    end
                    
                    mu = permute(mu(:,obj.observationIndex,:),[3,1,2]);
                    var = permute(var(:,obj.observationIndex,:),[3,1,2]);
                case 'oneStepWObs'
                    states = obj.testData.getDataEntry(obj.gkkfLearner.stateFeatureName);
                    observations = obj.testData.getDataEntry(obj.gkkfLearner.obsFeatureName);
                    groundtruth = obj.testData.getDataEntry(obj.groundtruthName);
                    valid = logical(obj.testData.getDataEntry(obj.validityDataEntry));
                    
                    states = states(valid,:);
                    observations = observations(valid,:);
                    groundtruth = groundtruth(find(valid)+1,:);
                    
                    [mu, var] = obj.observedOneStepPredictions(states,observations);
                case 'oneStep'
                    states = obj.testData.getDataEntry(obj.gkkfLearner.stateFeatureName);
                    groundtruth = obj.testData.getDataEntry(obj.groundtruthName);
                    valid = logical(obj.testData.getDataEntry(obj.validityDataEntry));
                    
                    states = states(valid,:);
                    groundtruth = groundtruth(find(valid)+1,:);
                    
                    [mu, var] = obj.oneStepPredictions(states);
                case 'longTerm'
                    valid = logical(obj.testData.getDataEntry(obj.validityDataEntry,1));
                    firstValid = find(valid, 1, 'first');
                    lastValid = find(valid, 1, 'last');
                    states = obj.testData.getDataEntry(obj.gkkfLearner.stateFeatureName,:,firstValid);
                    observations = obj.testData.getDataEntry(obj.gkkfLearner.obsFeatureName,:,firstValid);
                    
                    groundtruth = obj.testData.getDataEntry3D(obj.groundtruthName);
                    groundtruth = groundtruth(:,find(valid)+1);
                    
                    mu = obj.longTermPredictions(states,observations,lastValid+1-firstValid);
                case 'longTerm2'
                    valid = logical(obj.testData.getDataEntry(obj.validityDataEntry,1));
                    states = obj.testData.getDataEntry3D(obj.gkkfLearner.stateFeatureName);
                    observations = obj.testData.getDataEntry3D(obj.gkkfLearner.obsFeatureName);
                    groundtruth = obj.testData.getDataEntry3D(obj.groundtruthName);
                    
                    states = states(:,valid,:);
                    observations = observations(:,valid,:);
                    groundtruth = groundtruth(:,find(valid)+1,:);
                    groundtruth = repmat(groundtruth,1,1,size(groundtruth,2));
                    
                    mu = obj.longTermPredictions2(states,observations,groundtruth);
                case 'experimentalObs'
                    valid = logical(obj.testData.getDataEntry(obj.validityDataEntry));
                    states = obj.testData.getDataEntry(obj.gkkfLearner.stateFeatureName);
                    observations = obj.testData.getDataEntry(obj.gkkfLearner.obsFeatureName);
                    
                    states = states(valid,:);
                    observations = observations(valid,:);
                    
                    stateEmbeddings = obj.hyperParameterObject.filter.getEmbeddings(states);
                    obsEmbeddings = obj.hyperParameterObject.filter.obsKernelReferenceSet.getKernelVectors(observations);
                    
                    mu = obj.hyperParameterObject.filter.GL * stateEmbeddings;
                    groundtruth = obj.hyperParameterObject.filter.Kro * obsEmbeddings;
            end
            
            if ~strcmp(lastwarn,'')
                funcVal = 1e5;
            end
                        
            % evaluate the model
            switch obj.internalObjective
                case 'mse'
                    funcVal = funcVal + obj.squaredError(groundtruth,mu)/length(groundtruth(:));
                    if exist('muMonitoring','var')
                        fprintf(' %f ',obj.squaredError(groundtruthMonitoring,muMonitoring)/length(groundtruthMonitoring(:)));
                    end
                case 'llh'
                    funcVal = funcVal - obj.logLikelihood(groundtruth,mu,var);
                    if exist('muMonitoring','var')
                        fprintf(' %f ',-obj.logLikelihood(groundtruthMonitoring,muMonitoring,varMonitoring));
                    end
                case '123'
                    funcVal = funcVal + obj.oneTwoThreeStdDev(observations,mu,var);
                    if exist('muMonitoring','var')
                        fprintf(' %f ',-obj.oneTwoThreeStdDev(groundtruthMonitoring,muMonitoring,varMonitoring));
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
    
    methods
        function [mu, var] = observedOneStepPredictions(obj, states, observations)
            m = obj.hyperParameterObject.filter.getEmbeddings(states);
            [m, v] = obj.hyperParameterObject.filter.observation(m,obj.hyperParameterObject.filter.initialCov,observations);
            [m, v] = obj.hyperParameterObject.filter.transition(m,v);
            [mu, var] = obj.hyperParameterObject.filter.outputTransformation(m,v);
            
            mu = mu{1}';
        end
        function [mu, var] = oneStepPredictions(obj, states)
            m = obj.hyperParameterObject.filter.getEmbeddings(states);
            [m] = obj.hyperParameterObject.filter.transition(m);
            [mu, var] = obj.hyperParameterObject.filter.outputTransformation(m,obj.hyperParameterObject.filter.initialCov);
            
            mu = mu{1}';
        end
        function [mu] = longTermPredictions(obj, initialStates, initialObservations, numPredictionSteps)
            mu = zeros(size(initialStates,1),numPredictionSteps);
            m = obj.hyperParameterObject.filter.getEmbeddings(initialStates);
            m = obj.hyperParameterObject.filter.observation(m,obj.hyperParameterObject.filter.initialCov,initialObservations);
            for i = 1:numPredictionSteps
                m = obj.hyperParameterObject.filter.transition(m);
                mu(:,i) = obj.hyperParameterObject.filter.outputTransformation(m)';
            end
        end
        function [mu] = longTermPredictions2(obj, states, observations, mu)
            [nEpisodes, episodeLength, ~] = size(states);
            n = size(mu,3)/size(mu,2);
            
            m = obj.hyperParameterObject.filter.getEmbeddings(reshape(states,[],size(states,3)));
            m = obj.hyperParameterObject.filter.observation(m,obj.hyperParameterObject.filter.initialCov,reshape(observations,[],size(observations,3)));
            for i = 1:episodeLength
                m(:,1:nEpisodes * (episodeLength+1-i)) = obj.hyperParameterObject.filter.transition(m(:,1:nEpisodes * (episodeLength+1-i)));
                mu_ = obj.hyperParameterObject.filter.outputTransformation(m);
                for j = i:(episodeLength+1-i)
                    range = (j-i)*n+1:(j-i+1)*n;
                    mu(:,j,range) = permute(mu_(:, (j-i) * nEpisodes + 1: (j+1-i) * nEpisodes),[3,2,1]);
                end
            end
        end
    end
    
    
    methods (Static)
        function error = squaredError(data, estimates)
            error = (estimates - data).^2;
            error = sum(error(:));
        end
        
        function llh = logLikelihood(data, mean, var)
            if all(size(var) > 1)
                
                small_ind = find(diag(var) < .0001);
                var(sub2ind(size(var),small_ind,small_ind)) = .0001;
            else
                var(var < .0001) = .0001;
            end
            
            sq_error = (mean - data).^2;
            llh = -.5 * sq_error ./ var - .5 * log(2 * pi * var);
            llh = sum(llh(:));
        end
        
        function error = oneTwoThreeStdDev(data, mean, var)
            error = abs(mean - data);
            stdDev = sqrt(var);
            inOne = error < stdDev;
            inTwo = error < 2 * stdDev;
            inThree = error < 3 * stdDev;
            inOneP = sum(inOne(:)) / numel(data);
            inTwoP = sum(inTwo(:)) / numel(data);
            inThreeP = sum(inThree(:)) / numel(data);
            
            error = (inOneP - .6827).^2 + (inTwoP - .9545).^2 + (inThreeP - .9973).^2;
        end
    end
end

