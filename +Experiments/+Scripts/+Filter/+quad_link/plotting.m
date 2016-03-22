% 
load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalQuadLink/QuadLinkSwingDown_noisePreproConf_winPreproConf_obsPointsPreproConf_gkkfConf/SubGKKF_201508050057_01/experiment.mat')
subGKKF_Data = obj.getTrialData({'windowPredictionEvaluator'});
load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalQuadLink/QuadLinkSwingDown_noisePreproConf_windowPreprConf_validAliasAdder_obsPointsPreproConf_ceokkfConf/CEOKKF_201508050100_01/experiment.mat')
CEOKKF_Data = obj.getTrialData({'windowPredictionEvaluator'});
load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalQuadLink/QuadLinkSwingDown_noisePreproConf_windowPreproConf_windowAliasAdder_validAliasAdder_obsPointsPreproConf_spectralConf/SPECTRAL_201508050058_01/experiment.mat')
SPECTRAL_Data = obj.getTrialData({'windowPredictionEvaluator'});


%%
Plotter.PlotterEvaluations.plotMinMax(true);
Plotter.PlotterEvaluations.plotMedianQuantile(true);

[subGKKF_DataPlot] = Plotter.PlotterEvaluations.preparePlotData(subGKKF_Data, 'iterations', 'windowPredictionEvaluator', 'settings.reducedKRS_maxSizeReferenceSet', @(x_) num2str(x_), 'subGKKF', false, [], [], [5]);
[CEOKKF_DataPlot] = Plotter.PlotterEvaluations.preparePlotData(CEOKKF_Data, 'iterations', 'windowPredictionEvaluator', 'settings.kernelReferenceSet_maxSizeReferenceSet', @(x_) num2str(x_), 'CEOKKF', false, [], [5], []);
[SPECTRAL_DataPlot] = Plotter.PlotterEvaluations.preparePlotData(SPECTRAL_Data, 'iterations', 'windowPredictionEvaluator', 'settings.state1KRS_maxSizeReferenceSet', @(x_) num2str(x_), 'SPECTRAL', false, [], [], [5]);

Plotter.PlotterEvaluations.plotData(subGKKF_DataPlot);
Plotter.PlotterEvaluations.plotData(CEOKKF_DataPlot);
Plotter.PlotterEvaluations.plotData(SPECTRAL_DataPlot);
