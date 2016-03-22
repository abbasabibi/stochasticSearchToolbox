% 
% load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalKernelBayesFiltering/Swing_stateAliasAdder_noisePreproConf_windowPreproConf_obsPointsPreproConf_kbfConf/stdKernelBayesRule_201504282215_01/experiment.mat')
% stdKbfData = obj.getTrialData({'filteredDataEvaluator'});

% load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalKernelBayesFiltering/Swing_stateAliasAdder_noisePreproConf_windowPreproConf_obsPointsPreproConf_kbfConf/subspaceKernelBayesRule_201504282216_01/experiment.mat')
% subKbfData = obj.getTrialData({'filteredDataEvaluator'});

load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalKernelBayesFiltering/Swing_stateAliasAdder_noisePreproConf_windowPreproConf_obsPointsPreproConf_kbfConf/fixedKernelSize_201504300003_01/experiment.mat')
subKbfData = obj.getTrialData({'filteredDataEvaluator'});

Plotter.PlotterEvaluations.plotMinMax(true);
Plotter.PlotterEvaluations.plotMedianQuantile(true);

% [stdKbfDataPlot] = Plotter.PlotterEvaluations.preparePlotData(stdKbfData, 'iterations', 'filteredDataEvaluator', 'settings.stateKRS_maxSizeReferenceSet', @(x_) sprintf('kernel size = %d', x_), ['evalKernelBayesFiltering_std'], false, [2,3], []);
% [subKbfDataPlot] = Plotter.PlotterEvaluations.preparePlotData(subKbfData, 'iterations', 'filteredDataEvaluator', 'settings.stateKRS_maxSizeReferenceSet', @(x_) sprintf('kernel size = %d', x_), ['evalKernelBayesFiltering_sub'], false, [2,3], []);

[subKbfDataPlot] = Plotter.PlotterEvaluations.preparePlotData(subKbfData, 'iterations', 'filteredDataEvaluator', 'settings.stateKRS_maxSizeReferenceSet', @(x_) sprintf('kernel size = %d', x_), ['evalKernelBayesFiltering_sub'], false, [], [], [1:3]);


% mergedPlot = Plotter.PlotterEvaluations.mergePlots(stdKbfDataPlot, [1,2], subKbfDataPlot, [1,2], 'mergedKernelBayesFiltering', true);
% 
% mergedPlot.evaluationLabels{1} = 'std';
% mergedPlot.evaluationLabels{2} = 'sub-space';

% Plotter.PlotterEvaluations.plotData(stdKbfDataPlot);
Plotter.PlotterEvaluations.plotData(subKbfDataPlot);

% Plotter.PlotterEvaluations.plotData(mergedPlot);

%%
% load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalReferenceSetSize/SwingDown_stateAliasAdder_FeaturePicture_LinearTransform_stateFeatures_windowPreprocessorConfigurator_observationPointsPreprocessorConfigurator_gkkfConfigurator/GkkfPendulumSwingDownRegImages_201502110041_01/experiment.mat');
% data = obj.getTrialData({'filteredDataEvaluator'});
% 
% Plotter.PlotterEvaluations.plotMinMax(true);
% [dataPlot ] = Plotter.PlotterEvaluations.preparePlotData(data, 'iterations', 'filteredDataEvaluator', 'settings.reducedKRS_maxSizeReferenceSet', @(x_) sprintf('RefSet = %1.3f', x_), [], false, [1], []);
% % Plotter.PlotterEvaluations.plotData(dataPlot);