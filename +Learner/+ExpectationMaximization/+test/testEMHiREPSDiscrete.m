clear variables;
close all;


sampler = Sampler.EpisodeWithStepsSamplerOptions();

dataManager = sampler.getEpisodeDataManager();

settings = Common.Settings();

dimState    = 1; 
dimAction   = 1;
numOptions  = 2;
% dataManager.addDataEntry('steps.states', dimState);
% dataManager.addDataEntry('steps.actions', dimAction);
% dataManager.addDataEntry('steps.options', 1, 1, numOptions);
% dataManager.addDataEntry('steps.optionsOld', 1, 1, numOptions);
settings.setProperty('numOptions',numOptions);
settings.setProperty('numIterationsEM',2e2);
settings.setProperty('logLikelihoodThresholdEM',1e-1);
settings.setProperty('softMaxRegressionTerminationFactor',1e-6);
settings.setProperty('debugPlottingMM',true);
settings.setProperty('numTimeSteps',50);


environment = Learner.ExpectationMaximization.test.HMMTestEnvDiscrete(dataManager);

terminationPolicy   = Distributions.Discrete.DiscreteDistributionDiscreteInput(dataManager, 'terminations', 'states', 'terminationFunction');
terminationLearner  = Learner.ClassificationLearner.PriorDistributionLearner(dataManager,terminationPolicy);
terminationPolicyInitializer   = @Distributions.Discrete.DiscreteDistributionDiscreteInput;


actionPolicy = Distributions.Discrete.DiscreteDistributionDiscreteInput(dataManager, 'actions', 'states', 'ActionPolicy');
actionPolicyLearner = Learner.ClassificationLearner.PriorDistributionLearner(dataManager, actionPolicy);
actionPolicyInitializer = @Distributions.Discrete.DiscreteDistributionDiscreteInput;


gatingDist    = Distributions.Discrete.DiscreteDistributionDiscreteInput(dataManager, 'options', 'states', 'Gating');
gatingLearner = Learner.ClassificationLearner.PriorDistributionLearner(dataManager, gatingDist); %false or true???



mixtureModel  = Distributions.MixtureModel.MixtureModelWithTermination.createPolicy(dataManager, gatingDist, ...
    actionPolicyInitializer, 'actions', 'states', 'states', terminationPolicyInitializer,'options','optionsOld');

sampler.getStepSampler.setIsActiveSampler(Sampler.IsActiveStepSampler.IsActiveNumSteps(dataManager));




sampler.setContextSampler(environment);
sampler.setActionPolicy(mixtureModel);
sampler.setTransitionFunction(environment);
sampler.setRewardFunction(environment);
sampler.setInitialStateSampler(environment);



numSamples = 100;
dataManager.finalizeDataManager();
newData = dataManager.getDataObject(numSamples);
newData.setDataEntry('states', randi(3,numSamples,dimState)-2, :,1 ); %[episode, step]
newData.setDataEntry('optionsOld',randi(numOptions,numSamples,1) ,:, 1);

mixtureModel.initObject();
gatingDist.initObject();

%
mixtureModel.callDataFunction('sampleFromDistribution',newData);

%

dataManager.finalizeDataManager();
sampler.numSamples = 100;
sampler.setParallelSampling(true);
fprintf('Generating Data\n');
tic
sampler.createSamples(newData);
toc


%%
mixtureModelLearner = Learner.SupervisedLearner.MixtureModelLearner(dataManager, mixtureModel, actionPolicyLearner, gatingLearner, 'responsibilities')
terminationMMLearner = Learner.SupervisedLearner.TerminationMMLearner(dataManager, mixtureModel, actionPolicyLearner, 'responsibilities');


EMLearner     = Learner.ExpectationMaximization.EMMixtureModels(dataManager, mixtureModel, mixtureModelLearner)












environment = Sampler.test.EnvironmentSequentialOptionsTest(dataManager, dataManager.getSubDataManager());











