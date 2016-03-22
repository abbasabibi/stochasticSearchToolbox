clear variables;
close all;
addpath(genpath('Helper/'));

% rng(10)

sampler = Sampler.EpisodeWithStepsSamplerOptions();

dataManager = sampler.getEpisodeDataManager();

settings = Common.Settings();

dimState    = 2; 
dimAction   = 1;
numOptions  = 2;
numEpisodes = 1;
numTimeSteps = 150;
numIterationsEM = 10;
dataManager.addDataEntry('steps.states', dimState);
dataManager.addDataEntry('steps.actions', dimAction);
dataManager.addDataEntry('steps.options', 1, 1, numOptions);
dataManager.addDataEntry('steps.optionsOld', 1, 1, numOptions);
dataManager.addDataEntry('steps.terminations', 1, 1, 2);


settings.setProperty('numOptions',numOptions);
settings.setProperty('logLikelihoodThresholdEM',-1e-3);
settings.setProperty('softMaxRegressionTerminationFactor',1e-9);
settings.setProperty('softMaxRegressionToleranceF', 1e-15);
settings.setProperty('numTimeSteps', numTimeSteps);

settings.setProperty('logisticRegressionRegularizer',1e-7);
settings.setProperty('logisticRegressionNumIterations',1000);
settings.setProperty('logisticRegressionLearningRate',1e-2);


% dataManager.addDataEntry('steps.rewardWeighting', 1);


squaredFeatures = FeatureGenerators.SquaredFeatures(dataManager, 'states', [], true);
linearFeatures  = FeatureGenerators.LinearFeatures(dataManager, 'states', [], true);




% terminationPolicy   = Distributions.Discrete.LogisticDistribution(dataManager, 'terminations', squaredFeatures.outputName, 'terminationFunction');
terminationPolicy   = Distributions.Discrete.LogisticDistribution(dataManager, 'terminations', 'states', 'terminationFunction');
terminationLearner  = Learner.ClassificationLearner.LogisticRegressionLearner(dataManager,terminationPolicy, true);
terminationPolicy.setTheta(rand(1,dataManager.getNumDimensions('statesLinear')) -0.5);

terminationPolicyInitializer   = @Distributions.Discrete.LogisticDistribution;

gaussianDist  = Distributions.Gaussian.GaussianLinearInFeatures(dataManager, 'actions', 'states', 'ActionPolicy');

optionLearner = Learner.SupervisedLearner.LinearGaussianMLLearner(dataManager, gaussianDist);
optionInitializer = @Distributions.Gaussian.GaussianLinearInFeatures;


% gatingDist    = Distributions.Discrete.SoftMaxDistribution(dataManager, 'options', squaredFeatures.outputName, 'Gating');
gatingDist    = Distributions.Discrete.SoftMaxDistribution(dataManager, 'options', 'states', 'Gating');
gatingLearner = Learner.ClassificationLearner.MultiClassLogisticRegressionLearner(dataManager, gatingDist, true); %false or true???

gatingDist.setThetaAllItems(rand(size(gatingDist.thetaAllItems)) -0.5);


mixtureModel  = Distributions.MixtureModel.MixtureModelWithTermination.createPolicy(...
    dataManager, gatingDist, optionInitializer, 'actions', 'states', terminationPolicy.inputVariables{1},...
    terminationPolicyInitializer,'options','optionsOld');

sampler.getStepSampler.setIsActiveSampler(Sampler.IsActiveStepSampler.IsActiveNumSteps(dataManager));

environment = Learner.ExpectationMaximization.test.HMMTestEnvCont(dataManager, mixtureModel);

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize Model
% generatingMixtureModel = mixtureModel.clone();
% theta = [0, 0, 1, 0, 0, 0; 0, 0, -1, 0, 0, 0];
thetaTerminations = [ 0, 1;  0, -1];
mixtureModel.terminationMM.terminations{1}.setTheta( thetaTerminations(1,:) );
mixtureModel.terminationMM.terminations{2}.setTheta( thetaTerminations(2,:) );

% theta = [0 -1 0 0 0 0 ; 0 1 0 0 0 0];
thetaGating = [-1 0 ; 1 0 ];
mixtureModel.gating.setThetaAllItems(thetaGating);

