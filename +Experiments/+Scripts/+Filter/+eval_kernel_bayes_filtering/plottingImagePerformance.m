% 
load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalKernelBayesFiltering/Swing_stateAliasAdder_randEvPreproConf_FeaturePicture_noisePreproConf_LinearTransform_stateFeatures_winPreproConf_obsPointsPreproConf_gkkfConf/images_201505042158_01/experiment.mat')
kbfFilterImageData1 = obj.getTrialData({'filteredImageDataEvaluator'});
% load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalKernelBayesFiltering/Swing_stateAliasAdder_FeaturePicture_noisePreproConfig_LinearTransform_stateFeatures_winPreproConfig_obsPointsPreproConfig_gkkfConfigurator/images_201505011454_01/experiment.mat')
% kbfFilterImageData2 = obj.getTrialData({'filteredImageDataEvaluator'});
load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalKernelBayesFiltering/Swing_stateAliasAdder_FeaturePicture_noisePreproConfig_LinearTransform_stateFeatures_winPreproConfig_obsPointsPreproConfig_gkkfConfigurator/imagePrediction_201505011550_01/experiment.mat')
kbfPredictImageData = obj.getTrialData({'filteredImageDataEvaluator'});

Plotter.PlotterEvaluations.plotMinMax(true);
Plotter.PlotterEvaluations.plotMedianQuantile(true);


[filterImageDataPlotStd] = Plotter.PlotterEvaluations.preparePlotData(kbfFilterImageData1, 'iterations', 'filteredImageDataEvaluator', 'settings.obsKRS_maxSizeReferenceSet', @(x_) sprintf('standard KBF', x_), [], false, [1:5], []);
[filterImageDataPlotReg] = Plotter.PlotterEvaluations.preparePlotData(kbfFilterImageData1, 'iterations', 'filteredImageDataEvaluator', 'settings.redKRS_maxSizeReferenceSet', @(x_) sprintf('sub-space KBF', x_), [], false, [6:10], []);

[predictImageDataPlotStd] = Plotter.PlotterEvaluations.preparePlotData(kbfPredictImageData, 'iterations', 'filteredImageDataEvaluator', 'settings.obsKRS_maxSizeReferenceSet', @(x_) sprintf('standard KBF', x_), [], false, [1:5], []);
[predictImageDataPlotReg] = Plotter.PlotterEvaluations.preparePlotData(kbfPredictImageData, 'iterations', 'filteredImageDataEvaluator', 'settings.redKRS_maxSizeReferenceSet', @(x_) sprintf('sub-space KBF', x_), [], false, [6:10], []);

filterImageDataPlotStd.meansYData = squeeze(filterImageDataPlotStd.meansYData)';
filterImageDataPlotStd.stdsYData = permute(filterImageDataPlotStd.stdsYData,[2,1,3]);
filterImageDataPlotStd.xAxis = repmat([100 200 300 400 500],2,1);
filterImageDataPlotReg.meansYData = squeeze(filterImageDataPlotReg.meansYData)';
filterImageDataPlotReg.stdsYData = permute(filterImageDataPlotReg.stdsYData,[2,1,3]);
filterImageDataPlotReg.xAxis = repmat([100 200 300 400 500],2,1);

predictImageDataPlotStd.meansYData = squeeze(predictImageDataPlotStd.meansYData)';
predictImageDataPlotStd.stdsYData = permute(predictImageDataPlotStd.stdsYData,[2,1,3]);
predictImageDataPlotStd.xAxis = repmat([100 200 300 400 500],2,1);
predictImageDataPlotReg.meansYData = squeeze(predictImageDataPlotReg.meansYData)';
predictImageDataPlotReg.stdsYData = permute(predictImageDataPlotReg.stdsYData,[2,1,3]);
predictImageDataPlotReg.xAxis = repmat([100 200 300 400 500],2,1);

mergedFilterImageDataPlot = Plotter.PlotterEvaluations.mergePlots(filterImageDataPlotStd,[1],filterImageDataPlotReg,[1],'kbf/filterImageKBF',true);
mergedPredictImageDataPlot = Plotter.PlotterEvaluations.mergePlots(predictImageDataPlotStd,[1],predictImageDataPlotReg,[1],'kbf/predictImageKBF',true);

% mergedEvalDataPlot = Plotter.PlotterEvaluations.mergePlots(evalDataPlotStd,[1],evalDataPlotReg,[1],'filterEval',true);

Plotter.PlotterEvaluations.plotData(mergedFilterImageDataPlot);
Plotter.PlotterEvaluations.plotData(mergedPredictImageDataPlot);
% Plotter.PlotterEvaluations.plotData(mergedEvalDataPlot);

%%
% load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalReferenceSetSize/SwingDown_stateAliasAdder_FeaturePicture_LinearTransform_stateFeatures_windowPreprocessorConfigurator_observationPointsPreprocessorConfigurator_gkkfConfigurator/GkkfPendulumSwingDownRegImages_201502110041_01/experiment.mat');
% data = obj.getTrialData({'filteredDataEvaluator'});
% 
% Plotter.PlotterEvaluations.plotMinMax(true);
% [dataPlot ] = Plotter.PlotterEvaluations.preparePlotData(data, 'iterations', 'filteredDataEvaluator', 'settings.reducedKRS_maxSizeReferenceSet', @(x_) sprintf('RefSet = %1.3f', x_), [], false, [1], []);
% % Plotter.PlotterEvaluations.plotData(dataPlot);