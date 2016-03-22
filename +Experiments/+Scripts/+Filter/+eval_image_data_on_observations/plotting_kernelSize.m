% 
load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalImageDataPcaObs/SwingDown_stateAliasAdder_FeaturePicture_noisePreproConfig_LinearTransform_stateFeatures_winPreproConfig_obsPointsPreproConfig_gkkfConfigurator/kernel_size_201504210942_01/experiment.mat');
regGkkfData = obj.getTrialData({'filteredImageDataEvaluator'});

Plotter.PlotterEvaluations.plotMinMax(true);
Plotter.PlotterEvaluations.plotMedianQuantile(true);


[regDataPlot] = Plotter.PlotterEvaluations.preparePlotData(regGkkfData, 'iterations', 'filteredImageDataEvaluator', 'settings.reducedKRS_maxSizeReferenceSet', @(x_) sprintf('size ref set = %d', x_), [], false, [1:3], []);

Plotter.PlotterEvaluations.plotData(regDataPlot);

%%
% load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalReferenceSetSize/SwingDown_stateAliasAdder_FeaturePicture_LinearTransform_stateFeatures_windowPreprocessorConfigurator_observationPointsPreprocessorConfigurator_gkkfConfigurator/GkkfPendulumSwingDownRegImages_201502110041_01/experiment.mat');
% data = obj.getTrialData({'filteredDataEvaluator'});
% 
% Plotter.PlotterEvaluations.plotMinMax(true);
% [dataPlot ] = Plotter.PlotterEvaluations.preparePlotData(data, 'iterations', 'filteredDataEvaluator', 'settings.reducedKRS_maxSizeReferenceSet', @(x_) sprintf('RefSet = %1.3f', x_), [], false, [1], []);
% % Plotter.PlotterEvaluations.plotData(dataPlot);