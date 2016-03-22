% 
load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalOptimParamSet/SwingDown_stateAliasAdder_noisePreprocessorConfigurator_windowPreprocessorConfigurator_observationPointsPreprocessorConfigurator_gkkfConfigurator/GkkfRegPendulumSwingDown_201503241756_01/experiment.mat')
regGkkfData = obj.getTrialData({'filteredDataEvaluator'});

Plotter.PlotterEvaluations.plotMinMax(true);
Plotter.PlotterEvaluations.plotMedianQuantile(true);


% [stdDataPlot] = Plotter.PlotterEvaluations.preparePlotData(stdGkkfData, 'iterations', 'filteredDataEvaluator', 'learn T_cov', @(x_) sprintf('learn T_cov = %d', x_), ['evalBigReferenceSet_std'], false, [1 2], []);
% [regDataPlot] = Plotter.PlotterEvaluations.preparePlotData(regGkkfData, 'iterations', 'filteredDataEvaluator', 'settings.filterLearner_stateFeatureName', @(x_) sprintf('feature name = %s', x_), ['evalBigReferenceSetLlhOneStep_reg'], false, [], []);
[regDataPlot] = Plotter.PlotterEvaluations.preparePlotData(regGkkfData, 'iterations', 'filteredDataEvaluator', 'plotLabelName', @(x_) sprintf('%s', x_), [], false, [1:3], [],[],[]);
% [regDataPlot] = Plotter.PlotterEvaluations.preparePlotData(regGkkfData, 'iterations', 'windowPredictionEvaluator', 'settings.filterLearner_stateFeatureName', @(x_) sprintf('feature name = %s', x_), [], false, [], [],[1],[]);


% Plotter.PlotterEvaluations.plotData(stdDataPlot);
Plotter.PlotterEvaluations.plotData(regDataPlot);

%%
% load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalReferenceSetSize/SwingDown_stateAliasAdder_FeaturePicture_LinearTransform_stateFeatures_windowPreprocessorConfigurator_observationPointsPreprocessorConfigurator_gkkfConfigurator/GkkfPendulumSwingDownRegImages_201502110041_01/experiment.mat');
% data = obj.getTrialData({'filteredDataEvaluator'});
% 
% Plotter.PlotterEvaluations.plotMinMax(true);
% [dataPlot ] = Plotter.PlotterEvaluations.preparePlotData(data, 'iterations', 'filteredDataEvaluator', 'settings.reducedKRS_maxSizeReferenceSet', @(x_) sprintf('RefSet = %1.3f', x_), [], false, [1], []);
% % Plotter.PlotterEvaluations.plotData(dataPlot);