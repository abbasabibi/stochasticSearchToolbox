clear variables;
close all;
addpath(genpath('Helper/'));

warning('RNG is fixed')
rng(1)

numOptions      = 10;
numEpisodes     = 500;
<<<<<<< HEAD
numTimeSteps    = 2;
maxIterationsEM = 10;
toleranceEM     = 1e-19;
=======
numTimeSteps    = 100;
maxIterationsEM = 30;
toleranceEM     = -1e-19;
>>>>>>> f04b73c10e5524948e26652ef4159cb58eacf37d

dt                  = 0.01;
dtBase              = 0.05;
numStepsPerDecision = 5;
restartProb         = 0.02 * dt/dtBase * numStepsPerDecision;

minRangeContexts = [-pi, -30]; %[pi - pi/4, -5];
maxRangeContexts = [pi, 30];% [pi + pi/4, +5];
maxRangeActions     = 50;


settings = Common.Settings();



settings.setProperty('numOptions',numOptions);
settings.setProperty('numIterationsEM',maxIterationsEM);
settings.setProperty('logLikelihoodThresholdEM',toleranceEM);
settings.setProperty('numTimeSteps', numTimeSteps);
settings.setProperty('InitialStateDistributionMinRange', minRangeContexts);
settings.setProperty('InitialStateDistributionMaxRange', maxRangeContexts);
settings.setProperty('InitialStateDistributionType', 'Uniform');


settings.setProperty('numImitationEpisodes', numEpisodes);
settings.setProperty('numImitationSteps', numTimeSteps);

settings.setProperty('periodicRange', [-pi,pi]);

settings.setProperty('debugPlottingMM', true);




settings.setProperty('dt', dt);
% settings.setProperty('numStepsPerDecision', numStepsPerDecision);
% settings.setProperty('resetProbDecisionSteps', restartProb);


sampler             = Sampler.EpisodeWithStepsSamplerOptions();
dataManager         = sampler.getEpisodeDataManager();
dataManager.finalizeDataManager();


%%
depth = dataManager.getDataEntryDepth('contexts');

% dataManager.addDataEntryForDepth(depth, 'states', dimState);
% dataManager.addDataEntryForDepth(depth, 'actions', dimAction);
dataManager.addDataEntryForDepth(depth, 'options', 1, 1, numOptions);
dataManager.addDataEntryForDepth(depth, 'optionsOld', 1, 1, numOptions);
dataManager.addDataEntryForDepth(depth, 'terminations', 1, 1, 2);

environment         = Environments.DynamicalSystems.Pendulum(sampler, true); %non periodic
environment.initObject();

initialStateSampler = Sampler.InitialSampler.InitialStateSamplerStandard(sampler);
% contextSampler      = Sampler.InitialSampler.InitialContextSamplerStandard(sampler);
% initialStateSampler.setInitStateFromContext(true); %Set this to false to try fake settings
%
% endStageSampler     = Sampler.test.EnvironmentStageTest(controller); %Change stuff in here
%
%
sampler.setTransitionFunction(environment);
sampler.setInitialStateSampler(initialStateSampler);
% sampler.setContextSampler(contextSampler);
% sampler.stageSampler.setEndStateTransitionSampler(endStageSampler);
% sampler.stageSampler.stepSampler.setIsActiveSampler(controller);



actionCost = 0;
stateCost = [10 0; 0 0];
rewardFunction = RewardFunctions.QuadraticRewardFunctionSwingUpSimple(dataManager); %non multimodal reward
rewardFunction.setStateActionCosts(stateCost, actionCost);
returnSampler       = RewardFunctions.ReturnForEpisode.ReturnAvgReward(dataManager);



sampler.setRewardFunction(rewardFunction);
sampler.setReturnFunction(returnSampler);
sampler.getStepSampler.setIsActiveSampler(Sampler.IsActiveStepSampler.IsActiveNumSteps(dataManager));



dataManager.finalizeDataManager();
dataManager.setRange('states', minRangeContexts, maxRangeContexts);
% dataManager.setRange('contexts', minRangeContexts, maxRangeContexts);
dataManager.setRange('actions', -maxRangeActions, maxRangeActions);

sampler.initObject();
dataManager.finalizeDataManager();




% dataManager.addDataEntry('steps.rewardWeighting', 1);


squaredFeatures = FeatureGenerators.SquaredFeatures(dataManager, 'states', [], false);
linearFeatures  = FeatureGenerators.LinearFeatures(dataManager, 'states', [], true);




terminationPolicy   = Distributions.Discrete.LogisticDistribution(dataManager, 'terminations', squaredFeatures.outputName, 'terminationFunction');
% terminationPolicy   = Distributions.Discrete.LogisticDistribution(dataManager, 'terminations', 'states', 'terminationFunction');
terminationLearner  = Learner.ClassificationLearner.LogisticRegressionLearner(dataManager,terminationPolicy, true);
terminationPolicy.setTheta(rand(1,dataManager.getNumDimensions(linearFeatures.outputName)) -0.5);

