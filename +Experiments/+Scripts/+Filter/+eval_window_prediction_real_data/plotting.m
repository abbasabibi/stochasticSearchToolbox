% 
load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalWindowPredictionRealData/SwingDown_stateAliasAdder_noisePreprocessorConfigurator_windowPreprocessorConfigurator_observationPointsPreprocessorConfigurator_gkkfConfigurator/GkkfPendulumSwingDown_201502242154_01/experiment.mat')
stdGkkfData = obj.getTrialData({'windowPredictionEvaluator'});

load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalWindowPredictionRealData/SwingDown_stateAliasAdder_noisePreprocessorConfigurator_windowPreprocessorConfigurator_observationPointsPreprocessorConfigurator_gkkfConfigurator/GkkfPendulumSwingDownLearnTCov_201502242156_01/experiment.mat')
stdGkkfDataLearnTCov = obj.getTrialData({'windowPredictionEvaluator'});

load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalWindowPredictionRealData/SwingDown_stateAliasAdder_noisePreprocessorConfigurator_windowPreprocessorConfigurator_observationPointsPreprocessorConfigurator_gkkfConfigurator/GkkfRegPendulumSwingDown_201502260005_01/experiment.mat')
regGkkfData = obj.getTrialData({'windowPredictionEvaluator'});

load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalWindowPredictionRealData/SwingDown_stateAliasAdder_noisePreprocessorConfigurator_windowPreprocessorConfigurator_observationPointsPreprocessorConfigurator_gkkfConfigurator/GkkfRegPendulumSwingDownLearnTCov_201502260006_01/experiment.mat')
regGkkfDataLearnTCov = obj.getTrialData({'windowPredictionEvaluator'});

Plotter.PlotterEvaluations.plotMinMax(true);
Plotter.PlotterEvaluations.plotMedianQuantile(true);


[stdDataPlot] = Plotter.PlotterEvaluations.preparePlotData(stdGkkfData, 'iterations', 'windowPredictionEvaluator', 'settings.numSamplesEpisodes', @(x_) sprintf('num samples = %d', x_), ['evalWindowPredRealData_std'], false, [1:5], []);
[stdDataPlotLearnTCov] = Plotter.PlotterEvaluations.preparePlotData(stdGkkfDataLearnTCov, 'iterations', 'windowPredictionEvaluator', 'settings.numSamplesEpisodes', @(x_) sprintf('num samples = %d', x_), ['evalWindowPredRealData_std_learnTCov'], false, [1:5], []);
[regDataPlot] = Plotter.PlotterEvaluations.preparePlotData(regGkkfData, 'iterations', 'windowPredictionEvaluator', 'settings.numSamplesEpisodes', @(x_) sprintf('num samples = %d', x_), ['evalWindowPredRealData_reg'], false, [1:5], []);
[regDataPlotLearnTCov] = Plotter.PlotterEvaluations.preparePlotData(regGkkfDataLearnTCov, 'iterations', 'windowPredictionEvaluator', 'settings.numSamplesEpisodes', @(x_) sprintf('num samples = %d', x_), ['evalWindowPredRealData_reg_learnTCov'], false, [1:5], []);

mergedPlot = Plotter.PlotterEvaluations.mergePlots(stdDataPlot, 1, regDataPlot, 1, 'mergedWindowPredictionRealData', true);

mergedPlot.evaluationLabels{1} = 'std';
mergedPlot.evaluationLabels{2} = 'sub-space';

% Plotter.PlotterEvaluations.plotData(stdDataPlot);
% Plotter.PlotterEvaluations.plotData(stdDataPlotLearnTCov);
% Plotter.PlotterEvaluations.plotData(regDataPlot);
% Plotter.PlotterEvaluations.plotData(regDataPlotLearnTCov);

Plotter.PlotterEvaluations.plotData(mergedPlot);

%%
% load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalReferenceSetSize/SwingDown_stateAliasAdder_FeaturePicture_LinearTransform_stateFeatures_windowPreprocessorConfigurator_observationPointsPreprocessorConfigurator_gkkfConfigurator/GkkfPendulumSwingDownRegImages_201502110041_01/experiment.mat');
% data = obj.getTrialData({'filteredDataEvaluator'});
% 
% Plotter.PlotterEvaluations.plotMinMax(true);
% [dataPlot ] = Plotter.PlotterEvaluations.preparePlotData(data, 'iterations', 'filteredDataEvaluator', 'settings.reducedKRS_maxSizeReferenceSet', @(x_) sprintf('RefSet = %1.3f', x_), [], false, [1], []);
% % Plotter.PlotterEvaluations.plotData(dataPlot);