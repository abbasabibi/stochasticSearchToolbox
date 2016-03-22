% 
load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalWindowPrediction/SwingDown_stateAliasAdder_noisePreprocessorConfigurator_windowPreprocessorConfigurator_observationPointsPreprocessorConfigurator_gkkfConfigurator/GkkfPendulumSwingDown_201502201727_01/experiment.mat')
stdGkkfData = obj.getTrialData({'windowPredictionEvaluator'});

load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalWindowPrediction/SwingDown_stateAliasAdder_noisePreprocessorConfigurator_windowPreprocessorConfigurator_observationPointsPreprocessorConfigurator_gkkfConfigurator/GkkfRegPendulumSwingDown_201502201728_01/experiment.mat')
regGkkfData = obj.getTrialData({'windowPredictionEvaluator'});

load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalWindowPrediction/SwingDown_stateAliasAdder_noisePreprocessorConfigurator_windowPreprocessorConfigurator_observationPointsPreprocessorConfigurator_ceokkfConfigurator/CeokkfPendulumSwingDown_201502201728_01/experiment.mat')
ceoKkfData = obj.getTrialData({'windowPredictionEvaluator'});

load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalWindowPrediction/SwingDown_stateAliasAdder_noisePreprocessorConfigurator_windowPreprocessorConfigurator_windowAliasAdder_observationPointsPreprocessorConfigurator_spectralConfigurator/SpectralPendulumSwingDown_201502202159_01/experiment.mat')
spectralData = obj.getTrialData({'windowPredictionEvaluator'});

Plotter.PlotterEvaluations.plotMinMax(true);
Plotter.PlotterEvaluations.plotMedianQuantile(true);

iterIdx = 1:5;
valueIdx = 3;
[stdDataPlot] = Plotter.PlotterEvaluations.preparePlotData(stdGkkfData, 'iterations', 'windowPredictionEvaluator', 'settings.GKKF_learnTcov', @(x_) sprintf('learn T cov = %d', x_), ['evalWindowPred_std'], false, [2], [], iterIdx, valueIdx);
[regDataPlot] = Plotter.PlotterEvaluations.preparePlotData(regGkkfData, 'iterations', 'windowPredictionEvaluator', 'settings.GKKF_learnTcov', @(x_) sprintf('learn T cov = %d', x_), ['evalWindowPred_reg'], false, [2], [], iterIdx, valueIdx);
[ceoDataPlot] = Plotter.PlotterEvaluations.preparePlotData(ceoKkfData, 'iterations', 'windowPredictionEvaluator', 'settings.kernelReferenceSet_maxSizeReferenceSet', @(x_) sprintf('refset size = %d', x_), ['evalWindowPred_ceo'], false, [1], [], iterIdx, valueIdx);
[spectralDataPlot] = Plotter.PlotterEvaluations.preparePlotData(spectralData, 'iterations', 'windowPredictionEvaluator', 'numEigenvectors', @(x_) sprintf('num eigenvectors = %d', x_), ['evalWindowPred_spectral'], false, [5], [], iterIdx, valueIdx);

%%

mergedPlot = Plotter.PlotterEvaluations.mergePlots(stdDataPlot, 1, regDataPlot, 1, 'mergedWindowPrediction', true);
mergedPlot = Plotter.PlotterEvaluations.mergePlots(mergedPlot, 1:2, ceoDataPlot, 1, 'mergedWindowPrediction', true);
mergedPlot = Plotter.PlotterEvaluations.mergePlots(mergedPlot, 1:3, spectralDataPlot, 1, 'mergedWindowPrediction', true);

mergedPlot.meansYData = mergedPlot.meansYData(:,1:5);
mergedPlot.stdsYData = mergedPlot.stdsYData(:,1:5,:);

mergedPlot.evaluationLabels{1} = 'std';
mergedPlot.evaluationLabels{2} = 'sub-space';
mergedPlot.evaluationLabels{3} = 'ceo-kkf';
mergedPlot.evaluationLabels{4} = 'spectral';
mergedPlot.xAxis = repmat(cumsum([10 10 30 50 100]),length(mergedPlot.evaluationLabels),1);

% Plotter.PlotterEvaluations.plotData(stdDataPlot);
% Plotter.PlotterEvaluations.plotData(regDataPlot);
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