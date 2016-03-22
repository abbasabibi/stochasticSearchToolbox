% 
load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalDoubleLinkWindowPrediction/DoubleLinkSwingDown_noisePreprocessorConfigurator_windowPreprocessorConfigurator_observationPointsPreprocessorConfigurator_gkkfConfigurator/GkkfRegDoubleLinkSwingDown_201502271426_01/experiment.mat')
compTCovGkkfData = obj.getTrialData({'windowPredictionEvaluator'});

Plotter.PlotterEvaluations.plotMinMax(true);
Plotter.PlotterEvaluations.plotMedianQuantile(true);

nEpis = 5;
[compTCovDataPlot] = Plotter.PlotterEvaluations.preparePlotData(compTCovGkkfData, 'iterations', 'windowPredictionEvaluator', 'settings.numSamplesEpisodes', @(x_) sprintf('num samples = %d', x_), ['evalDoubleLink_compTcov'], false, [nEpis], []);
[learnTCovDataPlot] = Plotter.PlotterEvaluations.preparePlotData(learnTCovGkkfData, 'iterations', 'windowPredictionEvaluator', 'settings.numSamplesEpisodes', @(x_) sprintf('num samples = %d', x_), ['evalDoubleLink_learnTcov'], false, [nEpis], []);
[ceoDataPlot] = Plotter.PlotterEvaluations.preparePlotData(ceoKkfData, 'iterations', 'windowPredictionEvaluator', 'settings.numSamplesEpisodes', @(x_) sprintf('num samples = %d', x_), ['evalDoubleLink_ceo'], false, [nEpis], [1:8]);
[spectralDataPlot] = Plotter.PlotterEvaluations.preparePlotData(spectralData, 'iterations', 'windowPredictionEvaluator', 'numEigenvectors', @(x_) sprintf('num eigenvectors = %d', x_), ['evalDoubleLink_spectral'], false, [5], [], nEpis);

mergedPlot = Plotter.PlotterEvaluations.mergePlots(compTCovDataPlot, 1, ceoDataPlot, 1, 'mergedDoubleLinkWindowPrediction', true);
mergedPlot = Plotter.PlotterEvaluations.mergePlots(mergedPlot, 1:2, spectralDataPlot, 1, 'mergedDoubleLinkWindowPrediction', true);
%%
mergedPlot.meansYData = mergedPlot.meansYData(:,1:2:8) + mergedPlot.meansYData(:,2:2:8);
mergedPlot.stdsYData = mergedPlot.stdsYData(:,1:2:8,:) + mergedPlot.stdsYData(:,2:2:8,:);

mergedPlot.evaluationLabels{1} = 'sub-space';
mergedPlot.evaluationLabels{2} = 'ceo-kkf';
mergedPlot.evaluationLabels{3} = 'spectral';

mergedPlot.xAxis = repmat([0 1 2 3],3,1);

% Plotter.PlotterEvaluations.plotData(compTCovDataPlot);
% Plotter.PlotterEvaluations.plotData(learnTCovDataPlot);
% Plotter.PlotterEvaluations.plotData(ceoDataPlot);
% Plotter.PlotterEvaluations.plotData(spectralDataPlot);

Plotter.PlotterEvaluations.plotData(mergedPlot);

%%
% load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalReferenceSetSize/SwingDown_stateAliasAdder_FeaturePicture_LinearTransform_stateFeatures_windowPreprocessorConfigurator_observationPointsPreprocessorConfigurator_gkkfConfigurator/GkkfPendulumSwingDownRegImages_201502110041_01/experiment.mat');
% data = obj.getTrialData({'filteredDataEvaluator'});
% 
% Plotter.PlotterEvaluations.plotMinMax(true);
% [dataPlot ] = Plotter.PlotterEvaluations.preparePlotData(data, 'iterations', 'filteredDataEvaluator', 'settings.reducedKRS_maxSizeReferenceSet', @(x_) sprintf('RefSet = %1.3f', x_), [], false, [1], []);
% % Plotter.PlotterEvaluations.plotData(dataPlot);