terminationPolicyInitializer   = @Distributions.Discrete.LogisticDistribution;

gaussianDist  = Distributions.Gaussian.GaussianLinearInFeatures(dataManager, 'actions', 'states', 'ActionPolicy');

optionLearner = Learner.SupervisedLearner.LinearGaussianMLLearner(dataManager, gaussianDist);
optionInitializer = @Distributions.Gaussian.GaussianLinearInFeatures;


gatingDist    = Distributions.Discrete.SoftMaxDistribution(dataManager, 'options', squaredFeatures.outputName, 'Gating');
% gatingDist    = Distributions.Discrete.SoftMaxDistribution(dataManager, 'options', 'states', 'Gating');
gatingLearner = Learner.ClassificationLearner.MultiClassLogisticRegressionLearner(dataManager, gatingDist, true); %false or true???

gatingDist.setThetaAllItems(rand(size(gatingDist.thetaAllItems)) -0.5);


mixtureModel  = Distributions.MixtureModel.MixtureModelWithTermination.createPolicy(...
    dataManager, gatingDist, optionInitializer, 'actions', 'states', terminationPolicy.inputVariables{1},...
    terminationPolicyInitializer,'options','optionsOld');
mixtureModel.baseInputVariable          = 'states';


sampler.setActionPolicy(mixtureModel);
sampler.setParallelSampling(true);


mixtureModel.initObject();
gatingDist.initObject();
terminationPolicy.initObject();

mixtureModelLearner = Learner.SupervisedLearner.TerminationMMLearner(dataManager, mixtureModel, optionLearner, gatingLearner, terminationLearner,  'responsibilities');
EMLearner     = Learner.ExpectationMaximization.EMHiREPSContinuous (dataManager, mixtureModel, mixtureModelLearner);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
dataManager.finalizeDataManager();
% newData = dataManager.getDataObject([numEpisodes, numTimeSteps]);

settings.setProperty('debugPlottingEM',false);
settings.setProperty('useKMeans',true);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Create Reference Data
dataManager.finalizeDataManager();
newData = dataManager.getDataObject([numEpisodes, numTimeSteps]);
fileSampler = Sampler.SamplerFromFile(dataManager, 'Helper/PendulumTrajs/dataHiREPS.mat');
fileSampler.createSamples(newData);
 
%%
% load Helper/PendulumTrajs/data
% newData.setDataEntry('states', data.states(1:numEpisodes*data.steps(1).numElements,:));
% newData.setDataEntry('actions', data.actions(1:numEpisodes*data.steps(1).numElements));
Plotter.PlotterData.plotTrajectories(newData, 'states',1,15);
title('InputData');
figure(16)
plot(newData.getDataEntry('actions'),'*')
title('InputActions');
pause(1)
% EMLearner.setGeneratingModel(trial.parameterPolicy, 'generatingModel');

EMLearner.updateModel(newData);
figure; 
pause(1)
plot(EMLearner.logLikelihood)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PLOTTING
angleRange = pi;
VResolution = 100;


[x, y] = meshgrid( linspace(-angleRange, angleRange, VResolution), linspace(-30, 30, VResolution));
x = x';
y = y';
contextVec      = [x(:), y(:)];
plotData        = dataManager.getDataObject(size(contextVec,1));
plotData.setDataEntry('states', contextVec);

for i = 2 : 2
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
    
    % [~, maxRespsIdx] = max(resps,[],2);
    % respsMat                        = reshape(maxRespsIdx, VResolution, VResolution);
    % respsMat                        = respsMat';
    % imagesc([-angleRange, angleRange],[-30, 30],respsMat);
    % colorbar
    
    policyExpectationMat            = reshape(policyExpectation, VResolution, VResolution);
    policyExpectationMat            = policyExpectationMat';
    imagesc([-angleRange, angleRange],[-30, 30],policyExpectationMat);
    set(gca,'YDir','normal');
    colorbar
    title(figTitle);
    pause(0.1)
end


%%
plotData        = dataManager.getDataObject();

numTestEpisodes     = 50;
numTestTimeSteps    = 100;

sampler.stepSampler.isActiveSampler.numTimeSteps = numTestTimeSteps;
sampler.numSamples  = numTestEpisodes;
sampler.createSamples(plotData);
Plotter.PlotterData.plotTrajectories(plotData, 'jointPositions');
hold on


% for i = 1 : numTestEpisodes
%     terminationsNew     = newData.getDataEntry('terminations',i);
%     contextsNew         = newData.getDataEntry('states',i);
%     terminationsNewIdx  = terminationsNew == 1;
%     steps               = 1 : length(terminationsNew);
%     plot(steps(terminationsNewIdx), contextsNew(terminationsNewIdx,1),'r*');
% end

title('OutputData');