weights = [0,0 ; 0,0];
bias    = [1 ; -1];
mixtureModel.options{1}.setWeightsAndBias(weights(1,:), bias(1,:));
mixtureModel.options{2}.setWeightsAndBias(weights(2,:), bias(2,:));
EMLearner.setGeneratingModel(mixtureModel, 'generatingModel');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
dataManager.finalizeDataManager();
newData = dataManager.getDataObject(numEpisodes);
newData.setDataEntry('states', randn(numEpisodes,dimState), :,1 ); %[episode, step]
newData.setDataEntry('optionsOld',randi(numOptions,numEpisodes,1) ,:, 1);


sampler.numSamples = numEpisodes;
sampler.setParallelSampling(true);
% fprintf('Generating Data\n');
% tic
sampler.createSamples(newData);
% toc
statesOri   = newData.getDataEntry('states');
optionsOri  = newData.getDataEntry('options');
terminationsOri = newData.getDataEntry('terminations');

% Do it once for reference
settings.setProperty('numIterationsEM',2);
settings.setProperty('debugPlottingEM',false);
% EMLearner.updateModel(newData);
% figure; plot(EMLearner.logLikelihood)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Reset Model
% generatingMixtureModel = mixtureModel.clone();
theta = (rand(2,size(mixtureModel.terminationMM.terminations{1}.theta,2))-0.5) * 10;
mixtureModel.terminationMM.terminations{1}.setTheta( theta(1,:) );
mixtureModel.terminationMM.terminations{2}.setTheta( theta(2,:) );

theta = (rand(2,size(mixtureModel.terminationMM.terminations{1}.theta,2))-0.5) * 10;
mixtureModel.gating.setThetaAllItems(theta);

weights = [0,0 ; 0,0];
bias    = (rand(2,1)-0.5) *10;
mixtureModel.options{1}.setWeightsAndBias(weights(1,:), bias(1,:));
mixtureModel.options{2}.setWeightsAndBias(weights(2,:), bias(2,:));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


settings.setProperty('numIterationsEM',numIterationsEM);
settings.setProperty('debugPlottingEM',true);
settings.setProperty('useKMeans',false);
EMLearner.updateModel(newData);

EMLearner.logLikelihood(end)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PLOTTING
if(usejava('jvm') && usejava('desktop') )
    figure; plot(EMLearner.logLikelihood)

    sampler.createSamples(newData);
    statesNew   = newData.getDataEntry('states');
    optionsNew  = newData.getDataEntry('options');
    terminationsNew = newData.getDataEntry('terminations');
    figure(10)
    hold on
    plot(statesOri(:,1),statesOri(:,2),'b*')
    plot(statesNew(:,1),statesNew(:,2),'r*')
    
    option1IdxOri = optionsOri ==1;
    option1IdxNew = optionsNew ==1;
    
    terminationsOriIdx = terminationsOri == 1;
    terminationsNewIdx = terminationsNew == 1;
    steps = 1 : length(terminationsNew);
    
    figure(11)
    subplot(2,2,1)
    % clf
    hold on
    tmpStates1 = statesOri(:,1);
    tmpStates2 = statesOri(:,1);
    tmpStates1(~option1IdxOri) = NaN;
    tmpStates2(option1IdxOri) = NaN;
    plot(tmpStates1, 'b')
    plot(tmpStates2, 'm')
    plot(steps(terminationsOriIdx), statesOri(terminationsOriIdx,1),'r*');
    % plot(statesOri(option1IdxOri,1), 'b*')
    % plot(statesOri(~option1IdxOri,1), 'm*')
    subplot(2,2,2)
    plot(statesOri(:,2))
    
    subplot(2,2,3)
    % clf
    hold on
    tmpStates1 = statesNew(:,1);
    tmpStates2 = statesNew(:,1);
    tmpStates1(~option1IdxNew) = NaN;
    tmpStates2(option1IdxNew) = NaN;
    plot(tmpStates1, 'b')
    plot(tmpStates2, 'm')
    plot(steps(terminationsNewIdx), statesNew(terminationsNewIdx,1),'r*');
    % plot(statesNew(:,1))
    subplot(2,2,4)
    plot(statesNew(:,2))
    
    estimWeights    = [mixtureModel.options{1}.weights ; mixtureModel.options{2}.weights];
    estimBias       = [mixtureModel.options{1}.bias ; mixtureModel.options{2}.bias];
    
    estimTerminations = [mixtureModel.terminationMM.terminations{1}.theta ; mixtureModel.terminationMM.terminations{2}.theta];
    estimGating     = mixtureModel.gating.thetaAllItems;
end
% [weights, estimWeights ]
% [bias, estimBias]
% [thetaTerminations, estimTerminations]
% [thetaGating, estimGating]