 load('/home/hamidreza/stochasticsearch/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPSContextInitialSigma/numSamples_201406032029_02/eval001/trial001/trial.mat') 

 test = trial.dataManager.getDataObject();
 train = trial.dataManager.getDataObject();
 
 trial.sampler.createSamples(test);
 trial.sampler.createSamples(train);
 
 trial.rewardFunctionLearner.updateModel(train);
 value = trial.learnedRewardFunction.getExpectation(trial.sampler.numSamples,[test.getDataEntry('contexts'),test.getDataEntry('parameters')]);
 
 err = var((value-test.getDataEntry('returns')))
 
 