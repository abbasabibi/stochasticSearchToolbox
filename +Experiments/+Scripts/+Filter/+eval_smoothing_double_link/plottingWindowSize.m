% 
load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalDoubleLinkSmoothing/DoubleLinkSwingDown_noisePreproConf_winPreproConf_obsPointsPreproConf_gkksConf/windowSize_201504131745_01/experiment.mat')
data = obj.getTrialData({'filteredDataEvaluator'});

Plotter.PlotterEvaluations.plotMinMax(true);
Plotter.PlotterEvaluations.plotMedianQuantile(true);

[dataPlot] = Plotter.PlotterEvaluations.preparePlotData(data, 'iterations', 'filteredDataEvaluator', 'settings.windowSize', @(x_) sprintf('window size = %d', x_), ['evalDoubleLink_compTcov'], false, [], []);

% Plotter.PlotterEvaluations.plotData(compTCovDataPlot);
% Plotter.PlotterEvaluations.plotData(learnTCovDataPlot);
% Plotter.PlotterEvaluations.plotData(ceoDataPlot);
% Plotter.PlotterEvaluations.plotData(spectralDataPlot);

Plotter.PlotterEvaluations.plotData(dataPlot);

%%
% load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalReferenceSetSize/SwingDown_stateAliasAdder_FeaturePicture_LinearTransform_stateFeatures_windowPreprocessorConfigurator_observationPointsPreprocessorConfigurator_gkkfConfigurator/GkkfPendulumSwingDownRegImages_201502110041_01/experiment.mat');
% data = obj.getTrialData({'filteredDataEvaluator'});
% 
% Plotter.PlotterEvaluations.plotMinMax(true);
% [dataPlot ] = Plotter.PlotterEvaluations.preparePlotData(data, 'iterations', 'filteredDataEvaluator', 'settings.reducedKRS_maxSizeReferenceSet', @(x_) sprintf('RefSet = %1.3f', x_), [], false, [1], []);
% % Plotter.PlotterEvaluations.plotData(dataPlot);