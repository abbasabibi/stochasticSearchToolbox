% 
load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalQuadLinkWindowPrediction/DoubleLinkSwingDown_noisePreprocessorConfigurator_windowPreprocessorConfigurator_groundtruthWindowPreprocessorConfigurator_observationPointsPreprocessorConfigurator_gkkfConfigurator/GkkfRegQuadLinkSwingDown_201503061632_01/experiment.mat')
regGkkfData = obj.getTrialData({'windowPredictionEvaluator'});

Plotter.PlotterEvaluations.plotMinMax(true);
Plotter.PlotterEvaluations.plotMedianQuantile(true);

nEpis = 5;
[regDataPlot] = Plotter.PlotterEvaluations.preparePlotData(regGkkfData, 'iterations', 'windowPredictionEvaluator', 'settings.windowPreprocessor_windowSize', @(x_) sprintf('window size = %d', x_), ['evalQuadLink'], false, [1 2], []);

%%

Plotter.PlotterEvaluations.plotData(regDataPlot);

%%
% load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalReferenceSetSize/SwingDown_stateAliasAdder_FeaturePicture_LinearTransform_stateFeatures_windowPreprocessorConfigurator_observationPointsPreprocessorConfigurator_gkkfConfigurator/GkkfPendulumSwingDownRegImages_201502110041_01/experiment.mat');
% data = obj.getTrialData({'filteredDataEvaluator'});
% 
% Plotter.PlotterEvaluations.plotMinMax(true);
% [dataPlot ] = Plotter.PlotterEvaluations.preparePlotData(data, 'iterations', 'filteredDataEvaluator', 'settings.reducedKRS_maxSizeReferenceSet', @(x_) sprintf('RefSet = %1.3f', x_), [], false, [1], []);
% % Plotter.PlotterEvaluations.plotData(dataPlot);