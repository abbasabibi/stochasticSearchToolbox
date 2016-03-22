%LinearPolicy1D
%load('/home/fcportugal/data/NaoWalking/LinearAndNonLinear1DContextualWalkLearning/LinearPolicy/numSamples_201511202024_01/experiment.mat')
%obj.changePath('/home/fcportugal/data/NaoWalking/LinearAndNonLinear1DContextualWalkLearning/LinearPolicy/numSamples_201511202024_01/')
%load('/home/abbas/Documents/stochasticsearch/policysearchtoolbox/+Experiments/data/test/Examples.StochasticSearch.Rosenbrock.MORE_rosenbrockmultiplytrials/settings001/experiment.mat')
%load('/home/abbas/Documents/stochasticsearch/policysearchtoolbox/+Experiments/data/test/Examples.StochasticSearch.Rosenbrock.CMAES_rosenbrock/settings001/experiment.mat')
%load('/home/abbas/Documents/stochasticsearch/policysearchtoolbox/+Experiments/data/test/Examples.StochasticSearch.Rosenbrock.REPS_rosenbrock/settings001/experiment.mat')
%load('/home/abbas/Documents/stochasticsearch/policysearchtoolbox/+Experiments/data/test/Examples.StochasticSearch.Rosenbrock.MORE_rosenbrock/settings006/experiment.mat')
%load('/home/abbas/Documents/stochasticsearch/policysearchtoolbox/+Experiments/data/test/Examples.StochasticSearch.Rosenbrock.NES_rosenbrock/settings001/experiment.mat')
%load('/home/abbas/Documents/stochasticsearch/policysearchtoolbox/+Experiments/data/test/Examples.StochasticSearch.Rosenbrock.PI2_rosenbrock/settings001/experiment.mat')
%a= experiment.evaluationCollections{1};
%[~, plotDataMore] = a.plotResultsTrials(1,'avgReturns');
%dataLinearPolicy= experiment.getTrialData({'avgReturn'});

%[plotdataLinearPolicy ] = Plotter.PlotterEvaluations.preparePlotData(dataLinearPolicy, 'episodes', 'avgReturn', 'settings.entropyBeta', ...
    %@(x_) sprintf('EntropyBeta = %1.3f', x_), '', true, [], []);

%plotdataLinearPolicy = Plotter.PlotterEvaluations.smoothPlotData(plotdataLinearPolicy, 15);


%load('/home/abbas/Documents/stochasticsearch/policysearchtoolbox/+Experiments/data/test/Examples.StochasticSearch.reachingTask.CMAES_reachingTask/settings001/experiment.mat')
load('/home/abbas/Documents/stochasticsearch/policysearchtoolbox/+Experiments/data/test/Examples.StochasticSearch.Rosenbrock.CMAES_rastragin/settings001/experiment.mat')
a= experiment.evaluationCollections{1};
[~, plotDataCMAES] = a.plotResultsTrials(1,'avgReturns');

load('/home/abbas/Documents/stochasticsearch/policysearchtoolbox/+Experiments/data/test/Examples.StochasticSearch.Rosenbrock.REPS_Rastragin/settings001/experiment.mat')
a= experiment.evaluationCollections{1};
[~, plotDataCECERREPS] = a.plotResultsTrials(1,'avgReturns');

load('/home/abbas/Documents/stochasticsearch/policysearchtoolbox/+Experiments/data/test/Examples.StochasticSearch.Rosenbrock.StandardREPS_rastragin/settings001/experiment.mat')
a= experiment.evaluationCollections{1};
[~, plotDataREPS] = a.plotResultsTrials(1,'avgReturns');



%AlgComparison
%algComparison = Plotter.PlotterEvaluations.mergePlots(plotdataLinearPolicy, [1], plotdataNonLinearPolicy, [1], '');
algComparison = Plotter.PlotterEvaluations.mergePlots(plotDataCMAES, [1],  plotDataREPS, [1], '');
algComparison = Plotter.PlotterEvaluations.mergePlots(algComparison, [1 2],  plotDataCECERREPS, [1], '', true);


algComparison.evaluationLabels{1} = 'Contextual CMA-ES';
algComparison.evaluationLabels{2} = 'Contextual REPS';
algComparison.evaluationLabels{3} = 'Contextual CECER';




algComparison.evalProps(1).lineStyle = '-s';
algComparison.evalProps(1).lineWidth =1;
algComparison.evalProps(2).lineStyle = '-^';
algComparison.evalProps(2).lineWidth =1;
algComparison.evalProps(3).lineStyle = '-o';
algComparison.evalProps(3).lineWidth =1;



algComparison.plotInterval = 10;
Plotter.PlotterEvaluations.plotData(algComparison);

Plotter.plot2svg('geccoRastragin.svg', gcf);