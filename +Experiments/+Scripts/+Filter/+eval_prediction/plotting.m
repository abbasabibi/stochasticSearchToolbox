% 
load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalPrediction/SwingDown_stateAliasAdder_noisePreprocessorConfigurator_windowPreprocessorConfigurator_observationPointsPreprocessorConfigurator_gkkfConfigurator/GkkfPendulumSwingDown_201502191507_01/experiment.mat')
stdGkkfData = obj.getTrialData({'filteredDataEvaluator'});

load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalPrediction/SwingDown_stateAliasAdder_noisePreprocessorConfigurator_windowPreprocessorConfigurator_observationPointsPreprocessorConfigurator_gkkfConfigurator/GkkfRegPendulumSwingDown_201502191505_01/experiment.mat')
regGkkfData = obj.getTrialData({'filteredDataEvaluator'});

load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalPrediction/SwingDown_stateAliasAdder_noisePreprocessorConfigurator_windowPreprocessorConfigurator_observationPointsPreprocessorConfigurator_ceokkfConfigurator/CeokkfPendulumSwingDown_201502201120_01/experiment.mat')
ceoGkkfData = obj.getTrialData({'filteredDataEvaluator'});

load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalPrediction/SwingDown_stateAliasAdder_noisePreprocessorConfigurator_windowPreprocessorConfigurator_observationPointsPreprocessorConfigurator_ceokkfConfigurator/CeokkfPendulumSwingDownSingleObservation_201502191530_01/experiment.mat')
ceoGkkfDataSO = obj.getTrialData({'filteredDataEvaluator'});

load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalPrediction/SwingDown_stateAliasAdder_noisePreprocessorConfigurator_windowPreprocessorConfigurator_windowAliasAdder_observationPointsPreprocessorConfigurator_spectralConfigurator/SpectralPendulumSwingDown_201502191528_01/experiment.mat')
spectralDataSO = obj.getTrialData({'filteredDataEvaluator'});

load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalPrediction/SwingDown_stateAliasAdder_noisePreprocessorConfigurator_windowPreprocessorConfigurator_windowAliasAdder_observationPointsPreprocessorConfigurator_spectralConfigurator/SpectralPendulumSwingDown_201502201120_01/experiment.mat')
spectralData = obj.getTrialData({'filteredDataEvaluator'});

Plotter.PlotterEvaluations.plotMinMax(true);
Plotter.PlotterEvaluations.plotMedianQuantile(true);


[stdDataPlot] = Plotter.PlotterEvaluations.preparePlotData(stdGkkfData, 'iterations', 'filteredDataEvaluator', 'settings.GKKF_learnTcov', @(x_) sprintf('learn T cov = %d', x_), ['evalPrediction_std'], false, [1], []);
[regDataPlot] = Plotter.PlotterEvaluations.preparePlotData(regGkkfData, 'iterations', 'filteredDataEvaluator', 'settings.GKKF_learnTcov', @(x_) sprintf('learn T cov = %d', x_), ['evalPrediction_reg'], false, [1], []);
[ceoDataPlot] = Plotter.PlotterEvaluations.preparePlotData(ceoGkkfData, 'iterations', 'filteredDataEvaluator', 'settings.kernelReferenceSet_maxSizeReferenceSet', @(x_) sprintf('maxSizeReferenceSet = %d', x_), ['evalPrediction_ceo'], false, [1:1], []);
[ceoDataPlotSO] = Plotter.PlotterEvaluations.preparePlotData(ceoGkkfDataSO, 'iterations', 'filteredDataEvaluator', 'settings.kernelReferenceSet_maxSizeReferenceSet', @(x_) sprintf('maxSizeReferenceSet = %d', x_), ['evalPrediction_ceoSO'], false, [1:1], []);
[spectralDataPlot] = Plotter.PlotterEvaluations.preparePlotData(spectralData, 'iterations', 'filteredDataEvaluator', 'numEigenvectors', @(x_) sprintf('numEigenvectors = %d', x_), ['evalPrediction_spectral'], false, [5], []);
[spectralDataPlotSO] = Plotter.PlotterEvaluations.preparePlotData(spectralDataSO, 'iterations', 'filteredDataEvaluator', 'numEigenvectors', @(x_) sprintf('numEigenvectors = %d', x_), ['evalPrediction_spectralSO'], false, [5], []);

mergedPlot = Plotter.PlotterEvaluations.mergePlots(stdDataPlot, 1, regDataPlot, 1, 'mergedPrediction', true);
mergedPlot = Plotter.PlotterEvaluations.mergePlots(mergedPlot, 1:2, ceoDataPlot, 1, 'mergedPrediction', true);
mergedPlot = Plotter.PlotterEvaluations.mergePlots(mergedPlot, 1:3, ceoDataPlotSO, 1, 'mergedPrediction', true);
mergedPlot = Plotter.PlotterEvaluations.mergePlots(mergedPlot, 1:4, spectralDataPlot, 1, 'mergedPrediction', true);
mergedPlot = Plotter.PlotterEvaluations.mergePlots(mergedPlot, 1:5, spectralDataPlotSO, 1, 'mergedPrediction', true);

mergedPlot.evaluationLabels = cell(0);
mergedPlot.evaluationLabels{1} = 'std';
mergedPlot.evaluationLabels{end+1} = 'sub-space';
mergedPlot.evaluationLabels{end+1} = 'ceo-kkf';
mergedPlot.evaluationLabels{end+1} = 'ceo-kkf SO';
mergedPlot.evaluationLabels{end+1} = 'spectral';
mergedPlot.evaluationLabels{end+1} = 'spectral SO';

mergedPlot.xAxis = repmat(cumsum([10 10 30 50 100]),length(mergedPlot.evaluationLabels),1);
mergedPlot.xLabel = 'num training sequences';
mergedPlot.yLabel = 'MSE';

% Plotter.PlotterEvaluations.plotData(stdDataPlot);
% Plotter.PlotterEvaluations.plotData(regDataPlot);
% Plotter.PlotterEvaluations.plotData(ceoDataPlot);
% Plotter.PlotterEvaluations.plotData(ceoDataPlotSO);
% Plotter.PlotterEvaluations.plotData(spectralDataPlot);
% Plotter.PlotterEvaluations.plotData(spectralDataPlotSO);

Plotter.PlotterEvaluations.plotData(mergedPlot);

%%
% load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalReferenceSetSize/SwingDown_stateAliasAdder_FeaturePicture_LinearTransform_stateFeatures_windowPreprocessorConfigurator_observationPointsPreprocessorConfigurator_gkkfConfigurator/GkkfPendulumSwingDownRegImages_201502110041_01/experiment.mat');
% data = obj.getTrialData({'filteredDataEvaluator'});
% 
% Plotter.PlotterEvaluations.plotMinMax(true);
% [dataPlot ] = Plotter.PlotterEvaluations.preparePlotData(data, 'iterations', 'filteredDataEvaluator', 'settings.reducedKRS_maxSizeReferenceSet', @(x_) sprintf('RefSet = %1.3f', x_), [], false, [1], []);
% % Plotter.PlotterEvaluations.plotData(dataPlot);