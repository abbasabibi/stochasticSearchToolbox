clear all;
close all;

load('~/svn_projects/policysearchtoolbox/+Experiments/data/test/BallInACup_TrajectoryBased_REPS_InitialImitation/numSamples_201501201551_01//experiment.mat')
data = obj.getTrialData({'avgReturn'});

[plotDataREPS ] = Plotter.PlotterEvaluations.preparePlotData(data, 'episodes', 'avgReturn', 'settings.epsilonAction', @(x_) sprintf('epsilon = %.1f', x_), 'Epsilon_REPS', false, [], []);
plotDataREPS = Plotter.PlotterEvaluations.smoothPlotData(plotDataREPS,10);
Plotter.PlotterEvaluations.plotData(plotDataREPS );

%%
load('~/svn_projects/policysearchtoolbox/+Experiments/data/test/BallInACup_TrajectoryBased_Power_InitialImitation/numSamples_201501220931_01/experiment.mat')
data = obj.getTrialData({'avgReturn'});

[plotDataPower ] = Plotter.PlotterEvaluations.preparePlotData(data, 'episodes', 'avgReturn', 'settings.temperatureScalingPower', @(x_) sprintf('temperature = %.1f', x_), 'Temp_Power', false, [], []);
plotDataPower = Plotter.PlotterEvaluations.smoothPlotData(plotDataPower,10);
Plotter.PlotterEvaluations.plotData(plotDataPower );

%%
load('~/svn_projects/policysearchtoolbox/+Experiments/data/test/BallInACup_TrajectoryBased_NES_InitialImitation/numSamples_201501211146_01//experiment.mat')
data = obj.getTrialData({'avgReturn'});

[plotDataNES ] = Plotter.PlotterEvaluations.preparePlotData(data, 'episodes', 'avgReturn', 'settings.initSigmaParameters', @(x_) sprintf('initSigma = %.0d', x_), 'Epsilon_ACREPS', false, [], []);
%plotDataNES = Plotter.PlotterEvaluations.smoothPlotData(plotDataNES,10);
Plotter.PlotterEvaluations.plotData(plotDataNES );

%%
load('~/svn_projects/policysearchtoolbox/+Experiments/data/test/BallInACup_TrajectoryBased_CMA_InitialImitation/numSamples_201501191828_01/experiment.mat')
data = obj.getTrialData({'avgReturn'});
data(1).defaultParameters.numSamplesEpisodes.value = 17;

[plotDataCMA ] = Plotter.PlotterEvaluations.preparePlotData(data, 'episodes', 'avgReturn', 'settings.epsilonAction', @(x_) sprintf('epsilon = %.0d', x_), 'Epsilon_ACREPS', false, [], []);
%plotDataCMA = Plotter.PlotterEvaluations.smoothPlotData(plotDataCMA,10);
Plotter.PlotterEvaluations.plotData(plotDataCMA );

%%
plotDataComp = Plotter.PlotterEvaluations.mergePlots(plotDataREPS, 1, plotDataPower, 1, 'AlgComparison');
%plotDataComp = Plotter.PlotterEvaluations.mergePlots(plotDataComp, [1, 2], plotDataNES, 1, 'AlgComparison');
%plotDataComp = Plotter.PlotterEvaluations.mergePlots(plotDataComp, [1, 2 ,3], plotDataCMA, 1, 'AlgComparison');
plotDataComp.evaluationLabels{1} = 'REPS';
plotDataComp.evaluationLabels{2} = 'Power';
plotDataComp.evalProps(2).color = [1 0 0];

Plotter.PlotterEvaluations.plotData(plotDataComp );

%%
load('~/svn_projects/policysearchtoolbox/+Experiments/data/BeerBong/BeerPong_TrajectoryBased_REPS_InitialImitation/BeerPongREPS_201501181540_01//experiment.mat')
data = obj.getTrialData({'avgReturn'});

[plotDataBeerPong ] = Plotter.PlotterEvaluations.preparePlotData(data, 'episodes', 'avgReturn', 'settings.epsilonAction', @(x_) sprintf('epsilon = %.0d', x_), 'Epsilon_ACREPS', false, [], []);
plotDataBeerPong = Plotter.PlotterEvaluations.smoothPlotData(plotDataBeerPong,30);
Plotter.PlotterEvaluations.plotData(plotDataBeerPong );

%% Ball On a Beam
load('~/svn_projects/policysearchtoolbox/+Experiments/data/BallOnABeam/BallOnABeam_REPS/BallOnABeam_201501181952_01/experiment.mat')
data = obj.getTrialData({'avgReturn'});

[plotBallOnABeam ] = Plotter.PlotterEvaluations.preparePlotData(data, 'episodes', 'avgReturn', 'settings.epsilonAction', @(x_) sprintf('epsilon = %.0d', x_), 'AlgComparison', false, [1 2], []);
plotBallOnABeam = Plotter.PlotterEvaluations.smoothPlotData(plotBallOnABeam,30);

plotBallOnABeam.evaluationLabels{1} = 'REPS';
plotBallOnABeam.evaluationLabels{2} = 'POWER';
plotBallOnABeam.evaluationLabels{3} = 'CMA';
plotBallOnABeam.evaluationLabels{4} = 'NES';

Plotter.PlotterEvaluations.plotData(plotBallOnABeam );


%% Ball On a Beam

load('~/svn_projects/policysearchtoolbox/+Experiments/data/BallOnABeam/BallOnABeam_REPS/BallOnABeam_CMA_201501191002_01/experiment.mat')
data = obj.getTrialData({'avgReturn'});

[plotBallOnABeam ] = Plotter.PlotterEvaluations.preparePlotData(data, 'iterations', 'avgReturn', 'settings.epsilonAction', @(x_) sprintf('epsilon = %.0d', x_), 'AlgComparison', false, [], []);
plotBallOnABeam = Plotter.PlotterEvaluations.smoothPlotData(plotBallOnABeam,10);


Plotter.PlotterEvaluations.plotData(plotBallOnABeam );

%%

load('~/svn_projects/policysearchtoolbox/+Experiments/data/BallOnABeam/BallOnABeam_NES/BallOnABeam_NES_201501191457_01//experiment.mat')
data = obj.getTrialData({'avgReturn'});

[plotBallOnABeam ] = Plotter.PlotterEvaluations.preparePlotData(data, 'iterations', 'avgReturn', 'settings.epsilonAction', @(x_) sprintf('epsilon = %.0d', x_), 'AlgComparison', false, [], []);
plotBallOnABeam = Plotter.PlotterEvaluations.smoothPlotData(plotBallOnABeam,10);


Plotter.PlotterEvaluations.plotData(plotBallOnABeam );


%%

load('~/policysearchtoolbox/+Experiments/data//BeerBong/BeerPong_TrajectoryBased_REPSVariants_ImportanceSamplingPreProc_InitialImitation/BeerPongREPS_201507032114_01/experiment.mat')
data = obj.getTrialData({'maxReturn'});

[plotBallOnABeam ] = Plotter.PlotterEvaluations.preparePlotData(data, 'iterations', 'maxReturn', '', '', 'AlgComparison', false, [], []);
plotBallOnABeam = Plotter.PlotterEvaluations.smoothPlotData(plotBallOnABeam,10);


Plotter.PlotterEvaluations.plotData(plotBallOnABeam );

