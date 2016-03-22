%% StandarsRepsOneSmallContextDiffMaxSample
load('+Experiments/data/test/PlanarHoleReaching_StandardRepsOneSmallContext/numSamples_201410152059_01/experiment.mat'); 
dataStandardRepsOneContextDiffMaxSamples = obj.getTrialData({'avgReturnAll'});
[plotStandardRepsOneContextDiffMaxSamples] = Plotter.PlotterEvaluations.preparePlotData(dataStandardRepsOneContextDiffMaxSamples, 'episodes', 'avgReturnAll', 'settings.maxSamples', ...
    @(x_) sprintf('maxSamples = %1.3f', x_), 'StandardRepsOneContextDiffMaxSamples', true, [], []);
Plotter.PlotterEvaluations.plotData(plotStandardRepsOneContextDiffMaxSamples);
Plotter.plot2svg('StandardRepsOneSmallContext.svg', gcf);

%% localRepsOneSmallContext
load('+Experiments/data/test/PlanarHoleReaching_localRepsOneContextDiffSmallBandwidthSmallConrext/numSamples_201410132249_01/experiment.mat');
datalocalRepsOneContextDiffMaxSamples = obj.getTrialData({'avgReturnAll'});
datalocalRepsOneContextDiffMaxSamples = Plotter.PlotterEvaluations.filterEvalData(datalocalRepsOneContextDiffMaxSamples, 'avgReturnAll', -10^5);
[plotlocalRepsOneContextDiffMaxSamples] = Plotter.PlotterEvaluations.preparePlotData(datalocalRepsOneContextDiffMaxSamples, 'episodes', 'avgReturnAll', 'settings.maxSamples', ...
    @(x_) sprintf('maxSamples = %1.3f', x_), 'localRepsOneContext', true, [], []);
Plotter.PlotterEvaluations.plotData(plotlocalRepsOneContextDiffMaxSamples);
Plotter.plot2svg('LocalRepsOneSmallContext.svg', gcf);

%% LocalReps and StandardReps Comparision for small context
algComparison = Plotter.PlotterEvaluations.mergePlots(plotStandardRepsOneContextDiffMaxSamples, [2], plotlocalRepsOneContextDiffMaxSamples, [1], 'test');


algComparison.evaluationLabels{1} = 'StandardReps';
algComparison.evaluationLabels{2} = 'localReps';

%algComparison = Plotter.PlotterEvaluations.smoothPlotData(algComparison, 3);
algComparison.plotInterval = 2;
Plotter.PlotterEvaluations.plotData(algComparison);
Plotter.plot2svg('AlgComparisonLocqalRepsAndStandardRepsSmallContext.svg', gcf);
return;

%% localRepsOneContextDiffBandwidth
load('/home/gn81ireg/policysearchtoolboxICRA/policysearchtoolbox/+Experiments/data/test/PlanarHoleReaching_localRepsOneContextDiffBandwidth/numSamples_201409271724_01/experiment.mat')
datalocalRepsOneContextDiffBandwidth = obj.getTrialData({'avgReturn'});

[plotlocalRepsOneContextDiffBandwidth] = Plotter.PlotterEvaluations.preparePlotData(datalocalRepsOneContextDiffBandwidth, 'episodes', 'avgReturn', 'settings.bandwidthFactor', ...
    @(x_) sprintf('bandwidthFactor = %1.3f', x_), 'localRepsOneContextDiffBandwidth', true, [], []);
Plotter.PlotterEvaluations.plotData(plotlocalRepsOneContextDiffBandwidth);

%% localRepsOneContextDiffMaxSamples
load('/home/gn81ireg/policysearchtoolboxICRA/policysearchtoolbox/+Experiments/data/test/PlanarHoleReaching_localRepsOneContextDiffMaxSamples/numSamples_201409271726_01/experiment.mat')
datalocalRepsOneContextDiffMaxSamples = obj.getTrialData({'avgReturn'});

[plotlocalRepsOneContextDiffMaxSamples] = Plotter.PlotterEvaluations.preparePlotData(datalocalRepsOneContextDiffMaxSamples, 'episodes', 'avgReturn', 'settings.maxSamples', ...
    @(x_) sprintf('maxSamples = %1.3f', x_), 'localRepsOneContextDiffBandwidth', true, [], []);
Plotter.PlotterEvaluations.plotData(plotlocalRepsOneContextDiffMaxSamples);

%% StandardRepsOneContextDiffMaxSamples
load('/home/gn81ireg/policysearchtoolboxICRA/policysearchtoolbox/+Experiments/data/test/PlanarHoleReaching_StandardRepsOneContextDiffMaxSamples/numSamples_201409271729_01/experiment.mat');
dataStandardRepsOneContextDiffMaxSamples = obj.getTrialData({'avgReturn'});

[plotStandardRepsOneContextDiffMaxSamples] = Plotter.PlotterEvaluations.preparePlotData(dataStandardRepsOneContextDiffMaxSamples, 'episodes', 'avgReturn', 'settings.maxSamples', ...
    @(x_) sprintf('maxSamples = %1.3f', x_), 'StandardRepsOneContextDiffMaxSamples', true, [], []);
