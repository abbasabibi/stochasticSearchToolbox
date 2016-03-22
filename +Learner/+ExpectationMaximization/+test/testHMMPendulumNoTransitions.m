clear variables;
close all;
addpath(genpath('Helper/'));


numOptions  = 10;
numEpisodes = 100;
numTimeSteps = 100;

dt                  = 0.01;
dtBase              = 0.05;
numStepsPerDecision = 5;
restartProb         = 0.02 * dt/dtBase * numStepsPerDecision;

settings = Common.Settings();



settings.setProperty('numOptions',numOptions);
settings.setProperty('numIterationsEM',2e2);
settings.setProperty('logLikelihoodThresholdEM',1e-3);
settings.setProperty('softMaxRegressionTerminationFactor',1e-9);
settings.setProperty('softMaxRegressionToleranceF', 1e-15);
settings.setProperty('numTimeSteps', numTimeSteps);


settings.setProperty('dt', dt);
settings.setProperty('numStepsPerDecision', numStepsPerDecision);
settings.setProperty('resetProbDecisionSteps', restartProb);


sampler             = Sampler.EpisodeWithDecisionStagesSampler();
dataManager         = sampler.getEpisodeDataManager();


% dataManager.addDataEntry('steps.states', dimState);
% dataManager.addDataEntry('steps.actions', dimAction);
% dataManager.addDataEntry('steps.options', 1, 1, numOptions);
depth = dataManager.getDataEntryDepth('contexts');
dataManager.addDataEntryForDepth(depth, 'optionsOld', 1, 1, numOptions);
dataManager.addDataEntryForDepth(depth, 'terminations', 1, 1, 2);

sampler.stageSampler.setIsActiveSampler(Sampler.IsActiveStepSampler.IsActiveFixedGamma(dataManager, 'decisionSteps'));
dataManager.addDataEntryForDepth(depth, 'options', 1, 1, numOptions);
environment         = Environments.DynamicalSystems.Pendulum(sampler, true); %non periodic
environment.initObject();
controller          = TrajectoryGenerators.TrajectoryTracker.GoalAttractor(dataManager, 1);

initialStateSampler = Sampler.InitialSampler.InitialStateSamplerStandard(sampler);
contextSampler      = Sampler.InitialSampler.InitialContextSamplerStandard(sampler);
initialStateSampler.setInitStateFromContext(true); %Set this to false to try fake settings 

endStageSampler     = Sampler.test.EnvironmentStageTest(controller); %Change stuff in here


sampler.setTransitionFunction(environment);
sampler.setInitialStateSampler(initialStateSampler);
sampler.setContextSampler(contextSampler);
sampler.stageSampler.setEndStateTransitionSampler(endStageSampler);
sampler.stageSampler.stepSampler.setIsActiveSampler(controller);

actionCost = 0;
stateCost = [10 0; 0 0];
rewardFunction = RewardFunctions.QuadraticRewardFunctionSwingUpSimple(dataManager); %non multimodal reward
rewardFunction.setStateActionCosts(stateCost, actionCost);
returnSampler       = RewardFunctions.ReturnForEpisode.ReturnAvgReward(dataManager);



dataManager.finalizeDataManager();
% minRangeContexts = [- pi, -30]; 
% maxRangeContexts = [+ pi, 30];
minRangeContexts = [pi - pi/4, -5]; 
maxRangeContexts = [pi + pi/4, +5];
maxRange = 3;
dataManager.setRange('contexts', minRangeContexts, maxRangeContexts);
dataManager.setRange('parameters', -maxRange, maxRange);

sampler.initObject();
dataManager.finalizeDataManager();




% dataManager.addDataEntry('steps.rewardWeighting', 1);


squaredFeatures = FeatureGenerators.SquaredFeatures(dataManager, 'contexts', [], false);
linearFeatures  = FeatureGenerators.LinearFeatures(dataManager, 'contexts', [], true);




terminationPolicy   = Distributions.Discrete.LogisticDistribution(dataManager, 'terminations', squaredFeatures.outputName, 'terminationFunction');
% terminationPolicy   = Distributions.Discrete.LogisticDistribution(dataManager, 'terminations', 'states', 'terminationFunction');
terminationLearner  = Learner.ClassificationLearner.LogisticRegressionLearner(dataManager,terminationPolicy, true);
terminationPolicy.setTheta(rand(1,dataManager.getNumDimensions(linearFeatures.outputName)) -0.5);

terminationPolicyInitializer   = @Distributions.Discrete.LogisticDistribution;

