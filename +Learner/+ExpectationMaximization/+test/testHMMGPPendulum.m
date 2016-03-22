clear variables;
close all;
addpath(genpath('Helper/'));

rng(1)
warning('RNG is fixed');

numOptions      = 10;
numEpisodes     = 20;
numTimeSteps    = 50;
maxIterationsEM = 1;
toleranceEM     = -inf;


minRangeContexts = [-1.5708 -30]; 
maxRangeContexts = [4.7124 30];
maxRangeActions     = 30;
periodicRange = [-0.5 * pi, 1.5 * pi];

settings = Common.Settings();



settings.setProperty('numOptions',numOptions);
settings.setProperty('numIterationsEM',2e2);
settings.setProperty('logLikelihoodThresholdEM',toleranceEM);

settings.setProperty('numTimeSteps', numTimeSteps);
settings.setProperty('InitialStateDistributionMinRange', minRangeContexts);
settings.setProperty('InitialStateDistributionMaxRange', maxRangeContexts);
settings.setProperty('numImitationEpisodes', numEpisodes);
settings.setProperty('periodicRange', periodicRange);




settings.setProperty('softMaxRegressionTerminationFactor',1e-9);
settings.setProperty('softMaxRegressionToleranceF', 1e-15);
settings.setProperty('regularizationRegression', 1e-15);
settings.setProperty('logisticRegressionRegularizer', 1e-20);
settings.setProperty('reinitializeEM', false);


sampler             = Sampler.EpisodeWithStepsSamplerOptions();
dataManager         = sampler.getEpisodeDataManager();
dataManager.finalizeDataManager();



environment         = Environments.DynamicalSystems.Pendulum(sampler, true); %non periodic
environment.initObject();

depth = dataManager.getDataEntryDepth('states');
dataManager.addDataEntryForDepth(depth, 'options', 1, 1, numOptions);
dataManager.addDataEntryForDepth(depth, 'optionsOld', 1, 1, numOptions);
dataManager.addDataEntryForDepth(depth, 'terminations', 1, 1, 2);
% dataManager.addDataEntryForDepth(depth, 'contexts', dataManager.getNumDimensions('states')); %Doesnt work, context is already set as alias?
dataManager.addDataEntry('contexts',2)



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


squaredFeatures = FeatureGenerators.SquaredFeatures(dataManager, 'states', [], true);
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


sampler.setActionPolicy(mixtureModel);
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Reset Model
% generatingMixtureModel = mixtureModel.clone();
theta = (rand(numOptions,size(mixtureModel.terminationMM.terminations{1}.theta,2))-0.5) * 1;
mixtureModel.terminationMM.terminations{1}.setTheta( theta(1,:) );
mixtureModel.terminationMM.terminations{2}.setTheta( theta(2,:) );

theta = (rand(numOptions,size(mixtureModel.terminationMM.terminations{1}.theta,2))-0.5) * 1;
mixtureModel.gating.setThetaAllItems(theta);

weights = zeros(numOptions, dataManager.getNumDimensions(mixtureModel.inputVariables{1}));
bias    = (rand(numOptions,1)-0.5) *10;
for o = 1 : numOptions
    mixtureModel.options{o}.setWeightsAndBias(weights(o,:), bias(o,:));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


settings.setProperty('numIterationsEM', maxIterationsEM);
settings.setProperty('debugPlottingEM',false);
settings.setProperty('useKMeans',true);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Create Reference Data
dataManager.finalizeDataManager();
newData = dataManager.getDataObject([numEpisodes, numTimeSteps]);
fileSampler = Sampler.SamplerFromFile(dataManager, 'Helper/PendulumTrajs/data');
fileSampler.createSamples(newData);
 
%%
% load Helper/PendulumTrajs/data
% newData.setDataEntry('states', data.states(1:numEpisodes*data.steps(1).numElements,:));
% newData.setDataEntry('actions', data.actions(1:numEpisodes*data.steps(1).numElements));
Plotter.PlotterData.plotTrajectories(newData, 'states',1);
title('InputData');
% EMLearner.setGeneratingModel(trial.parameterPolicy, 'generatingModel');


