load +Experiments/data/evalDoubleLinkWindowPrediction/DoubleLinkSwingDown_noisePreprocessorConfigurator_windowPreprocessorConfigurator_observationPointsPreprocessorConfigurator_gkkfConfigurator/GkkfRegDoubleLinkSwingDown_201502271426_01/eval005/trial002/trial.mat


data = trial.dataManager.getDataObject();
rng(1000);
trial.sampler.createSamples(data);

for i = 1:length(trial.scenario.dataPreprocessorFunctions)
    data = trial.scenario.dataPreprocessorFunctions{i}.preprocessData(data);
end

% trial.filterLearner.outputDataName = 'states';
% trial.filterLearner.updateOutputData(trial.filterOptimizer.trainData);



% trial.transitionFunction.visualize