gaussianDist  = Distributions.Gaussian.GaussianLinearInFeatures(dataManager, 'parameters', 'contexts', 'ActionPolicy');

optionLearner = Learner.SupervisedLearner.LinearGaussianMLLearner(dataManager, gaussianDist);
optionInitializer = @Distributions.Gaussian.GaussianLinearInFeatures;


gatingDist    = Distributions.Discrete.SoftMaxDistribution(dataManager, 'options', squaredFeatures.outputName, 'Gating');
% gatingDist    = Distributions.Discrete.SoftMaxDistribution(dataManager, 'options', 'states', 'Gating');
gatingLearner = Learner.ClassificationLearner.MultiClassLogisticRegressionLearner(dataManager, gatingDist, true); %false or true???

gatingDist.setThetaAllItems(rand(size(gatingDist.thetaAllItems)) -0.5);


mixtureModel  = Distributions.MixtureModel.MixtureModelWithTermination.createParameterPolicy(...
    dataManager, gatingDist, optionInitializer, 'parameters', 'contexts', terminationPolicy.inputVariables{1},...
    terminationPolicyInitializer,'options','optionsOld');


sampler.stageSampler.setRewardFunction(rewardFunction);
sampler.stageSampler.setReturnFunction(returnSampler);

sampler.stageSampler.setParameterPolicy(mixtureModel);
sampler.stageSampler.setActionPolicy(controller);
sampler.setParallelSampling(true);


mixtureModel.initObject();
gatingDist.initObject();
terminationPolicy.initObject();

mixtureModelLearner = Learner.SupervisedLearner.TerminationMMLearner(dataManager, mixtureModel, optionLearner, gatingLearner, terminationLearner,  'responsibilities');
EMLearner     = Learner.ExpectationMaximization.EMHiREPSContinuous (dataManager, mixtureModel, mixtureModelLearner);


