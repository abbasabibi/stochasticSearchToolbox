%Rosenbrock
%LinearPolicy1D
%load('/home/fcportugal/data/NaoWalking/LinearAndNonLinear1DContextualWalkLearning/LinearPolicy/numSamples_201511202024_01/experiment.mat')
%o.changePath('/home/fcportugal/data/NaoWalking/LinearAndNonLinear1DContextualWalkLearning/LinearPolicy/numSamples_201511202024_01/')
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
%Rosenbrock
%%plotdataLinearPolicy = Plotter.PlotterEvaluations.smoothPlotData(plotdataLinearPolicy, 15);
%load('/home/abbas/Documents/stochasticsearchtoolbox/policysearchtoolbox/+Experiments/data/test/Retina/test/Examples.StochasticSearch.IROS.RBFCECER_StandardFunctions/settings001/experiment.mat')
%a= experiment.evaluationCollections{1};
%[~, plotDataCMAES] = a.plotResultsTrials(1,'avgReturns');
%load('/home/abbas/Documents/stochasticsearch/policysearchtoolbox/+Experiments/data/test/Retina/test/Examples.StochasticSearch.IROS.CECER_StandardFunctions/settings001/experiment.mat')
%experiment.changePath('+Experiments/data/test/Retina/test/Examples.StochasticSearch.IROS.CECER_StandardFunctions');
load('/home/abbas/Documents/stochasticsearch/policysearchtoolbox/+Experiments/data/test/Examples.StochasticSearch.IROS.CECER_StandardFunctions/settings001/experiment.mat')
%load('/home/abbas/Documents/stochasticsearch/policysearchtoolbox/+Experiments/data/test/Examples.StochasticSearch.reachingTask.CMAES_reachingTask/settings001/experiment.mat')
%load('/home/abbas/Documents/stochasticsearch/policysearchtoolbox/+Experiments/data/test/Examples.StochasticSearch.reachingTask.CMAES_reachingTask2/settings001/experiment.mat')
a= experiment.evaluationCollections{1};
[~, plotDataCECER] = a.plotResultsTrials(1,'avgReturns',2,[]);

load('/home/abbas/Documents/stochasticsearch/policysearchtoolbox/+Experiments/data/test/Examples.StochasticSearch.IROS.RBFCECER_StandardFunctions/settings001/experiment.mat')
%load('/home/abbas/Documents/stochasticsearch/policysearchtoolbox/+Experiments/data/test/Examples.StochasticSearch.reachingTask.CMAES_reachingTask/settings001/experiment.mat')
%load('/home/abbas/Documents/stochasticsearch/policysearchtoolbox/+Experiments/data/test/Examples.StochasticSearch.reachingTask.CMAES_reachingTask2/settings001/experiment.mat')
a= experiment.evaluationCollections{1};
[~, plotDataRBFCECER] = a.plotResultsTrials(1,'avgReturns',2,[]);

%load('/home/abbas/Documents/stochasticsearch/policysearchtoolbox/+Experiments/data/test/Examples.StochasticSearch.IROS.LocalREPS_StandardFunctionRosenSphere/settings001/experiment.mat')
%load('/home/abbas/Documents/stochasticsearch/policysearchtoolbox/+Experiments/data/test/Examples.StochasticSearch.reachingTask.CMAES_reachingTask/settings001/experiment.mat')
%load('/home/abbas/Documents/stochasticsearch/policysearchtoolbox/+Experiments/data/test/Examples.StochasticSearch.reachingTask.CMAES_reachingTask2/settings001/experiment.mat')
load('/home/abbas/Documents/stochasticsearch/policysearchtoolbox/+Experiments/data/test/Examples.StochasticSearch.IROS.LocalREPS_StandardFunctionCigarRastragin/settings001/experiment.mat')
a= experiment.evaluationCollections{1};
[~, plotDataLocalCECER] = a.plotResultsTrials(1,'avgReturns',1,[2:3]);




%AlgComparison
%algComparison = Plotter.PlotterEvaluations.mergePlots(plotdataLinearPolicy, [1], plotdataNonLinearPolicy, [1], '');
algComparison = Plotter.PlotterEvaluations.mergePlots(plotDataCECER, [1],  plotDataRBFCECER, [1], '');
algComparison = Plotter.PlotterEvaluations.mergePlots(algComparison, [1 2],  plotDataLocalCECER, [1], '', true);


algComparison.evaluationLabels{1} = 'Contextual CECER';
algComparison.evaluationLabels{2} = 'Contextual RBF-CECER';
algComparison.evaluationLabels{3} = 'Local CECER';




algComparison.evalProps(1).lineStyle = '-s';
algComparison.evalProps(1).lineWidth =1;
algComparison.evalProps(2).lineStyle = '-^';
algComparison.evalProps(2).lineWidth =1;
algComparison.evalProps(3).lineStyle = '-o';
algComparison.evalProps(3).lineWidth =1;



algComparison.plotInterval = 10;
Plotter.PlotterEvaluations.plotData(algComparison);

Plotter.plot2svg('Cigar.svg', gcf);