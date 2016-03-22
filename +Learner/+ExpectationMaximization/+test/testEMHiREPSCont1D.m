clear variables;
close all;
addpath(genpath('Helpers/'));
addpath Helper/

sampler = Sampler.EpisodeWithStepsSamplerOptions();

dataManager = sampler.getEpisodeDataManager();

settings = Common.Settings();

dimState    = 1; 
dimAction   = 1;
numOptions  = 2;
numEpisodes = 10;
numTimeSteps = 20;
dataManager.addDataEntry('steps.states', dimState);
dataManager.addDataEntry('steps.actions', dimAction);
dataManager.addDataEntry('steps.options', 1, 1, numOptions);
dataManager.addDataEntry('steps.optionsOld', 1, 1, numOptions);
dataManager.addDataEntry('steps.terminations', 1, numOptions, 2);

settings.setProperty('numOptions',numOptions);
settings.setProperty('numIterationsEM',2e2);
settings.setProperty('logLikelihoodThresholdEM',1e-6);
settings.setProperty('softMaxRegressionTerminationFactor',1e-6);
settings.setProperty('numTimeSteps', numTimeSteps);


% dataManager.addDataEntry('steps.rewardWeighting', 1);


% squaredFeatures = FeatureGenerators.SquaredFeatures(dataManager, 'states', [], true);
linearFeatures  = FeatureGenerators.LinearFeatures(dataManager, 'states', [], true);




terminationPolicy   = Distributions.Discrete.LogisticDistribution(dataManager, 'terminations', linearFeatures.outputName, 'terminationFunction');
terminationLearner  = Learner.ClassificationLearner.LogisticRegressionLearner(dataManager,terminationPolicy, true);
terminationLearner.logisticRegressionLearningRate = 1;
% terminationPolicy.setTheta(rand(1,dataManager.getNumDimensions('statesLinear')) -0.5);

terminationPolicyInitializer   = @Distributions.Discrete.LogisticDistribution;

gaussianDist  = Distributions.Gaussian.GaussianLinearInFeatures(dataManager, 'actions', 'states', 'ActionPolicy');

optionLearner = Learner.SupervisedLearner.LinearGaussianMLLearner(dataManager, gaussianDist);
optionInitializer = @Distributions.Gaussian.GaussianLinearInFeatures;


gatingDist    = Distributions.Discrete.SoftMaxDistribution(dataManager, 'options', linearFeatures.outputName, 'Gating');
gatingLearner = Learner.ClassificationLearner.MultiClassLogisticRegressionLearner(dataManager, gatingDist, true); %false or true???

% gatingDist.setThetaAllItems(rand(dataManager.getMaxRange('options'),dataManager.getNumDimensions('statesSquared')) -0.5);


mixtureModel  = Distributions.MixtureModel.MixtureModelWithTermination.createPolicy(...
    dataManager, gatingDist, optionInitializer, 'actions', 'states', terminationPolicy.inputVariables{1},...
    terminationPolicyInitializer,'options','optionsOld');

sampler.getStepSampler.setIsActiveSampler(Sampler.IsActiveStepSampler.IsActiveNumSteps(dataManager));

environment = Learner.ExpectationMaximization.test.HMMTestEnvCont1D(dataManager, mixtureModel);

mixtureModel.initObject();
gatingDist.initObject();
terminationPolicy.initObject();

mixtureModelLearner = Learner.SupervisedLearner.TerminationMMLearner(dataManager, mixtureModel, optionLearner, gatingLearner, terminationLearner,  'responsibilities');
EMLearner     = Learner.ExpectationMaximization.EMHiREPSContinuous (dataManager, mixtureModel, mixtureModelLearner);


sampler.setContextSampler(environment);
sampler.setActionPolicy(mixtureModel);
sampler.setTransitionFunction(environment);
sampler.setRewardFunction(environment);
sampler.setInitialStateSampler(environment);

dataManager.finalizeDataManager();
newData = dataManager.getDataObject(numEpisodes);
newData.setDataEntry('states', randn(numEpisodes,dimState), :,1 ); %[episode, step]
newData.setDataEntry('optionsOld',randi(numOptions,numEpisodes,1) ,:, 1);


sampler.numSamples = numEpisodes;
sampler.setParallelSampling(true);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize Model
% generatingMixtureModel = mixtureModel.clone();
theta = [-2, 3; -2, -3];
mixtureModel.terminationMM.terminations{1}.setTheta( theta(1,:) );
mixtureModel.terminationMM.terminations{2}.setTheta( theta(2,:) );

theta = [0 -1; 0 1 ];
mixtureModel.gating.setThetaAllItems(theta);

weights = [0 ; 0];
bias    = [10 ; -10];
mixtureModel.options{1}.setWeightsAndBias(weights(1,:), bias(1,:));
mixtureModel.options{2}.setWeightsAndBias(weights(2,:), bias(2,:));
EMLearner.setGeneratingModel(mixtureModel, 'generatingModel');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

fprintf('Generating Data\n');
tic
sampler.createSamples(newData);
toc
statesOri = newData.getDataEntry('states');


% Do it once for reference
settings.setProperty('numIterationsEM',2);
settings.setProperty('debugPlottingEM',false);
% EMLearner.updateModel(newData);
% figure; plot(EMLearner.logLikelihood)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Reset Model
theta = (rand(numOptions,dataManager.getNumDimensions(mixtureModel.terminationMM.inputVariables{1}))-0.5) * 10;
mixtureModel.terminationMM.terminations{1}.setTheta( theta(1,:) );
mixtureModel.terminationMM.terminations{2}.setTheta( theta(2,:) );

theta = (rand(numOptions,dataManager.getNumDimensions(mixtureModel.gating.inputVariables{1}))-0.5) * 10;
mixtureModel.gating.setThetaAllItems(theta);

weights = [0 ; 0];
bias    = (rand(2,1)-0.5) *10;
mixtureModel.options{1}.setWeightsAndBias(weights(1,:), bias(1,:));
mixtureModel.options{1}.setWeightsAndBias(weights(2,:), bias(2,:));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
settings.setProperty('logLikelihoodThresholdEM',1e-9);
settings.setProperty('numIterationsEM',50);
settings.setProperty('debugPlottingEM',true);
settings.setProperty('useKMeans',true);
EMLearner.updateModel(newData);
figure; plot(EMLearner.logLikelihood)


sampler.createSamples(newData);
statesNew = newData.getDataEntry('states');


figure
subplot(2,1,1)
plot(statesOri(:,1))
subplot(2,1,2)
plot(statesNew(:,1))
