% 
load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalPendulum/SwingDown_stateAliasAdder_noisePreproConf_winPreproConf_obsPointsPreproConf_gkkfConf_mcConf/GKKF_201508041403_01/experiment.mat')
GKKF_Data = obj.getTrialData({'filteredDataEvaluator' 'kldFilteredDataEvaluator' 'filterTimeEvaluator'});
load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalPendulum/SwingDown_stateAliasAdder_noisePreproConf_winPreproConf_obsPointsPreproConf_gkkfConf_mcConf/subGKKF_201508041405_01/experiment.mat')
subGKKF_Data = obj.getTrialData({'filteredDataEvaluator' 'kldFilteredDataEvaluator' 'filterTimeEvaluator'});
load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalPendulum/SwingDown_stateAliasAdder_noisePreproConf_windowPreprConf_obsPointsPreproConf_ceokkfConf_mcConf/CEOKKF_201508041407_01/experiment.mat')
CEOKKF_Data = obj.getTrialData({'filteredDataEvaluator' 'kldFilteredDataEvaluator' 'filterTimeEvaluator'});
load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalPendulum/SwingDown_stateAliasAdder_noisePreproConf_windowPreproConf_obsPointsPreproConf_kbfConf_mcConf/KBR_201508041409_01/experiment.mat')
KBF_Data = obj.getTrialData({'filteredDataEvaluator' 'kldFilteredDataEvaluator' 'filterTimeEvaluator'});
load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalPendulum/SwingDown_stateAliasAdder_noisePreproConf_windowPreproConf_windowAliasAdder_obsPointsPreproConf_spectralConf/SPECTRAL_201508041401_01/experiment.mat')
SPECTRAL_Data = obj.getTrialData({'filteredDataEvaluator' 'filterTimeEvaluator'});


%%
Plotter.PlotterEvaluations.plotMinMax(true);
Plotter.PlotterEvaluations.plotMedianQuantile(true);

[GKKF_DataPlot] = Plotter.PlotterEvaluations.preparePlotData(GKKF_Data, 'iterations', 'filteredDataEvaluator', 'settings.stateKRS_maxSizeReferenceSet', @(x_) num2str(x_), 'GKKF', false, [2:4], [], []);
[subGKKF_DataPlot] = Plotter.PlotterEvaluations.preparePlotData(subGKKF_Data, 'iterations', 'filteredDataEvaluator', 'settings.reducedKRS_maxSizeReferenceSet', @(x_) num2str(x_), 'subGKKF', false, [2:4], [], []);
[CEOKKF_DataPlot] = Plotter.PlotterEvaluations.preparePlotData(CEOKKF_Data, 'iterations', 'filteredDataEvaluator', 'settings.kernelReferenceSet_maxSizeReferenceSet', @(x_) num2str(x_), 'CEOKKF', false, [2:4], [], []);
[KBF_DataPlot] = Plotter.PlotterEvaluations.preparePlotData(KBF_Data, 'iterations', 'filteredDataEvaluator', 'settings.stateKRS_maxSizeReferenceSet', @(x_) num2str(x_), 'KBF', false, [2:4], [], []);
[SPECTRAL_DataPlot] = Plotter.PlotterEvaluations.preparePlotData(SPECTRAL_Data, 'iterations', 'filteredDataEvaluator', 'settings.state1KRS_maxSizeReferenceSet', @(x_) num2str(x_), 'SPECTRAL', false, [2:4], [], []);

Plotter.PlotterEvaluations.plotData(GKKF_DataPlot);
Plotter.PlotterEvaluations.plotData(subGKKF_DataPlot);
Plotter.PlotterEvaluations.plotData(CEOKKF_DataPlot);
Plotter.PlotterEvaluations.plotData(KBF_DataPlot);
Plotter.PlotterEvaluations.plotData(SPECTRAL_DataPlot);

%%
Plotter.PlotterEvaluations.plotMinMax(true);
Plotter.PlotterEvaluations.plotMedianQuantile(true);

[GKKF_DataPlot_KLD] = Plotter.PlotterEvaluations.preparePlotData(GKKF_Data, 'iterations', 'kldFilteredDataEvaluator', 'settings.stateKRS_maxSizeReferenceSet', @(x_) num2str(x_), 'GKKF', false, [2:4], [], []);
[subGKKF_DataPlot_KLD] = Plotter.PlotterEvaluations.preparePlotData(subGKKF_Data, 'iterations', 'kldFilteredDataEvaluator', 'settings.reducedKRS_maxSizeReferenceSet', @(x_) num2str(x_), 'subGKKF', false, [2:4], [], []);
[CEOKKF_DataPlot_KLD] = Plotter.PlotterEvaluations.preparePlotData(CEOKKF_Data, 'iterations', 'kldFilteredDataEvaluator', 'settings.kernelReferenceSet_maxSizeReferenceSet', @(x_) num2str(x_), 'CEOKKF', false, [2:4], [], []);
[KBF_DataPlot_KLD] = Plotter.PlotterEvaluations.preparePlotData(KBF_Data, 'iterations', 'kldFilteredDataEvaluator', 'settings.stateKRS_maxSizeReferenceSet', @(x_) num2str(x_), 'KBF', false, [2:4], [], []);