for t = 1 : 20
    sampler.stepSampler.isActiveSampler.numTimeSteps = numTimeSteps;    
    EMLearner.numIterations = t;    
    save(['tmpData',num2str(t)])
    EMLearner.updateModel(newData);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% PLOTTING
    
    
    angleRange = pi;
    VResolution = 100;
    
    
    [x, y] = meshgrid( linspace(-angleRange +0.5*pi, angleRange+0.5*pi, VResolution), linspace(-30, 30, VResolution));
    x = x';
    y = y';
    contextVec      = [x(:), y(:)];
    plotData        = dataManager.getDataObject(size(contextVec,1));
    plotData.setDataEntry('states', contextVec);
    
    figure(51); clf;
    currModel   = mixtureModel;
    figTitle    = 'Estimated Policy';
    resps = currModel.gating.getItemProbabilities([],plotData.getDataEntry(mixtureModel.gating.inputVariables{1}));
    
    [~, optionIdx]      = max(resps,[],2);
    optionList          = unique(optionIdx);
    policyExpectation   = zeros(size(optionIdx,1),1);
    for i = 1 : length(optionList)
        option              = optionList(i);
        sampleSelection     = optionIdx == option;
        contextsForOption   = contextVec(sampleSelection,:);
        numSamples          = size(contextsForOption,1);
        respCenters(:,option)    = mean(contextsForOption)';
        policyExpectation(sampleSelection) =  currModel.options{option}.getExpectation(numSamples, contextsForOption);
    end
    
    % [~, maxRespsIdx] = max(resps,[],2);
    % respsMat                        = reshape(maxRespsIdx, VResolution, VResolution);
    % respsMat                        = respsMat';
    % imagesc([-angleRange, angleRange],[-30, 30],respsMat);
    % colorbar
    
    policyExpectationMat            = reshape(policyExpectation, VResolution, VResolution);
    policyExpectationMat            = policyExpectationMat';
    imagesc([-angleRange+0.5*pi, angleRange+0.5*pi],[-30, 30],policyExpectationMat);
    set(gca,'YDir','normal');
    
%     respCenters = squeeze(mean(bsxfun(@times, permute(resps,[1 3 2]), contextVec)));
    for i = 1 : length(optionList)
        o = optionList(i);
        text(respCenters(1,o),respCenters(2,o), ['O',num2str(o)]);
    end
    
    colorbar
    
    title(figTitle);
    pause(0.1)
    
    figure(37)
    title('TerminationPolicies');
    for o = 1 : mixtureModel.numOptions
        subplot(1,mixtureModel.numOptions,o);
        terminationProb = exp(mixtureModel.terminationMM.terminations{o}.getDataProbabilities(plotData.getDataEntry(mixtureModel.terminationMM.inputVariables{1}), ones(VResolution^2,1)));
        terminationProb            = reshape(terminationProb, VResolution, VResolution);
        terminationProb            = terminationProb';
        imagesc([-angleRange+0.5*pi, angleRange+0.5*pi],[-30, 30],terminationProb)
        colorbar
        set(gca,'YDir','normal');
    end
    
    
    
    %
    numTestEpisodes     = 20;
    numTestTimeSteps    = 50;
    copyInitStates      = false;
    plotData            = dataManager.getDataObject([numTestEpisodes, numTestTimeSteps]);
    sampler.stepSampler.isActiveSampler.numTimeSteps = numTestTimeSteps;
    initialStateSampler.setInitStateFromContext(copyInitStates);
    initStatesTraining = newData.getDataEntry('states',1,:);
%     plotData.setDataEntry('contexts', initStatesTraining(1:numTestEpisodes,:));
    sampler.numSamples  = numTestEpisodes;
    sampler.createSamples(plotData);
    figure(31)
    clf
    hold all
    for i = 1 : numTestEpisodes
        contextsNew         = plotData.getDataEntry('states',i);
        statesPeriodic = contextsNew(:,1);
        %     statesPeriodic(abs(diff(contextsNew(:,1)))>pi)=nan;
        plot(statesPeriodic);
    end
    % Plotter.PlotterData.plotTrajectories(plotData, 'jointPositions');
    title('OutputData');
    
    
    figure(51); hold on;
    states = plotData.getDataEntry('states');
    terminations = plotData.getDataEntry('terminations');    
    plot(states(terminations==1,1), states(terminations==1,2),'r*')
    
    
    figure(32)
    clf
    hold on
    totalTerminations = 0;
    for i = 1 : numTestEpisodes
        terminationsNew     = plotData.getDataEntry('terminations',i);
        contextsNew         = plotData.getDataEntry('states',i);
        terminationsNewIdx  = terminationsNew == 1;
        totalTerminations   = totalTerminations + sum(terminationsNewIdx);
        steps               = 1 : length(terminationsNew);
        plot(contextsNew(:,1));
        plot(steps(terminationsNewIdx), contextsNew(terminationsNewIdx,1),'r*');
    end    
    title('OutputData with Terminations');
    fprintf('terminationRatio = %.3g \n', totalTerminations / size(plotData.getDataEntry('terminations'),1));
    %
    
    for i = 1 : numTestTimeSteps
        statesEnd = plotData.getDataEntry('states',:,i);
        ratio(i)   = sum(abs(statesEnd(:,1)) < 0.5) / numel(statesEnd(:,1));
    end
    figure(33)
    plot(ratio)
    ratio(end)
    
    pause(1)
    
    
    
