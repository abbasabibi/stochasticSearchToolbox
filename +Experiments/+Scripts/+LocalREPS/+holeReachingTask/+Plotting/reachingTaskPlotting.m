%% localRepsOneContextDiffBandwidth
load('+Experiments/data/test/PlanarReaching_localRepsReachingTaskDiffBandwidth/numSamples_201409300120_01/experiment.mat')
datalocalRepsReachingTaskDiffBandwidth = obj.getTrialData({'avgReturnAll'});

[plotlocalRepsReachingTaskDiffBandwidth] = Plotter.PlotterEvaluations.preparePlotData(datalocalRepsReachingTaskDiffBandwidth, 'episodes', 'avgReturnAll', 'settings.bandwidthFactor', ...
    @(x_) sprintf('bandwidthFactor = %1.3f', x_), 'localRepsReachingTaskDiffBandwidth', false, [], []);
Plotter.PlotterEvaluations.plotData(plotlocalRepsReachingTaskDiffBandwidth);
Plotter.plot2svg('LocalRepsReachingTaskFalse.svg', gcf);


load('+Experiments/data/test/PlanarReaching_StandardRepsReachingTaskDiffMaxSamples/numSamples_201409301034_01/experiment.mat') 
dataStandardRepsReachingTaskDiffMaxSamples = obj.getTrialData({'avgReturnAll'});

[plotStandardRepsReachingTaskDiffMaxSamples] = Plotter.PlotterEvaluations.preparePlotData(dataStandardRepsReachingTaskDiffMaxSamples, 'episodes', 'avgReturnAll', 'settings.maxSamples', ...
    @(x_) sprintf('maxSamples = %1.3f', x_), 'StandardRepsReachingTaskDiffMaxSamples', false, [], []);
Plotter.PlotterEvaluations.plotData(plotStandardRepsReachingTaskDiffMaxSamples);
Plotter.plot2svg('StandardRepsReachingTaskFalse.svg', gcf);

algComparison = Plotter.PlotterEvaluations.mergePlots(plotlocalRepsReachingTaskDiffBandwidth, [2], plotStandardRepsReachingTaskDiffMaxSamples, [2], 'test');


algComparison.evaluationLabels{1} = 'LocalReps';
algComparison.evaluationLabels{2} = 'StandardReps';

%algComparison = Plotter.PlotterEvaluations.smoothPlotData(algComparison, 3);
algComparison.plotInterval = 2;
Plotter.PlotterEvaluations.plotData(algComparison);
Plotter.plot2svg('AlgComparisonLocqalRepsAndStandardReps.svg', gcf);