Plotter.PlotterEvaluations.plotData(GKKF_DataPlot_KLD);
Plotter.PlotterEvaluations.plotData(subGKKF_DataPlot_KLD);
Plotter.PlotterEvaluations.plotData(CEOKKF_DataPlot_KLD);
Plotter.PlotterEvaluations.plotData(KBF_DataPlot_KLD);

%%
Plotter.PlotterEvaluations.plotMinMax(true);
Plotter.PlotterEvaluations.plotMedianQuantile(true);

[GKKF_DataPlot_LT] = Plotter.PlotterEvaluations.preparePlotData(GKKF_Data, 'iterations', 'filterTimeEvaluator', 'settings.stateKRS_maxSizeReferenceSet', @(x_) num2str(x_), 'GKKF', false, [2:4], [], [], [1]);
[subGKKF_DataPlot_LT] = Plotter.PlotterEvaluations.preparePlotData(subGKKF_Data, 'iterations', 'filterTimeEvaluator', 'settings.reducedKRS_maxSizeReferenceSet', @(x_) num2str(x_), 'subGKKF', false, [2:4], [], [], [1]);
[CEOKKF_DataPlot_LT] = Plotter.PlotterEvaluations.preparePlotData(CEOKKF_Data, 'iterations', 'filterTimeEvaluator', 'settings.kernelReferenceSet_maxSizeReferenceSet', @(x_) num2str(x_), 'CEOKKF', false, [2:4], [], [], [1]);
[KBF_DataPlot_LT] = Plotter.PlotterEvaluations.preparePlotData(KBF_Data, 'iterations', 'filterTimeEvaluator', 'settings.stateKRS_maxSizeReferenceSet', @(x_) num2str(x_), 'KBF', false, [2:4], [], [], [1]);
[SPECTRAL_DataPlot_LT] = Plotter.PlotterEvaluations.preparePlotData(SPECTRAL_Data, 'iterations', 'filterTimeEvaluator', 'settings.state1KRS_maxSizeReferenceSet', @(x_) num2str(x_), 'SPECTRAL', false, [2:4], [], [], [1]);

Plotter.PlotterEvaluations.plotData(GKKF_DataPlot_LT);
Plotter.PlotterEvaluations.plotData(subGKKF_DataPlot_LT);
Plotter.PlotterEvaluations.plotData(CEOKKF_DataPlot_LT);
Plotter.PlotterEvaluations.plotData(KBF_DataPlot_LT);
Plotter.PlotterEvaluations.plotData(SPECTRAL_DataPlot_LT);

%%
Plotter.PlotterEvaluations.plotMinMax(true);
Plotter.PlotterEvaluations.plotMedianQuantile(true);

[GKKF_DataPlot_FT] = Plotter.PlotterEvaluations.preparePlotData(GKKF_Data, 'iterations', 'filterTimeEvaluator', 'settings.stateKRS_maxSizeReferenceSet', @(x_) num2str(x_), 'GKKF', false, [], [], [], [2]);
[subGKKF_DataPlot_FT] = Plotter.PlotterEvaluations.preparePlotData(subGKKF_Data, 'iterations', 'filterTimeEvaluator', 'settings.reducedKRS_maxSizeReferenceSet', @(x_) num2str(x_), 'subGKKF', false, [], [], [], [2]);
[CEOKKF_DataPlot_FT] = Plotter.PlotterEvaluations.preparePlotData(CEOKKF_Data, 'iterations', 'filterTimeEvaluator', 'settings.kernelReferenceSet_maxSizeReferenceSet', @(x_) num2str(x_), 'CEOKKF', false, [], [], [], [2]);
[KBF_DataPlot_FT] = Plotter.PlotterEvaluations.preparePlotData(KBF_Data, 'iterations', 'filterTimeEvaluator', 'settings.stateKRS_maxSizeReferenceSet', @(x_) num2str(x_), 'KBF', false, [], [1:16], [], [2]);
[SPECTRAL_DataPlot_FT] = Plotter.PlotterEvaluations.preparePlotData(SPECTRAL_Data, 'iterations', 'filterTimeEvaluator', 'settings.state1KRS_maxSizeReferenceSet', @(x_) num2str(x_), 'SPECTRAL', false, [], [], [], [2]);

Plotter.PlotterEvaluations.plotData(GKKF_DataPlot_FT);
Plotter.PlotterEvaluations.plotData(subGKKF_DataPlot_FT);
Plotter.PlotterEvaluations.plotData(CEOKKF_DataPlot_FT);
Plotter.PlotterEvaluations.plotData(KBF_DataPlot_FT);
Plotter.PlotterEvaluations.plotData(SPECTRAL_DataPlot_FT);