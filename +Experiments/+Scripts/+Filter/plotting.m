% 
% load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalReferenceSetSize/SwingDown_stateAliasAdder_noisePreprocessorConfigurator_windowPreprocessorConfigurator_observationPointsPreprocessorConfigurator_LinearTransform_stateFeatures_gkkfConfigurator/GkkfPendulumSwingDown_201502111326_01/experiment.mat')
% load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalReferenceSetSize/SwingDown_stateAliasAdder_noisePreprocessorConfigurator_windowPreprocessorConfigurator_observationPointsPreprocessorConfigurator_LinearTransform_stateFeatures_gkkfConfigurator/GkkfPendulumSwingDownReg_201502111324_01/experiment.mat')
% load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalReferenceSetSize/SwingDown_stateAliasAdder_noisePreprocessorConfigurator_windowPreprocessorConfigurator_observationPointsPreprocessorConfigurator_ceokkfConfigurator/CeokkfPendulumSwingDownSingleObservation_201502111328_01/experiment.mat')
load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalReferenceSetSize/SwingDown_stateAliasAdder_noisePreprocessorConfigurator_windowPreprocessorConfigurator_windowAliasAdder_observationPointsPreprocessorConfigurator_spectralConfigurator/GkkfPendulumSwingDown_201502161542_01/experiment.mat')
% load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalReferenceSetSize/SwingDown_stateAliasAdder_noisePreprocessorConfigurator_windowPreprocessorConfigurator_observationPointsPreprocessorConfigurator_ceokkfConfigurator/CeokkfPendulumSwingDownSingleObservation_201502111328_01/experiment.mat')

data = obj.getTrialData({'filteredDataEvaluator'});

Plotter.PlotterEvaluations.plotMinMax(true);
[dataPlot ] = Plotter.PlotterEvaluations.preparePlotData(data, 'iterations', 'filteredDataEvaluator', 'settings.stateKRS_maxSizeReferenceSet', @(x_) sprintf('RefSet = %1.3f', x_), [], false, [1 2 3], []);
Plotter.PlotterEvaluations.plotData(dataPlot);

%%
% load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalReferenceSetSize/SwingDown_stateAliasAdder_FeaturePicture_LinearTransform_stateFeatures_windowPreprocessorConfigurator_observationPointsPreprocessorConfigurator_gkkfConfigurator/GkkfPendulumSwingDownRegImages_201502110041_01/experiment.mat');
% data = obj.getTrialData({'filteredDataEvaluator'});
% 
% Plotter.PlotterEvaluations.plotMinMax(true);
% [dataPlot ] = Plotter.PlotterEvaluations.preparePlotData(data, 'iterations', 'filteredDataEvaluator', 'settings.reducedKRS_maxSizeReferenceSet', @(x_) sprintf('RefSet = %1.3f', x_), [], false, [1], []);
% % Plotter.PlotterEvaluations.plotData(dataPlot);