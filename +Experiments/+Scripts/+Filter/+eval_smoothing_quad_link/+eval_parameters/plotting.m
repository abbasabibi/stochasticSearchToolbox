% 
% load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalQuadLinkSmoothing/QuadLinkSwingDown_noisePreproConf_winPreproConf_obsPointsPreproConf_gkksConf/evalParameters_Kappa_201507251709_01/experiment.mat')
% kappaData = obj.getTrialData({'filteredDataEvaluator'});
load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalQuadLinkSmoothing/QuadLinkSwingDown_noisePreproConf_winPreproConf_obsPointsPreproConf_gkksConf/evalParameters_lambdaI_201507251452_01/experiment.mat')
lambdaIData = obj.getTrialData({'filteredDataEvaluator'});
% load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalQuadLinkSmoothing/QuadLinkSwingDown_noisePreproConf_winPreproConf_obsPointsPreproConf_gkksConf/evalParameters_ObsBandwidthFactor_201507251812_01/experiment.mat')
% obsBandwidthData = obj.getTrialData({'filteredDataEvaluator'});
load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalQuadLinkSmoothing/QuadLinkSwingDown_noisePreproConf_winPreproConf_obsPointsPreproConf_gkksConf/evalParameters_StateBandwidthFactor_201507251850_01/experiment.mat')
stateBandwidthData = obj.getTrialData({'filteredDataEvaluator'});
% load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalQuadLinkSmoothing/QuadLinkSwingDown_noisePreproConf_winPreproConf_obsPointsPreproConf_gkksConf/evalParameters_RedKernelSize_201507251624_01/experiment.mat')
% redKernelSizeData = obj.getTrialData({'filteredDataEvaluator'});
% load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalQuadLinkSmoothing/QuadLinkSwingDown_noisePreproConf_winPreproConf_obsPointsPreproConf_gkksConf/evalParameters_WinSize_201507251512_01/experiment.mat')
% winSizeData = obj.getTrialData({'filteredDataEvaluator'});



Plotter.PlotterEvaluations.plotMinMax(true);
Plotter.PlotterEvaluations.plotMedianQuantile(true);

% [kappaDataPlot] = Plotter.PlotterEvaluations.preparePlotData(kappaData, 'evaluations', 'filteredDataEvaluator', 'settings.GKKS_kappa', @(x_) log(x_), [], false, [1:7], [], []);
[lambdaIDataPlot] = Plotter.PlotterEvaluations.preparePlotData(lambdaIData, 'evaluations', 'filteredDataEvaluator', 'GKKS_lambdaI', @(x_) log10(x_), [], false, [], [], []);
% [obsBandwidthDataPlot] = Plotter.PlotterEvaluations.preparePlotData(obsBandwidthData, 'evaluations', 'filteredDataEvaluator', 'settings.obsKRS_kernelMedianBandwidthFactor', @(x_) x_, [], false, [], [], []);
[stateBandwidthDataPlot] = Plotter.PlotterEvaluations.preparePlotData(stateBandwidthData, 'evaluations', 'filteredDataEvaluator', 'settings.stateKRS_kernelMedianBandwidthFactor', @(x_) x_, [], false, [], [], []);
% [redKernelSizeDataPlot] = Plotter.PlotterEvaluations.preparePlotData(redKernelSizeData, 'evaluations', 'filteredDataEvaluator', 'settings.reducedKRS_maxSizeReferenceSet', @(x_) x_, [], false, [], [], []);
% [winSizeDataPlot] = Plotter.PlotterEvaluations.preparePlotData(winSizeData, 'evaluations', 'filteredDataEvaluator', 'settings.windowSize', @(x_) x_, [], false, [1:9], [], []);

% Plotter.PlotterEvaluations.plotData(kappaDataPlot);
% Plotter.PlotterEvaluations.plotData(lambdaIDataPlot);
% Plotter.PlotterEvaluations.plotData(obsBandwidthDataPlot);
Plotter.PlotterEvaluations.plotData(stateBandwidthDataPlot);
% Plotter.PlotterEvaluations.plotData(redKernelSizeDataPlot);
% Plotter.PlotterEvaluations.plotData(winSizeDataPlot);

%
% load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalReferenceSetSize/SwingDown_stateAliasAdder_FeaturePicture_LinearTransform_stateFeatures_windowPreprocessorConfigurator_observationPointsPreprocessorConfigurator_gkkfConfigurator/GkkfPendulumSwingDownRegImages_201502110041_01/experiment.mat');
% data = obj.getTrialData({'filteredDataEvaluator'});
% 
% Plotter.PlotterEvaluations.plotMinMax(true);
% [dataPlot ] = Plotter.PlotterEvaluations.preparePlotData(data, 'iterations', 'filteredDataEvaluator', 'settings.reducedKRS_maxSizeReferenceSet', @(x_) sprintf('RefSet = %1.3f', x_), [], false, [1], []);
% % Plotter.PlotterEvaluations.plotData(dataPlot);