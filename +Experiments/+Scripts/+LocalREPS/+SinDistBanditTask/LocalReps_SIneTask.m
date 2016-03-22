[trial, settingsEval] = Experiments.getTrialForScript(); 
close all;

if (trial.isConfigure)
    

    % Experiments settings
    settings = Common.Settings();

    settings.setProperty('numIterations',2000);
    settings.setProperty('numSamplesEpisodes',200);
    settings.setProperty('numInitialSamplesEpisodes', 2000);
    settings.setProperty('maxSamples', 2000);
    settings.setProperty('maxCorrParameters', 1.0);
    settings.setProperty('initSigmaParameters', 0.5);
    settings.setProperty('epsilonAction', 1);
    settings.setProperty('bandwidthFactor', 1);
    settings.setProperty('useFeaturesForPolicy',false);
    settings.setProperty('numDuplication', 2);
    settings.setProperty('InitialContextDistributionType', 'Uniform');

    trial.configure(settingsEval);

        

    % create steps sampler
    sampler = Sampler.EpisodeSampler();
    dataManager = sampler.getDataManager();
        
    %define environment
    Experiments.Tasks.SinDistQuadraticBanditTask()
    returnSampler = Environments.BanditEnvironments.SinDistReward(sampler);

    %parameterPolicy = Distributions.Gaussian.GaussianParameterPolicy(dataManager);
    contextFeatures = FeatureGenerators.SquaredFeatures(dataManager, 'contexts');    
    %parameterPolicyLearner = Learner.SupervisedLearner.LinearGaussianMLLearner(dataManager, parameterPolicy);
    
    kernel = FeatureGenerators.ExponentialQuadraticKernel(dataManager, {'contexts'}, ':', 1);
    
    policyLearner = Learner.EpisodicRL.LocalREPS(dataManager,kernel,'returns', contextFeatures.getFeatureName(),'parameters');
    policyLearner.initObject();
    
    sampler.setParameterPolicy(policyLearner);

    sampler.setReturnFunction(returnSampler);
    
    contextSampler = Sampler.InitialSampler.InitialDuplicatorContextSampler(sampler);    
    sampler.setContextSampler(contextSampler);
        
    deletionStrategy = LearningScenario.MaxSamplesDeletionStrategy();

    dataManager.finalizeDataManager();
end

if (trial.isStart)
    
    data = dataManager.getDataObject(0);

 %   parameterPolicy.initObject();
    
    for i = 1:settings.numIterations
        
        
        newData = dataManager.getDataObject(0);

        sampler.setSamplerIteration(i);

        sampler.createSamples(newData);
        
        % keep old samples strategy comes here...
        data.mergeData(newData);
        deletionStrategy.deleteSamples(data);
        
        policyLearner.updateModel(data);

        % data preprocessors come here
        % ...
%        importanceWeighting.preprocessData(data);
        
        % learning comes here...
        
        % log the results...
        trial.store('avgReturns', mean(newData.getDataEntry('returns')), Experiments.StoringType.ACCUMULATE)
        %trial.store('entropy', policyLearner.entropyAfter, Experiments.StoringType.ACCUMULATE);
%        trial.store('divMean', policyLearner.divMean, Experiments.StoringType.ACCUMULATE);
       % trial.store('divCov', policyLearner.divCov, Experiments.StoringType.ACCUMULATE);
        %trial.store('divKL', policyLearner.divKL, Experiments.StoringType.ACCUMULATE);

        
        
       % trial.saveWorkspace();
       % trial.storeTrial();
        
       % fprintf('Iteration %d, Average Reward: %f, NumSamples: %f\n', i, mean(newData.getDataEntry('returns')), data.getNumElements());
       % policyLearner.printMessage(data)
         fprintf('Iteration %d: %f \n',i, trial.avgReturns(end, 1));

       % fprintf('Iteration %d: %f, divKL: %f \n',i, trial.avgReturns(end, 1), trial.divKL(end));
     %  fprintf('Iteration %d: %f, divCov: %f, divMin: %f \n',i, trial.avgReturns(end, 1), trial.divCov(end), trial.divMean(end));
     %  policyLearner.printMessage(data)

       %fprintf('Iteration %d: %f \n',i, trial.avgReturns(end, 1));

    end
end