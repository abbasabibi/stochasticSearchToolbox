% 
load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalQuadLinkWindowPrediction/DoubleLinkSwingDown_noisePreprocessorConfigurator_windowPreprocessorConfigurator_groundtruthWindowPreprocessorConfigurator_observationPointsPreprocessorConfigurator_gkkfConfigurator/GkkfRegQuadLinkSwingDown_201503161905_01/experiment.mat')
regGkkfData = obj.getTrialData({'windowPredictionEvaluator'});

Plotter.PlotterEvaluations.plotMinMax(true);
Plotter.PlotterEvaluations.plotMedianQuantile(true);

nEpis = 5;
[regDataPlot1] = Plotter.PlotterEvaluations.preparePlotData(regGkkfData, 'iterations', 'windowPredictionEvaluator', 'settings.reducedKRS_maxSizeReferenceSet', @(x_) sprintf('kernel size = %d', x_), ['evalQuadLinkKernelSize'], false, [], [], [1]);
[regDataPlot2] = Plotter.PlotterEvaluations.preparePlotData(regGkkfData, 'iterations', 'windowPredictionEvaluator', 'settings.reducedKRS_maxSizeReferenceSet', @(x_) sprintf('kernel size = %d', x_), ['evalQuadLinkKernelSize'], false, [], [], [2]);

%%

regDataPlot1_ = regDataPlot1;
regDataPlot1_.meansYData = sqrt(regDataPlot1.meansYData(:,1:2:8) + regDataPlot1.meansYData(:,2:2:8));
regDataPlot1_.stdsYData = sqrt((regDataPlot1.stdsYData(:,1:2:8,:) + regDataPlot1.stdsYData(:,2:2:8,:))/2);
regDataPlot1_.xAxis = regDataPlot1.xAxis(:,1:4);

regDataPlot2_ = regDataPlot2;
regDataPlot2_.meansYData = sqrt(regDataPlot2.meansYData(:,1:2:8) + regDataPlot2.meansYData(:,2:2:8));
regDataPlot2_.stdsYData = sqrt((regDataPlot2.stdsYData(:,1:2:8,:) + regDataPlot2.stdsYData(:,2:2:8,:))/2);
regDataPlot2_.xAxis = regDataPlot2.xAxis(:,1:4);

Plotter.PlotterEvaluations.plotData(regDataPlot1_);
Plotter.PlotterEvaluations.plotData(regDataPlot2_);

%%
% load('/home/yy05vipo/git/policysearchtoolbox/+Experiments/data/evalReferenceSetSize/SwingDown_stateAliasAdder_FeaturePicture_LinearTransform_stateFeatures_windowPreprocessorConfigurator_observationPointsPreprocessorConfigurator_gkkfConfigurator/GkkfPendulumSwingDownRegImages_201502110041_01/experiment.mat');
% data = obj.getTrialData({'filteredDataEvaluator'});
% 
% Plotter.PlotterEvaluations.plotMinMax(true);
% [dataPlot ] = Plotter.PlotterEvaluations.preparePlotData(data, 'iterations', 'filteredDataEvaluator', 'settings.reducedKRS_maxSizeReferenceSet', @(x_) sprintf('RefSet = %1.3f', x_), [], false, [1], []);
% % Plotter.PlotterEvaluations.plotData(dataPlot);