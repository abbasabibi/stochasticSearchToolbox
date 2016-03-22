% 
load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalImageData/SwingDown_stateAliasAdder_noisePreprocessorConfigurator_FeaturePicture_LinearTransform_stateFeatures_windowPreprocessorConfigurator_observationPointsPreprocessorConfigurator_gkkfConfigurator/GkkfRegPendulumSwingDownImages_201502201501_01/experiment.mat')
regGkkfData = obj.getTrialData({'filteredDataEvaluator'});

load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalImageData/SwingDown_stateAliasAdder_noisePreprocessorConfigurator_FeaturePicture_LinearTransform_stateFeatures_windowPreprocessorConfigurator_windowAliasAdder_observationPointsPreprocessorConfigurator_spectralConfigurator/SpectralPendulumSwingDownImages_201502191744_01/experiment.mat')
spectralData = obj.getTrialData({'filteredDataEvaluator'});

Plotter.PlotterEvaluations.plotMinMax(true);
Plotter.PlotterEvaluations.plotMedianQuantile(true);


[regDataPlot] = Plotter.PlotterEvaluations.preparePlotData(regGkkfData, 'iterations', 'filteredDataEvaluator', 'settings.reducedKRS_maxSizeReferenceSet', @(x_) sprintf('size ref set = %d', x_), ['regImageOnObs'], false, [1:2], []);
[spectralDataPlot] = Plotter.PlotterEvaluations.preparePlotData(spectralData, 'iterations', 'filteredDataEvaluator', 'settings.windowSize', @(x_) sprintf('window size = %d', x_), ['spectralImageOnObs'], false, [1:3], []);


Plotter.PlotterEvaluations.plotData(regDataPlot);
Plotter.PlotterEvaluations.plotData(spectralDataPlot);

%%
% load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalReferenceSetSize/SwingDown_stateAliasAdder_FeaturePicture_LinearTransform_stateFeatures_windowPreprocessorConfigurator_observationPointsPreprocessorConfigurator_gkkfConfigurator/GkkfPendulumSwingDownRegImages_201502110041_01/experiment.mat');
% data = obj.getTrialData({'filteredDataEvaluator'});
% 
% Plotter.PlotterEvaluations.plotMinMax(true);
% [dataPlot ] = Plotter.PlotterEvaluations.preparePlotData(data, 'iterations', 'filteredDataEvaluator', 'settings.reducedKRS_maxSizeReferenceSet', @(x_) sprintf('RefSet = %1.3f', x_), [], false, [1], []);
% % Plotter.PlotterEvaluations.plotData(dataPlot);