Plotter.PlotterEvaluations.plotData(plotStandardRepsOneContextDiffMaxSamples);

%% StandardRepsOneContextRBFfeaturesDiffNumFeatures
load('/home/gn81ireg/policysearchtoolboxICRA/policysearchtoolbox/+Experiments/data/test/PlanarHoleReaching_StandardRepsOneContextRBFfeaturesDiffNumFeatures/numSamples_201409271730_01/experiment.mat')
dataStandardRepsOneContextRBFfeaturesDiffNumFeatures = obj.getTrialData({'avgReturn'});

[plotStandardRepsOneContextRBFfeaturesDiffNumFeatures] = Plotter.PlotterEvaluations.preparePlotData(dataStandardRepsOneContextRBFfeaturesDiffNumFeatures, 'episodes', 'avgReturn', 'settings.rbfNumDimCenters', ...
    @(x_) sprintf('rbfNumDimCenters = %1.3f', x_), 'StandardRepsOneContextRBFfeaturesDiffNumFeatures', true, [], []);
Plotter.PlotterEvaluations.plotData(plotStandardRepsOneContextRBFfeaturesDiffNumFeatures);

%% localRepsTwoContextDiffBandwidth
load('/home/gn81ireg/policysearchtoolboxICRA/policysearchtoolbox/+Experiments/data/test/PlanarHoleReaching_localRepsTwoContextDiffBandwidth/numSamples_201409271727_01/experiment.mat')
datalocalRepsTwoContextDiffBandwidth = obj.getTrialData({'avgReturn'});

[plotlocalRepsTwoContextDiffBandwidth] = Plotter.PlotterEvaluations.preparePlotData(datalocalRepsTwoContextDiffBandwidth, 'episodes', 'avgReturn', 'settings.bandwidthFactor', ...
    @(x_) sprintf('bandwidthFactor = %1.3f', x_), 'localRepsTwoContextDiffBandwidth', true, [], []);
Plotter.PlotterEvaluations.plotData(plotlocalRepsTwoContextDiffBandwidth);

%% localRepsTwoContextDiffMaxSamples
load('/home/gn81ireg/policysearchtoolboxICRA/policysearchtoolbox/+Experiments/data/test/PlanarHoleReaching_localRepsTwoContextDiffMaxSamples/numSamples_201409271728_01/experiment.mat')
datalocalRepsTwoContextDiffMaxSamples = obj.getTrialData({'avgReturn'});

[plotlocalRepsTwoContextDiffMaxSamples] = Plotter.PlotterEvaluations.preparePlotData(datalocalRepsTwoContextDiffMaxSamples, 'episodes', 'avgReturn', 'settings.maxSamples', ...
    @(x_) sprintf('maxSamples = %1.3f', x_), 'localRepsTwoContextDiffBandwidth', true, [], []);
Plotter.PlotterEvaluations.plotData(plotlocalRepsTwoContextDiffMaxSamples);

%% StandardRepsTwoContextDiffMaxSamples
load('/home/gn81ireg/policysearchtoolboxICRA/policysearchtoolbox/+Experiments/data/test/PlanarHoleReaching_StandardRepsTwoContextDiffMaxSamples/numSamples_201409271730_01/experiment.mat')
dataStandardRepsTwoContextDiffMaxSamples = obj.getTrialData({'avgReturn'});

[plotStandardRepsTwoContextDiffMaxSamples] = Plotter.PlotterEvaluations.preparePlotData(dataStandardRepsTwoContextDiffMaxSamples, 'episodes', 'avgReturn', 'settings.maxSamples', ...
    @(x_) sprintf('maxSamples = %1.3f', x_), 'StandardRepsTwoContextDiffMaxSamples', true, [], []);
Plotter.PlotterEvaluations.plotData(plotStandardRepsTwoContextDiffMaxSamples);

%% StandardRepsTwoContextRBFfeaturesDiffNumFeatures
load('/home/gn81ireg/policysearchtoolboxICRA/policysearchtoolbox/+Experiments/data/test/PlanarHoleReaching_StandardRepTwoContextRBFfeaturesDiffNumFeatures/numSamples_201409271739_01/experiment.mat')
dataStandardRepsTwoContextRBFfeaturesDiffNumFeatures = obj.getTrialData({'avgReturn'});

[plotStandardRepsTwoContextRBFfeaturesDiffNumFeatures] = Plotter.PlotterEvaluations.preparePlotData(dataStandardRepsTwoContextRBFfeaturesDiffNumFeatures, 'episodes', 'avgReturn', 'settings.rbfNumDimCenters', ...
    @(x_) sprintf('rbfNumDimCenters = %1.3f', x_), 'StandardRepsTwoContextRBFfeaturesDiffNumFeatures', true, [], []);
Plotter.PlotterEvaluations.plotData(plotStandardRepsTwoContextRBFfeaturesDiffNumFeatures);


