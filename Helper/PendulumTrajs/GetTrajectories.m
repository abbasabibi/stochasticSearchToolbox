numEpisodes     = 1000;
numTimeSteps    = 50;


%git checkout e9c01963


load('/scratch/git/policysearchtoolbox/+Experiments/data/test/test_201410231434_01/eval001/trial010/trial.mat');
newData = trial.dataManager.getDataObject();
trial.sampler.numSamples            = numEpisodes;
isActiveStepSampler                 = Sampler.IsActiveStepSampler.IsActiveNumSteps(trial.dataManager);
trial.sampler.stepSampler.setIsActiveSampler(isActiveStepSampler);
trial.sampler.stepSampler.isActiveSampler.numTimeSteps = numTimeSteps;
trial.sampler.createSamples(newData);
Plotter.PlotterData.plotTrajectories(newData, 'jointPositions');