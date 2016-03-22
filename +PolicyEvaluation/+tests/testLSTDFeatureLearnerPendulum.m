[trial, settingsEval] = Experiments.getTrialForScript(); 
close all;

if (trial.isConfigure)
    settings = Common.Settings();

    settings.setProperty('GPVarianceNoiseFactorActions', 10^-1);
    settings.setProperty('maxNumOptiIterations', 300);
    settings.setProperty('CMANumRestarts', 1);
    settings.setProperty('maxSizeReferenceSet', 300);
    settings.setProperty('Noise_std', 1.0);
    settings.setProperty('InitialStateDistributionMinRange', [pi - pi, -2]);
    settings.setProperty('InitialStateDistributionMaxRange', [pi + pi, 2]);
    settings.setProperty('InitialStateDistributionType', 'Uniform');
    settings.setProperty('dt', 0.025);
    settings.setProperty('initSigmaActions', 1.0);
    settings.setProperty('discountFactor', 0.98);
    settings.setProperty('numTimeSteps', 300);
    settings.setProperty('kernelMedianBandwidthFactor', 0.6);
    settings.setProperty('kernelMedianBandwidthFactorStates', 0.1);
    settings.setProperty('numLocalDataPoints', 10);

    trial.configure(settingsEval);
    %%%% Sampling Process Definition Begin
    sampler = Sampler.EpisodeWithStepsSampler();

    dataManager = sampler.getEpisodeDataManager();
    stepSampler = sampler.getStepSampler();

    environment = Environments.DynamicalSystems.Pendulum(sampler, true);

    initialStateSampler = Sampler.InitialSampler.InitialStateSamplerStandard(sampler);
    actionCost = 0.001;
    stateCost = [10 0; 0 0];

    rewardFunction = RewardFunctions.QuadraticRewardFunctionSwingUp(dataManager);
    rewardFunction.setStateActionCosts(stateCost, actionCost);
    returnFunction = RewardFunctions.ReturnForEpisode.ReturnDecayedSummedReward(dataManager);

    actionPolicy = Distributions.Gaussian.GaussianActionPolicy(dataManager);

    sampler.setTransitionFunction(environment);
    sampler.setInitialStateSampler(initialStateSampler);
    sampler.setActionPolicy(actionPolicy);
    sampler.setRewardFunction(rewardFunction);
    sampler.setReturnFunction(returnFunction);

    environment.initObject();
    actionPolicy.initObject();

    %%%% Sampling Process Definition End

    %%%% Features for LSTD...

    numStates = dataManager.getNumDimensions('states');
    numActions = dataManager.getNumDimensions('actions');

    stateKernel = Kernels.Kernel.createKernelSQEPeriodic(dataManager, 'states');
    actionKernel = Kernels.ExponentialQuadraticKernel(dataManager, dataManager.getNumDimensions('actions'), 'Actions');

    stateActionKernel =  Kernels.ProductKernel(dataManager, numStates + numActions, {stateKernel, actionKernel}, ...
                    {1:numStates, (numStates + 1):(numStates + numActions)}, 'StateActions');

    stateActionFeatures = Kernels.KernelBasedFeatureGenerator(dataManager, stateActionKernel, {'states', 'actions'}, '~stateActionFeatures');
    stateActionKernelReferenceSetLearner = Kernels.Learner.RandomKernelReferenceSetLearner(dataManager, stateActionFeatures);

    nextActionFeatures = PolicyEvaluation.NextStateActionFeaturesCurrentPolicy(dataManager, stateActionFeatures, 'stateActionFeatures', 'actions', actionPolicy);

    dataDensityProcessor = DataPreprocessors.UniformDensityDataSelector(dataManager, stateKernel, 'states');

    %%%%%%%% Q-Function and LSTD
    dataManager.addDataEntryForDepth(2, 'qValues', 1);
    qFunction = Functions.FunctionLinearInFeatures(dataManager, 'qValues', {'stateActionFeatures'}, 'qFunction');
    qFunction.setFeatureGenerator(stateActionFeatures);
    lstdLearner = PolicyEvaluation.LeastSquaresTDLearningCorrectRegularizer(dataManager, qFunction, 'stateActionFeatures', 'nextStateActionFeatures', 'rewards');
    qFunctionFeatureLearner = PolicyEvaluation.FeatureLearner.LSTDFeatureLearnerMSPBE(dataManager, lstdLearner, 'stateActionFeatures', 'nextStateActionFeatures', qFunction, stateActionKernelReferenceSetLearner);
    qFunctionFeatureLearner.debugMessages = true;
    qFunctionFeatureLearner.initObject()
    qFunctionFeatureLearner.optimizer.printProperties
    qFunctionFeatureLearner.optimizer.maxNumOptiIterations = 0;
    
end

if (trial.isStart)
    sampler.finalizeSampler();
    data = dataManager.getDataObject(10);
    testData = dataManager.getDataObject(10);

    reloadData = false;

    if (reloadData)
        load('pendulumData.mat')

        data.copyValuesFromDataStructure(dataStruct);
        testData.copyValuesFromDataStructure(dataStructTest);
    else
        sampler.numSamples = 20;
        fprintf('Generating Data\n');
        tic
        sampler.createSamples(data);
        toc

        sampler.numSamples = 1000;
        fprintf('Generating Data\n');
        tic
        sampler.createSamples(testData);
        toc

        dataStruct = data.getDataStructure();
        dataStructTest = testData.getDataStructure();

        save('pendulumData.mat', 'dataStruct', 'dataStructTest');
    end

    %qFunctionFeatureLearner.updateModel(data);

    tic
    procData = dataDensityProcessor.preprocessData(data);
    toc
    fprintf('NumSamples after PreProcessing: %d\n', procData.getNumElementsForDepth(2));

    qFunctionFeatureLearner.updateModel(procData);

    Plotter.PlotterFunctions.plotOutputFunctionSlice2D(qFunction, 1, 2, [-pi -20], [pi 20], [0 0 0], 50);

    % get the predicted value of each first time step in the test data
    predictedReturns = qFunction.callDataFunctionOutput('getExpectation', testData, :, 1);

    mseValue = var(testData.getDataEntry('returns') - predictedReturns);
end
