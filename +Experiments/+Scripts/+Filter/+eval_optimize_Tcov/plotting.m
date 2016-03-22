% 
% load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalTcov/SwingDown_stateAliasAdder_noisePreprocessorConfigurator_windowPreprocessorConfigurator_observationPointsPreprocessorConfigurator_gkkfConfigurator/GkkfPendulumSwingDown_201502182320_01/experiment.mat')
load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalTcov/SwingDown_stateAliasAdder_noisePreprocessorConfigurator_windowPreprocessorConfigurator_observationPointsPreprocessorConfigurator_gkkfConfigurator/GkkfRegPendulumSwingDown_201502182321_01/experiment.mat')
% load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalReferenceSetSizeSmall/SwingDown_stateAliasAdder_noisePreprocessorConfigurator_windowPreprocessorConfigurator_observationPointsPreprocessorConfigurator_ceokkfConfigurator/CeokkfPendulumSwingDownSingleObservation_201502171707_01/experiment.mat')
% load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalReferenceSetSizeSmall/SwingDown_stateAliasAdder_noisePreprocessorConfigurator_windowPreprocessorConfigurator_windowAliasAdder_observationPointsPreprocessorConfigurator_spectralConfigurator/SpectralPendulumSwingDown_201502171710_01/experiment.mat')
% load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalReferenceSetSizeSmall/SwingDown_stateAliasAdder_noisePreprocessorConfigurator_windowPreprocessorConfigurator_observationPointsPreprocessorConfigurator_LinearTransform_stateFeatures_ceokkfConfigurator/CeokkfPendulumSwingDown_201502171706_01/experiment.mat')

data = obj.getTrialData({'filteredDataEvaluator'});

Plotter.PlotterEvaluations.plotMinMax(true);
Plotter.PlotterEvaluations.plotMedianQuantile(true);
[dataPlot ] = Plotter.PlotterEvaluations.preparePlotData(data, 'iterations', 'filteredDataEvaluator', 'settings.GKKF_learnTcov', @(x_) sprintf('learn T_cov = %d', x_), [], false, [1 2], []);
Plotter.PlotterEvaluations.plotData(dataPlot);

%%
% load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalReferenceSetSize/SwingDown_stateAliasAdder_FeaturePicture_LinearTransform_stateFeatures_windowPreprocessorConfigurator_observationPointsPreprocessorConfigurator_gkkfConfigurator/GkkfPendulumSwingDownRegImages_201502110041_01/experiment.mat');
% data = obj.getTrialData({'filteredDataEvaluator'});
% 
% Plotter.PlotterEvaluations.plotMinMax(true);
% [dataPlot ] = Plotter.PlotterEvaluations.preparePlotData(data, 'iterations', 'filteredDataEvaluator', 'settings.reducedKRS_maxSizeReferenceSet', @(x_) sprintf('RefSet = %1.3f', x_), [], false, [1], []);
% % Plotter.PlotterEvaluations.plotData(dataPlot);