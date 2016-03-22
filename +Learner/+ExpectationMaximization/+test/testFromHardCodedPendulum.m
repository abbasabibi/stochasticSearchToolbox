clear variables;
close all;
addpath(genpath('Helper/'));

% rng(3)
% warning('RNG is fixed');

numOptions      = 10;
numEpisodes     = 10;
numTimeSteps    = 50;
maxIterationsEM = 1;
toleranceEM     = -inf;

fileName = 'Helper/PendulumTrajs/dataHandCoded';


minRangeContexts = [-pi -10];
maxRangeContexts = [pi 10];
maxRangeActions     = 35;


settings = Common.Settings();

settings.setProperty('numSamplesEpisodes', numEpisodes);
settings.setProperty('numTimeSteps', numTimeSteps);
settings.setProperty('periodicRange', [-pi, pi]);

settings.setProperty('InitialStateDistributionMinRange', minRangeContexts);
settings.setProperty('InitialStateDistributionMaxRange', maxRangeContexts);
settings.setProperty('pendulumStateMinRange', minRangeContexts);
settings.setProperty('pendulumStateMaxRange', maxRangeContexts);
settings.setProperty('pendulumActionMaxRange', maxRangeActions);

settings.setProperty('InitialStateDistributionType', 'Uniform');
settings.setProperty('maxTorque', maxRangeActions);


settings.setProperty('numOptions',numOptions);
settings.setProperty('numIterationsEM',2e2);
settings.setProperty('logLikelihoodThresholdEM',toleranceEM);


settings.setProperty('numImitationEpisodes', numEpisodes);
settings.setProperty('numImitationSteps', numTimeSteps);

settings.setProperty('debugPlottingMM', true);

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

sampler.setTransitionFunction(environment);
sampler.setInitialStateSampler(initialStateSampler);


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
dataManager.setRange('actions', -500, 500);

sampler.initObject();
dataManager.finalizeDataManager();

squaredFeatures = FeatureGenerators.SquaredFeatures(dataManager, 'states', [], true);
linearFeatures  = FeatureGenerators.LinearFeatures(dataManager, 'states', [], true);



terminationPolicy   = Distributions.Discrete.LogisticDistribution(dataManager, 'terminations', squaredFeatures.outputName, 'terminationFunction');

terminationLearner  = Learner.ClassificationLearner.LogisticRegressionLearner(dataManager,terminationPolicy, true);
terminationPolicy.setTheta(rand(1,dataManager.getNumDimensions(linearFeatures.outputName)) -0.5);

terminationPolicyInitializer   = @Distributions.Discrete.LogisticDistribution;

gaussianDist  = Distributions.Gaussian.GaussianLinearInFeatures(dataManager, 'actions', 'states', 'ActionPolicy');

optionLearner = Learner.SupervisedLearner.LinearGaussianMLLearner(dataManager, gaussianDist);
optionInitializer = @Distributions.Gaussian.GaussianLinearInFeatures;


gatingDist    = Distributions.Discrete.SoftMaxDistribution(dataManager, 'options', linearFeatures.outputName, 'Gating');
gatingLearner = Learner.ClassificationLearner.MultiClassLogisticRegressionLearner(dataManager, gatingDist, true); %false or true???

gatingDist.setThetaAllItems(rand(size(gatingDist.thetaAllItems)) -0.5);


mixtureModel  = Distributions.MixtureModel.MixtureModelWithTermination.createPolicy(...
    dataManager, gatingDist, optionInitializer, 'actions', 'states', terminationPolicy.inputVariables{1},...
    terminationPolicyInitializer,'options','optionsOld');


sampler.setActionPolicy(mixtureModel);
sampler.setParallelSampling(true);




mixtureModelLearner = Learner.SupervisedLearner.TerminationMMLearner(dataManager, mixtureModel, optionLearner, gatingLearner, terminationLearner,  'responsibilities');
EMLearner     = Learner.ExpectationMaximization.EMHiREPSContinuous (dataManager, mixtureModel, mixtureModelLearner);

mixtureModel.initObject();
mixtureModelLearner.initObject();
gatingDist.initObject();
terminationPolicy.initObject();


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% Reset Model
% generatingMixtureModel = mixtureModel.clone();
% theta = (rand(numOptions,size(mixtureModel.terminationMM.terminations{1}.theta,2))-0.5) * 1;
% mixtureModel.terminationMM.terminations{1}.setTheta( theta(1,:) );
% mixtureModel.terminationMM.terminations{2}.setTheta( theta(2,:) );
% 
% theta = (rand(numOptions,size(mixtureModel.terminationMM.terminations{1}.theta,2))-0.5) * 1;
% mixtureModel.gating.setThetaAllItems(theta);
% 
% weights = zeros(numOptions, dataManager.getNumDimensions(mixtureModel.inputVariables{1}));
% bias    = (rand(numOptions,1)-0.5) *10;
% for o = 1 : numOptions
%     mixtureModel.options{o}.setWeightsAndBias(weights(o,:), bias(o,:));
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


settings.setProperty('numIterationsEM', maxIterationsEM);
settings.setProperty('debugPlottingEM',false);
settings.setProperty('useKMeans',true);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Create Reference Data
dataManager.finalizeDataManager();
newData = dataManager.getDataObject([numEpisodes, numTimeSteps]);
fileSampler = Sampler.SamplerFromFile(dataManager,fileName);
fileSampler.createSamples(newData);

% figure(11)
% Plotter.PlotterData.plotTrajectories(newData, 'states',1,11);
% title('InputData');
% figure(12)
% states = newData.getDataEntry('states');
% actions = newData.getDataEntry('actions');
% scatter(states(:,1), states(:,2), 100, actions)
% pause(1)


for t = 1 : 20
    sampler.stepSampler.isActiveSampler.numTimeSteps = numTimeSteps;    
    EMLearner.numIterations = t;    
    save(['tmpData',num2str(t)])
    EMLearner.updateModel(newData);
    
    
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
    imagesc([-angleRange, angleRange],[-30, 30],policyExpectationMat);
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
        imagesc([-angleRange, angleRange],[-30, 30],terminationProb)
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
