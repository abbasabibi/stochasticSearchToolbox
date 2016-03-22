clear variables;
%close all;

sampler = Sampler.EpisodeWithStepsSampler();

dataManager = sampler.getEpisodeDataManager();
stepsManager = dataManager.subDataManager;
%dataManager.addDataEntry('contexts', 1, -1, 1);

dataManager.addDataEntry('contexts', 2, [0.625*pi, 0], [0.875*pi, 0]);

contextSampler = Sampler.InitialSampler.InitialContextSamplerStandard(sampler);
sampler.setContextSampler(contextSampler);

stepSampler = sampler.getStepSampler();
isActiveSampler = Sampler.IsActiveStepSampler.IsActiveFixedGamma(dataManager);
isActiveSampler.resetProb= 0.02;
stepSampler.setIsActiveSampler(isActiveSampler);

environment = Environments.DynamicalSystems.Pendulum(sampler);

%contextSampler = Sampler.InitialSampler.InitialContextSamplerStandard( sampler);
initialStateSampler = Sampler.InitialSampler.InitialStateSamplerStandard(sampler);
initialStateSampler.InitialStateDistributionWidth = 0.1;
initialStateSampler.setInitStateFromContext(true);
sampler.setInitialStateSampler(initialStateSampler);
rewardFunction = Environments.DynamicalSystems.tests.TestRewardFunction(sampler);
returnFunction = RewardFunctions.ReturnForEpisode.ReturnSummedReward( sampler);

%%%
removeDuplicates = false;
sekernel = @FeatureGenerators.Kernels.sq_exp_kernel;
seprodkernel = @(s1,a1,s2,a2,bw) FeatureGenerators.Kernels.product_kernels(sekernel, sekernel, s1,a1,s2,a2,bw);

maxFeat = 800;

dataManager.finalizeDataManager();


skernelFeatures = FeatureGenerators.KernelSref(sekernel, removeDuplicates, maxFeat, dataManager, 'states');
nskernelFeatures = FeatureGenerators.KernelSref(sekernel, removeDuplicates, maxFeat, dataManager, 'nextStates');
sakernelFeatures = FeatureGenerators.KernelStateActionFeatures(seprodkernel, removeDuplicates, maxFeat, dataManager, {'states','actions'});
rkhslearner = Learner.ModelLearner.RKHSModelLearner(dataManager, maxFeat,skernelFeatures,nskernelFeatures,sakernelFeatures);

gaussianDistribution = Distributions.Gaussian.GaussianLinearInFeatures(dataManager, 'actions', 'states', 'ActionPolicy');
pl = Learner.SupervisedLearner.LinearGaussianMLLearner(dataManager, gaussianDistribution);

dataManager.finalizeDataManager();
skernelFeatures.initObject();
sakernelFeatures.initObject();
nskernelFeatures.initObject();
rkhslearner.initObject();
dataManager.finalizeDataManager();
reps = Learner.SteadyStateRL.REPS_infhorizon_iter(dataManager, pl, 'rewards', 'sampleWeights', 'statesKernelSref', 'statesactionsKernelStateActionstatesKernelStateExpNextFeat') ; 


dataManager.finalizeDataManager();

newData = dataManager.getDataObject(10);
newData2 = dataManager.getDataObject(0);




actionPolicy = Distributions.Gaussian.GaussianActionPolicy(dataManager);

actionPolicy.initObject();
actionPolicy.setSigma(10);

sampler.setTransitionFunction(environment);
%sampler.setContextSampler(contextSampler);
sampler.setInitialStateSampler(initialStateSampler);
sampler.setRewardFunction(rewardFunction);
sampler.setReturnFunction(returnFunction);
sampler.setActionPolicy(actionPolicy)

environment.initObject();





sampler.numSamples = 10;
sampler.setParallelSampling(true);

sampler.createSamples(newData);



newData2.mergeData(newData);

skernelFeatures.updateModel(newData)
sakernelFeatures.updateModel(newData)
nskernelFeatures.updateModel(newData)
%rkhslearner.updateModel(newData)
%with new hyperparameters

phi = newData.getDataEntry('statesKernelSref');
%psi = newData.getDataEntry('statesactionsKernelStateActionstatesKernelSrefExpNextFeat');
%reps.updateModel(newData);
sw = newData.getDataEntry('sampleWeights');


% validate model...





%train data


%nsamples = size(newData.getDataEntry('states',1:2:sampler.numSamples,:),1);
%fprintf('train %f',nsamples)
%trainData = dataManager.getDataObject(nsamples);
%dataManager.copyDataStructureIndex(trainData, newData, 1:nsamples, 1:2:sampler.numSamples)

trainData = newData.cloneDataSubSet(1:2:sampler.numSamples)
%trainData.setDataEntry('states',newData.getDataEntry('states',1:2:sampler.numSamples,:));
%trainData.setDataEntry('actions', newData.getDataEntry('actions',1:2:sampler.numSamples,:));
%trainData.setDataEntry('nextStates', newData.getDataEntry('nextStates',1:2:sampler.numSamples,:));
skernelFeatures.updateModel(trainData)
sakernelFeatures.updateModel(trainData)
nskernelFeatures.updateModel(trainData)


%test data
%nsamples = size(newData.getDataEntry('states',2:2:sampler.numSamples,:),1);
%fprintf('test %f',nsamples)
%testData = dataManager.getDataObject(nsamples);
testData = newData.cloneDataSubSet(2:2:sampler.numSamples);
%dataManager.copyDataStructureIndex(trainData, newData, 1:nsamples, 2:2:sampler.numSamples)
%testData.setDataEntry('states',newData.getDataEntry('states',2:2:sampler.numSamples,:));
%testData.setDataEntry('actions', newData.getDataEntry('actions',2:2:sampler.numSamples,:));
%testData.setDataEntry('nextStates', newData.getDataEntry('nextStates',2:2:sampler.numSamples,:));

rkhslearner2 = Learner.ModelLearner.RKHSModelLearner(dataManager, maxFeat,skernelFeatures,nskernelFeatures,sakernelFeatures);

rkhslearner2.updateModel(trainData)



psiExpTrain = trainData.getDataEntry('statesactionsKernelStateActionstatesKernelSrefExpNextFeat');
psiTrueTrain = trainData.getDataEntry('nextStatesKernelSref');

%skernelFeatures.updateModel(testData)
%sakernelFeatures.updateModel(testData)
%nskernelFeatures.updateModel(testData)

psiExp = testData.getDataEntry('statesactionsKernelStateActionstatesKernelSrefExpNextFeat');
psiTrue = testData.getDataEntry('nextStatesKernelSref');

states = trainData.getDataEntry('states');
n =size(states,1);
mx = max(max(psiTrue));

figure(1)
subplot(2,2,1); image(psiExpTrain(:,1:n)/mx*60); 
title('psi expected train')
subplot(2,2,2); image(psiTrueTrain(:,1:n)/mx*60); 
title('psi true train')
subplot(2,2,3); image(psiExp(:,1:n)/mx*60); 
title('psi expected test')
subplot(2,2,4); image(psiTrue(:,1:n)/mx*60);
title('psi true test')

figure(2)
phi = testData.getDataEntry('statesKernelSref');
subplot(3,1,1); imagesc(psiExpTrain(:,1:n) - psiTrueTrain(:,1:n) )
colorbar
title('train set error')
subplot(3,1,2); imagesc(psiExp(:,1:n) - psiTrue(:,1:n) )
colorbar
title('test set error')
subplot(3,1,3); imagesc(phi(:,1:n) - psiTrue(:,1:n) )
colorbar
title('baseline: dif phi and psi')
