% 
load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalFiltering/SwingDown_stateAliasAdder_noisePreprocessorConfigurator_windowPreprocessorConfigurator_observationPointsPreprocessorConfigurator_gkkfConfigurator/GkkfPendulumSwingDown_201502182322_01/experiment.mat')
stdGkkfData = obj.getTrialData({'filteredDataEvaluator'});

load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalFiltering/SwingDown_stateAliasAdder_noisePreprocessorConfigurator_windowPreprocessorConfigurator_observationPointsPreprocessorConfigurator_gkkfConfigurator/GkkfRegPendulumSwingDown_201502182322_01/experiment.mat')
regGkkfData = obj.getTrialData({'filteredDataEvaluator'});

Plotter.PlotterEvaluations.plotMinMax(true);
Plotter.PlotterEvaluations.plotMedianQuantile(true);


[stdDataPlot] = Plotter.PlotterEvaluations.preparePlotData(stdGkkfData, 'iterations', 'filteredDataEvaluator', 'settings.stateKRS_inputDataEntry', @(x_) sprintf('features = %s', x_), ['evalFiltering_std'], false, [1:2], []);
[regDataPlot] = Plotter.PlotterEvaluations.preparePlotData(regGkkfData, 'iterations', 'filteredDataEvaluator', 'settings.stateKRS_inputDataEntry', @(x_) sprintf('features = %s', x_), ['evalFiltering_reg'], false, [1:2], []);


Plotter.PlotterEvaluations.plotData(stdDataPlot);
Plotter.PlotterEvaluations.plotData(regDataPlot);

%%
% load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalReferenceSetSize/SwingDown_stateAliasAdder_FeaturePicture_LinearTransform_stateFeatures_windowPreprocessorConfigurator_observationPointsPreprocessorConfigurator_gkkfConfigurator/GkkfPendulumSwingDownRegImages_201502110041_01/experiment.mat');
% data = obj.getTrialData({'filteredDataEvaluator'});
% 
% Plotter.PlotterEvaluations.plotMinMax(true);
% [dataPlot ] = Plotter.PlotterEvaluations.preparePlotData(data, 'iterations', 'filteredDataEvaluator', 'settings.reducedKRS_maxSizeReferenceSet', @(x_) sprintf('RefSet = %1.3f', x_), [], false, [1], []);
% % Plotter.PlotterEvaluations.plotData(dataPlot);