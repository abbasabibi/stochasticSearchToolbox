load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_CMAwithoutnoise/numSamples_201405171823_01/experiment.mat')

dataCMA = obj.getTrialData({'avgReturn'});

[dataCMAPlot ] = Plotter.PlotterEvaluations.preparePlotData(dataCMA, 'iterations', 'avgReturn', 'settings.initSigmaParameters', @(x_) sprintf('Sigma0 = %1.4f', x_), 'InitialSigma_CMA', false, [], []);
Plotter.PlotterEvaluations.plotData(dataCMAPlot);

%%
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_CMAwithnoise/numSamples_201405172054_01/experiment.mat')

dataCMA = obj.getTrialData({'avgReturn'});

[dataCMAPlot ] = Plotter.PlotterEvaluations.preparePlotData(dataCMA, 'iterations', 'avgReturn', 'settings.initSigmaParameters', @(x_) sprintf('Sigma0 = %1.4f', x_), 'InitialSigma_CMA', false, [], []);
Plotter.PlotterEvaluations.plotData(dataCMAPlot);
