% 
load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalKernelBayesFiltering/Swing_stateAliasAdder_randEventPreproConf_noisePreproConf_windowPreproConf_obsPointsPreproConf_kbfConf/fixedKernelSize_201505042251_01/experiment.mat')
kbfData = obj.getTrialData({'filteredDataEvaluator' 'filterTimeEvaluator'});

Plotter.PlotterEvaluations.plotMinMax(true);
Plotter.PlotterEvaluations.plotMedianQuantile(true);

% rangeStd = 1:4;
% rangeReg = 5:8;

rangeStd = 1:5;
rangeReg = 6:10;

[timeDataPlotStd] = Plotter.PlotterEvaluations.preparePlotData(kbfData, 'iterations', 'filterTimeEvaluator', 'settings.obsKRS_maxSizeReferenceSet', @(x_) sprintf('std KBF', x_), [], false, rangeStd, [],[],[1:2]);
[timeDataPlotReg] = Plotter.PlotterEvaluations.preparePlotData(kbfData, 'iterations', 'filterTimeEvaluator', 'settings.obsKRS_maxSizeReferenceSet', @(x_) sprintf('reg KBF', x_), [], false, rangeReg, [],[],[1:2]);
[evalDataPlotStd] = Plotter.PlotterEvaluations.preparePlotData(kbfData, 'iterations', 'filteredDataEvaluator', 'settings.obsKRS_maxSizeReferenceSet', @(x_) sprintf('std KBF', x_), [], false, rangeStd, []);
[evalDataPlotReg] = Plotter.PlotterEvaluations.preparePlotData(kbfData, 'iterations', 'filteredDataEvaluator', 'settings.obsKRS_maxSizeReferenceSet', @(x_) sprintf('reg KBF', x_), [], false, rangeReg, []);

timeDataPlotStd.meansYData = squeeze(timeDataPlotStd.meansYData)';
timeDataPlotStd.stdsYData = permute(timeDataPlotStd.stdsYData,[2,1,3]);
timeDataPlotStd.xAxis = repmat([obj.evaluation.values{rangeStd,2}],2,1);
timeDataPlotReg.meansYData = squeeze(timeDataPlotReg.meansYData)';
timeDataPlotReg.stdsYData = permute(timeDataPlotReg.stdsYData,[2,1,3]);
timeDataPlotReg.xAxis = repmat([obj.evaluation.values{rangeStd,2}],2,1);

evalDataPlotStd.meansYData = squeeze(evalDataPlotStd.meansYData)';
evalDataPlotStd.stdsYData = flip(squeeze(evalDataPlotStd.stdsYData)');
evalDataPlotStd.xAxis = [obj.evaluation.values{rangeStd,2}];
evalDataPlotReg.meansYData = squeeze(evalDataPlotReg.meansYData)';
evalDataPlotReg.stdsYData = flip(squeeze(evalDataPlotReg.stdsYData)');
evalDataPlotReg.xAxis = [obj.evaluation.values{rangeStd,2}];

mergedTimeDataPlot1 = Plotter.PlotterEvaluations.mergePlots(timeDataPlotStd,[1],timeDataPlotReg,[1],'kbf/filterLearningTime',true);

mergedTimeDataPlot2 = Plotter.PlotterEvaluations.mergePlots(timeDataPlotStd,[2],timeDataPlotReg,[2],'kbf/filterRunTime',true);

mergedEvalDataPlot = Plotter.PlotterEvaluations.mergePlots(evalDataPlotStd,[1],evalDataPlotReg,[1],'kbf/filterPerformance',true);

Plotter.PlotterEvaluations.plotData(mergedTimeDataPlot1);
Plotter.PlotterEvaluations.plotData(mergedTimeDataPlot2);
Plotter.PlotterEvaluations.plotData(mergedEvalDataPlot);

%%
% load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalReferenceSetSize/SwingDown_stateAliasAdder_FeaturePicture_LinearTransform_stateFeatures_windowPreprocessorConfigurator_observationPointsPreprocessorConfigurator_gkkfConfigurator/GkkfPendulumSwingDownRegImages_201502110041_01/experiment.mat');
% data = obj.getTrialData({'filteredDataEvaluator'});
% 
% Plotter.PlotterEvaluations.plotMinMax(true);
% [dataPlot ] = Plotter.PlotterEvaluations.preparePlotData(data, 'iterations', 'filteredDataEvaluator', 'settings.reducedKRS_maxSizeReferenceSet', @(x_) sprintf('RefSet = %1.3f', x_), [], false, [1], []);
% % Plotter.PlotterEvaluations.plotData(dataPlot);