
settings = Common.Settings;
settings.setProperty('thetaWindowPrepro_inputNames','theta');

for e = 3:3
    for t = 4:4
        load(['+Experiments/data/evalImageData/SwingDown_stateAliasAdder_noisePreprocessorConfigurator_FeaturePicture_LinearTransform_stateFeatures_windowPreprocessorConfigurator_windowAliasAdder_observationPointsPreprocessorConfigurator_spectralConfigurator/SpectralPendulumSwingDownImages_201502191744_01/eval00' num2str(e) '/trial00' num2str(t) '/trial.mat']);
    
        evaluator = Evaluator.FilteredDataEvaluator();
        evaluator.getEvaluation([],[],trial);
        
%         filter = Filter.WindowPredictionRegGeneralizedKernelKalmanFilter(trial.dataManager,trial.filterLearner.filter.winKernelReferenceSet, trial.filterLearner.filter.obsKernelReferenceSet,'winGKKF');
%         filter.redKernelReferenceSet = trial.filterLearner.filter.redKernelReferenceSet;
%         trial.filterLearner.transitionModelLearner.gkkf = filter;
%         trial.filterLearner.observationModelLearner.gkkf = filter;
%         trial.filterLearner.filter = filter;
%         trial.filterLearner.filter.windowSize = 4;
%         trial.filterLearner.filter.initFiltering(trial.filterLearner.observations, {'filteredMu', 'filteredVar'}, 1);
%         trial.filterLearner.updateOutputData(trial.filterOptimizer.wholeData);
%         trial.filterLearner.updateModel(trial.filterOptimizer.wholeData);
%         
%         windowEvaluator = Evaluator.WindowPredictionEvaluator();
%         windowEvaluator.groundtruthName = 'thetaWindows';
%         windowEvaluator.observationIndex = 1:4;
%         
%         trial.observationPointsPreprocessor.observationIndices = 1:30;
%         trial.evaluationGroundtruth = 'thetaWindows';
% %         trial.windowPreprocessor.inputNames = {'thetaNoisyPicturePcaFeatures' 'theta'};
%         
%         dataPrepro2 = DataPreprocessors.GenerateDataWindowsPreprocessor(trial.dataManager,'thetaWindowPrepro');
%         trial.scenario.addDataPreprocessor(dataPrepro2);
%         trial.dataManager.finalizeDataManager;
%         
%         evaluation = windowEvaluator.getEvaluation([],[],trial);
    end
end