% 
% 
% 
% dataManager.finalizeDataManager();
% newData = dataManager.getDataObject(10);
% newData2 = dataManager.getDataObject(0);
% 
% 
% sampler.numSamples = 1000;
% sampler.setParallelSampling(true);
% fprintf('Generating Data\n');
% tic
% sampler.createSamples(newData);
% toc
% 
% fprintf('Merging Data\n');
% tic
% newData2.mergeData(newData);
% toc   
% 
% fprintf('Generating Data 2nd time\n');
% tic
% sampler.createSamples(newData);
% toc
% 
% fprintf('Merging Data\n');
% tic
% newData2.mergeData(newData);
% toc
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% %%
% dataManager = Data.DataManager('steps');
% settings = Common.Settings();
% 
% dimState    = 0; 
% dimAction   = 2;
% dataManager.addDataEntry('states', dimState);
% dataManager.addDataEntry('actions', dimAction);
% dataManager.addDataEntry('options', 1, 1, 3);
% settings.setProperty('numOptions',3);
% % dataManager.addDataEntry('responsibilities', settings.getProperty('numOptions') ); %Is that correct?
% 
% dataManager.addDataEntry('rewardWeighting', 1);
% 
% dataManager.addDataEntry('logQAso', 1); %not completely intuitive maybe
% dataManager.addDataEntry('logQAsoAllOptions', settings.getProperty('numOptions')); %Couldn't we add this in the mixture model?
% 
% 
% dataManager.finalizeDataManager();
% 
% numSamples = 100;
% newData = dataManager.getDataObject(numSamples);
% newData.setDataEntry('states', randn(numSamples,dimState));
% newData.setDataEntry('options', randi(settings.getProperty('numOptions'),numSamples,1));
% 
% 
% gaussianDist  = Distributions.Gaussian.GaussianLinearInFeatures(dataManager, 'actions', 'states', 'ActionPolicy');
% %we dont want no states for now
% % gaussianDist  = Distributions.Gaussian.GaussianStateDistribution %<- DOESNT WORK I WANT A DIST JUST OVER ACTIONS
% % gaussianDist  = @Distributions.Gaussian.GaussianLinearInFeatures;
% actionPolicyLearner = Learner.SupervisedLearner.LinearGaussianMLLearner(dataManager, gaussianDist);
% actionPolicyInitializer = @Distributions.Gaussian.GaussianLinearInFeatures;
% %this seems a bit weird. We first have to create a dist to init the
% %learner, but then the mmlearner will set a different dist for the
% %optionlearner. 
% 
% 
% 
% terminationDist    = Distributions.Discrete.LogisticDistribution(dataManager, 'terminations', squaredFeatures.outputName, 'testFunction');
% terminationLearner = Learner.ClassificationLearner.LogisticRegressionLearner(dataManager,terminationDist, true);
% terminationLearner.logisticRegressionLearningRate = 1;
% 
% gatingDist = Distributions.Discrete.SoftMaxDistribution(dataManager, 'options', squaredFeatures.outputName, 'GatingPolicy');
% gatingLearner = Learner.ClassificationLearner.MultiClassLogisticRegressionLearner(dataManager,gatingDist, true); %true or false?
% gatingLearner.softMaxRegressionLearningRate = 0.1;
% 
% 
% mixtureModel  = Distributions.MixtureModel.MixtureModel(dataManager, actionPolicyInitializer, 'actions', 'states', 'options');
% mixtureModelLearner = Learner.SupervisedLearner.MixtureModelLearner(dataManager, mixtureModel, actionPolicyLearner, gatingLearner, 'responsibilities')
% 
% EMLearner     = Learner.ExpectationMaximization.EMHiREPS(dataManager, mixtureModel, mixtureModelLearner)
% 
% 
% 
% mixtureModel.initObject();
% gatingDist.initObject();
% terminationDist.initObject();
% 
% 
% mixtureModel.callDataFunction('sampleFromDistribution', newData);
% 
% mixtureModel.callDataFunction('getDataProbabilities', newData);
% 
% 
% 
% 
% 
% 
% %%
% numOptions = 3;
% samples = zeros(numSamples*numOptions,dimState+dimAction);
% responsibilities = ones(numSamples*numOptions,numOptions);
% for o = 1 : numOptions 
%     mean = ones(1,dimState+dimAction) * o * 10;
%     sigma = [3, 0; 0, 1] * 9;
%     sigmaCorr = [0 , 1; 1, 0] * rand * 8;
% %     sigmaCorr = rand(2)*4;
% %     sigmaCorr = (sigmaCorr' + sigmaCorr)/2;
%     sigma = sigma + sigmaCorr;
%     idx = (o-1) * numSamples;
%     samples(idx+1 : idx + numSamples,:) = mvnrnd(mean,sigma,numSamples);
%     responsibilities(idx+1 : idx+numSamples,o) = ones(numSamples,1)*3;
% end
% 
% responsibilities = bsxfun(@rdivide, responsibilities, sum(responsibilities,2));
% newData = dataManager.getDataObject(numSamples*numOptions);
% newData.setDataEntry('actions', samples);
% newData.setDataEntry('responsibilities', responsibilities);
% 
% %%
% % 
% 
% 
% % mixtureModelLearner.updateModel(newData);
% 
% EMLearner.updateModel(newData);
% 
% 
% % plot(samples(:,1), samples(:,2),'*')
% % hold all
% % for o = 1 : numOptions
% %     plot(mixtureModel.getOption(o).bias(1),mixtureModel.getOption(o).bias(2),'r*')
% % end
% 
% 
% %%
% % 
% % %First test the linear regression
% % learnerFunction.updateModel(newData);
% % 
% % %this is what we set initially
% % [weights, bias]
% % 
% % %this is what we estimated
% % [gaussianDist.weights, gaussianDist.bias]
% % 
% % %Now test the estimation of the covariance (note: The distribution learner
% % %does both for you, regression and covariance estimation
% % learnerDistribution = Learner.SupervisedLearner.LinearGaussianMLLearner(dataManager, gaussianDist);
% % learnerDistribution.updateModel(newData);
% % 
% % %this is what we set initially
% % [Sigma2]
% % 
% % %this is what we estimated
% % [gaussianDist.getCovariance()]
% % 
% % % Now do the same stuff with a weighting
% % 
% % newData.setDataEntry('rewardWeighting', ones(newData.getNumElements(),1));
% % learnerDistribution.setWeightName('rewardWeighting');
% % learnerDistribution.updateModel(newData);
% % 
% % %this is what we set initially
% % [Sigma2]
% % 
% % %this is what we estimated
% % [gaussianDist.getCovariance()]