% sampler.setContextSampler(environment);
% sampler.setActionPolicy(mixtureModel);
% sampler.setTransitionFunction(environment);
% sampler.setRewardFunction(environment);
% sampler.setInitialStateSampler(environment);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
dataManager.finalizeDataManager();
newData = dataManager.getDataObject([numEpisodes, numTimeSteps]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Reset Model
% generatingMixtureModel = mixtureModel.clone();
theta = (rand(numOptions,size(mixtureModel.terminationMM.terminations{1}.theta,2))-0.5) * 10;
mixtureModel.terminationMM.terminations{1}.setTheta( theta(1,:) );
mixtureModel.terminationMM.terminations{2}.setTheta( theta(2,:) );

theta = (rand(numOptions,size(mixtureModel.terminationMM.terminations{1}.theta,2))-0.5) * 10;
mixtureModel.gating.setThetaAllItems(theta);

weights = zeros(numOptions, newData.getNumDimensions(mixtureModel.inputVariables{1}));
bias    = (rand(numOptions,1)-0.5) *10;
for o = 1 : numOptions
    mixtureModel.options{o}.setWeightsAndBias(weights(o,:), bias(o,:));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


settings.setProperty('numIterationsEM',1);
settings.setProperty('debugPlottingEM',false);
settings.setProperty('useKMeans',true);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Create Reference Data
%This doesnt work, need to ask geri
load('/scratch/git/policysearchtoolbox/+Experiments/data/test/PendulumPeriodic_RBFStates_contextsKernel_SquaredFeatures_MixtureModel_HiREPS_PendulumPlotter/numOptionsTrial/trial.mat');
isActiveStepSampler = Sampler.IsActiveStepSampler.IsActiveNumSteps(trial.dataManager, 'decisionSteps');
isActiveStepSampler.numTimeSteps = numTimeSteps;
trial.sampler.stageSampler.setIsActiveSampler(isActiveStepSampler);
trial.sampler.numSamples = numEpisodes;
tmpData = trial.dataManager.getDataObject(numEpisodes); trial.sampler.createSamples(tmpData);

newData.setDataEntry('contexts',tmpData.getDataEntry('contexts' ))
newData.setDataEntry('parameters', tmpData.getDataEntry('parameters' ));
Plotter.PlotterData.plotTrajectories(newData, 'contexts',1);
title('InputData');
% EMLearner.setGeneratingModel(trial.parameterPolicy, 'generatingModel');

EMLearner.updateModel(newData);
figure; plot(EMLearner.logLikelihood)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PLOTTING


angleRange = pi;
VResolution = 100;


[x, y] = meshgrid( linspace(-angleRange, angleRange, VResolution), linspace(-30, 30, VResolution));
x = x';
y = y';
contextVec      = [x(:), y(:)];
plotData        = dataManager.getDataObject(size(contextVec,1));
plotData.setDataEntry('contexts', contextVec);

for i = 1 : 2
figure(28+i); clf;
if(i == 1) 
    currModel   = trial.parameterPolicy;
    figTitle    = 'Original Policy';
else
    currModel   = mixtureModel;
    figTitle    = 'Estimated Policy';
end
resps = currModel.gating.getItemProbabilities([],plotData.getDataEntry(mixtureModel.gating.inputVariables{1}));

[~, optionIdx]      = max(resps,[],2);
optionList          = unique(optionIdx);
policyExpectation   = zeros(size(optionIdx,1),1);
for i = 1 : length(optionList)
    option              = optionList(i);
    sampleSelection     = optionIdx == option;
    contextsForOption   = contextVec(sampleSelection,:);
    numSamples          = size(contextsForOption,1);
    
    policyExpectation(sampleSelection) =  currModel.options{option}.getExpectation(numSamples, contextsForOption);
end

[~, maxRespsIdx] = max(resps,[],2);
respsMat                        = reshape(maxRespsIdx, VResolution, VResolution);
respsMat                        = respsMat';
imagesc([-angleRange, angleRange],[-30, 30],respsMat);
colorbar

policyExpectationMat            = reshape(policyExpectation, VResolution, VResolution);
policyExpectationMat            = policyExpectationMat';
imagesc([-angleRange, angleRange],[-30, 30],policyExpectationMat);
set(gca,'YDir','normal');
colorbar
title(figTitle);
pause(0.1)
end

sampler.numSamples = 30;
sampler.createSamples(newData);
Plotter.PlotterData.plotTrajectories(newData, 'jointPositions');
hold on

terminationsNew     = newData.getDataEntry('terminations');
contextsNew         = newData.getDataEntry('contexts');
terminationsNewIdx  = terminationsNew == 1;
steps               = 1 : length(terminationsNew);

plot(steps(terminationsNewIdx), contextsNew(terminationsNewIdx,1),'r*');

title('OutputData');
% statesNew   = newData.getDataEntry('states');
% optionsNew  = newData.getDataEntry('options');
% terminationsNew = newData.getDataEntry('terminations');
% figure(10)
% hold on
% plot(statesOri(:,1),statesOri(:,2),'b*')
% plot(statesNew(:,1),statesNew(:,2),'r*')
% 
% option1IdxOri = optionsOri ==1;
% option1IdxNew = optionsNew ==1;
% 
% terminationsOriIdx = terminationsOri == 1;
% terminationsNewIdx = terminationsNew == 1;
% steps = 1 : length(terminationsNew);
% 
% figure(11)
% subplot(2,2,1)
% % clf
% hold on
% tmpStates1 = statesOri(:,1);
% tmpStates2 = statesOri(:,1);
% tmpStates1(~option1IdxOri) = NaN;
% tmpStates2(option1IdxOri) = NaN;
% plot(tmpStates1, 'b')
% plot(tmpStates2, 'm')
% plot(steps(terminationsOriIdx), statesOri(terminationsOriIdx,1),'r*');
% % plot(statesOri(option1IdxOri,1), 'b*')
% % plot(statesOri(~option1IdxOri,1), 'm*')
% subplot(2,2,2)
% plot(statesOri(:,2))
% 
% subplot(2,2,3)
% % clf
% hold on
% tmpStates1 = statesNew(:,1);
% tmpStates2 = statesNew(:,1);
% tmpStates1(~option1IdxNew) = NaN;
% tmpStates2(option1IdxNew) = NaN;
% plot(tmpStates1, 'b')
% plot(tmpStates2, 'm')
% plot(steps(terminationsNewIdx), statesNew(terminationsNewIdx,1),'r*');
% % plot(statesNew(:,1))
% subplot(2,2,4)
% plot(statesNew(:,2))
% 
% estimWeights    = [mixtureModel.options{1}.weights ; mixtureModel.options{2}.weights];
% estimBias       = [mixtureModel.options{1}.bias ; mixtureModel.options{2}.bias];
% 
% estimTerminations = [mixtureModel.terminationMM.terminations{1}.theta ; mixtureModel.terminationMM.terminations{2}.theta];
% estimGating     = mixtureModel.gating.thetaAllItems;
% 
% [weights, estimWeights ]
% [bias, estimBias]
% [thetaTerminations, estimTerminations]
% [thetaGating, estimGating]