end

figure(80); plot(EMLearner.logLikelihood)

%% OLD STUFF
% EMLearner.updateModel(newData);
% figure; plot(EMLearner.logLikelihood)
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% PLOTTING
% 
% 
% angleRange = pi;
% VResolution = 100;
% 
% 
% [x, y] = meshgrid( linspace(-angleRange, angleRange, VResolution), linspace(-30, 30, VResolution));
% x = x';
% y = y';
% contextVec      = [x(:), y(:)];
% plotData        = dataManager.getDataObject(size(contextVec,1));
% plotData.setDataEntry('states', contextVec);
% 
% for i = 2 : 2
% figure(28+i); clf;
% if(i == 1) 
%     currModel   = trial.parameterPolicy;
%     figTitle    = 'Original Policy';
% else
%     currModel   = mixtureModel;
%     figTitle    = 'Estimated Policy';
% end
% resps = currModel.gating.getItemProbabilities([],plotData.getDataEntry(mixtureModel.gating.inputVariables{1}));
% 
% [~, optionIdx]      = max(resps,[],2);
% optionList          = unique(optionIdx);
% policyExpectation   = zeros(size(optionIdx,1),1);
% for i = 1 : length(optionList)
%     option              = optionList(i);
%     sampleSelection     = optionIdx == option;
%     contextsForOption   = contextVec(sampleSelection,:);
%     numSamples          = size(contextsForOption,1);
%     
%     policyExpectation(sampleSelection) =  currModel.options{option}.getExpectation(numSamples, contextsForOption);
% end
% 
% % [~, maxRespsIdx] = max(resps,[],2);
% % respsMat                        = reshape(maxRespsIdx, VResolution, VResolution);
% % respsMat                        = respsMat';
% % imagesc([-angleRange, angleRange],[-30, 30],respsMat);
% % colorbar
% 
% policyExpectationMat            = reshape(policyExpectation, VResolution, VResolution);
% policyExpectationMat            = policyExpectationMat';
% imagesc([-angleRange, angleRange],[-30, 30],policyExpectationMat);
% set(gca,'YDir','normal');
% colorbar
% title(figTitle);
% pause(0.1)
% end
% 
% %%
% numTestEpisodes     = 20;
% numTestTimeSteps    = 50;
% copyInitStates      = true;
% plotData            = dataManager.getDataObject([numTestEpisodes, numTestTimeSteps]);
% sampler.stepSampler.isActiveSampler.numTimeSteps = numTestTimeSteps;
% initialStateSampler.setInitStateFromContext(copyInitStates); 
% initStatesTraining = newData.getDataEntry('states',1,:);
% plotData.setDataEntry('contexts', initStatesTraining(1:numTestEpisodes,:));
% sampler.numSamples  = numTestEpisodes;
% sampler.createSamples(plotData);
% figure
% hold all
% for i = 1 : numTestEpisodes
%     contextsNew         = plotData.getDataEntry('states',i);
%     statesPeriodic = contextsNew(:,1); 
%     statesPeriodic(abs(diff(contextsNew(:,1)))>pi)=nan;
%     plot(statesPeriodic);    
% end
% % Plotter.PlotterData.plotTrajectories(plotData, 'jointPositions');
% title('OutputData');
% 
% Plotter.PlotterData.plotTrajectories(plotData, 'jointPositions');
% hold on
% for i = 1 : numTestEpisodes
%     terminationsNew     = plotData.getDataEntry('terminations',i);
%     contextsNew         = plotData.getDataEntry('states',i);
%     terminationsNewIdx  = terminationsNew == 1;
%     steps               = 1 : length(terminationsNew);
%     plot(steps(terminationsNewIdx), contextsNew(terminationsNewIdx,1),'r*');
% end
% 
% title('OutputData');