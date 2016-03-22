
load('/home/abbas/Documents/stochasticsearch/policysearchtoolbox/+Experiments/data/test/Examples.StochasticSearch.IROSHoleReaching.CECERholeReachingTask2Context/settings001/experiment.mat')
a= experiment.evaluationCollections{1};
[~, plotDataCECER] = a.plotResultsTrials(1,'avgReturn',[],[2,3]);

load('/home/abbas/Documents/stochasticsearch/policysearchtoolbox/+Experiments/data/test/Examples.StochasticSearch.IROSHoleReaching.RBFCECERholeReachingTask2Context/settings001/experiment.mat')
a= experiment.evaluationCollections{1};
[~, plotDataRBFCECER] = a.plotResultsTrials(1,'avgReturn',[],[2,4]);


load('/home/abbas/Documents/stochasticsearch/policysearchtoolbox/+Experiments/data/test/Examples.StochasticSearch.LocalREPS.LocalRepsHoleReachingTask2Contex/settings001/experiment.mat')
a= experiment.evaluationCollections{1};
[~, plotDataLocalCECER] = a.plotResultsTrials(1,'avgReturn',[],[1,2,5]);





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

Plotter.plot2svg('HoleReachingTask2C.svg', gcf);