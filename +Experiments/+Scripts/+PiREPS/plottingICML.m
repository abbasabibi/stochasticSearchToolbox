clear variables;
close all;

%% NumSamples PIREPS
%load('/home/neumann/svn_projects/policysearchtoolbox/+Experiments/data/test/DoubleLinkSwingUpFH_PiREPS/numSamples_201401290125_01/experiment.mat');
%load('/home/vgomez/policysearchtoolbox/+Experiments/data/test/DoubleLinkSwingUpFH_SquaredFeatures_TimeDependentPolicy_PiREPS/numSamples_201502181245_01/experiment.mat')
load('/home/vgomez/policysearchtoolbox/+Experiments/data/test/DoubleLinkSwingUpFH_SquaredFeatures_TimeDependentPolicy_PiREPS/numSamples_201503310044_01/experiment.mat')

%cd +Experiments
dataPiREPSSamples = obj.getTrialData({'avgReturn'});

[plotDataPiREPSSamples] = Plotter.PlotterEvaluations.preparePlotData(dataPiREPSSamples, 'iterations', 'avgReturn', 'settings.numSamplesEpisodes', @(x_) sprintf('num Samples = %.0d', x_), 'NumSamples_PiREPS', true, [], []);
Plotter.PlotterEvaluations.plotData(plotDataPiREPSSamples );

% %% initial Sigma Variance
% 
% load([project_path '/policysearchtoolbox/+Experiments/data/test/DoubleLinkSwingUpFH_PiREPS/SigmaActions_201401292057_01/experiment.mat']);
% dataPiREPSNoise = obj.getTrialData({'avgReturn'});
% 
% [plotDataPiREPSNoise ] = Plotter.PlotterEvaluations.preparePlotData(dataPiREPSNoise, 'iterations', 'avgReturn', 'settings.initSigmaActions', @(x_) sprintf('Sigma0 = %1.3f', x_^2), 'InitialSigma_PiREPS', true, [1 3 5], []);
% Plotter.PlotterEvaluations.plotData(plotDataPiREPSNoise);
% 
% %% Power lambda
% 
% load('/home/neumann/svn_projects/policysearchtoolbox/+Experiments/data_vicenc/test/DoubleLinkSwingUpFH_Power/temperatureScalingPower_201401301634_01/experiment.mat')
% dataPowerLambda = obj.getTrialData({'avgReturn'});
% 
% [plotDataPowerLambda ] = Plotter.PlotterEvaluations.preparePlotData(dataPowerLambda, 'iterations', 'avgReturn', 'settings.temperatureScalingPower', @(x_) sprintf('lambda = %1.3f', x_), 'Lambda_PiREPS', true, [], []);
% Plotter.PlotterEvaluations.plotData(plotDataPowerLambda);
% 
% %% Power Open Loop
% load('/home/neumann/svn_projects/policysearchtoolbox/+Experiments/data_vicenc/test/DoubleLinkSwingUpFH_EpisodicPower/temperatureScalingPower_201401301215_01/experiment.mat')
% plotDataPowerOpenLoop = obj.getTrialData({'avgReturn'});
% 
% [plotDataPowerOpenLoop ] = Plotter.PlotterEvaluations.preparePlotData(plotDataPowerOpenLoop, 'iterations', 'avgReturn', 'settings.temperatureScalingPower', @(x_) sprintf('lambda = %1.3f', x_), 'OpenLoop', true, [], []);
% Plotter.PlotterEvaluations.plotData(plotDataPowerOpenLoop);


%% Episodic PiREPS Samples
%load('/home/neumann/svn_projects/policysearchtoolbox/+Experiments/data_vicenc/test/DoubleLinkSwingUpFH_EpisodicPiREPS/numSamples_201401291118_01/experiment.mat')
%load('/home/vgomez/policysearchtoolbox/+Experiments/data/test/DoubleLinkSwingUpFH_SquaredContextFeatures_TimeDependentPolicy_EpisodicPiREPS/numSamples_201502181159_01/experiment.mat')
load('/home/vgomez/policysearchtoolbox/+Experiments/data/test/DoubleLinkSwingUpFH_SquaredContextFeatures_TimeDependentPolicy_EpisodicPiREPS/numSamples_201503271751_01/experiment.mat');
obj.path = ['+Experiments/' obj.path];
dataEpisodicPiREPSamples = obj.getTrialData({'avgReturn'});

[dataEpisodicPiREPSamples ] = Plotter.PlotterEvaluations.preparePlotData(dataEpisodicPiREPSamples, 'iterations', 'avgReturn', 'settings.numSamplesEpisodes', @(x_) sprintf('num Samples = %1.3f', x_), 'NumSamples_EpisodicPiREPS', true, [], []);
Plotter.PlotterEvaluations.plotData(dataEpisodicPiREPSamples);
% 
% %% 2nd
% load('/home/neumann/svn_projects/policysearchtoolbox/+Experiments/data_vicenc/test/DoubleLinkSwingUpFH_EpisodicPiREPS/numSamples_201401290122_01/experiment.mat')
% dataEpisodicPiREPSamples2 = obj.getTrialData({'avgReturn'});
% 
% [dataEpisodicPiREPSamples2 ] = Plotter.PlotterEvaluations.preparePlotData(dataEpisodicPiREPSamples2, 'iterations', 'avgReturn', 'settings.numSamples', @(x_) sprintf('num Samples = %1.3f', x_), 'NumSamples_EpisodicPiREPS2', true, [], []);
% Plotter.PlotterEvaluations.plotData(dataEpisodicPiREPSamples2);

% 
% %% Noise_std Episodic PiREPS 
%load('/home/vgomez/policysearchtoolbox/+Experiments/data/test/DoubleLinkSwingUpFH_SquaredContextFeatures_TimeDependentPolicy_EpisodicPiREPS/noiseStd_201502191324_01/experiment.mat')
load('/home/vgomez/policysearchtoolbox/+Experiments/data/test/DoubleLinkSwingUpFH_SquaredContextFeatures_TimeDependentPolicy_EpisodicPiREPS/noiseStd_201503310050_01/experiment.mat')
dataEpisodicPiREPNoise = obj.getTrialData({'avgReturn'});
[dataEpisodicPiREPNoise ] = Plotter.PlotterEvaluations.preparePlotData(dataEpisodicPiREPNoise, 'iterations', 'avgReturn', 'settings.Noise_std', @(x_) sprintf('Noise = %1.3f', x_), 'Noise_EpisodicPiREPS', true, [], []);
Plotter.PlotterEvaluations.plotData(dataEpisodicPiREPNoise);

% load('/home/neumann/svn_projects/policysearchtoolbox/+Experiments/data_vicenc/test/DoubleLinkSwingUpFH_EpisodicPiREPS/noiseStd_201401290131_01/experiment.mat')
% dataEpisodicPiREPNoise = obj.getTrialData({'avgReturn'});
% [dataEpisodicPiREPNoise ] = Plotter.PlotterEvaluations.preparePlotData(dataEpisodicPiREPNoise, 'iterations', 'avgReturn', 'settings.Noise_std', @(x_) sprintf('Noise = %1.3f', x_), 'Noise_EpisodicPiREPS', true, [2:4], []);
% Plotter.PlotterEvaluations.plotData(dataEpisodicPiREPNoise);

% %% Step-based, No Features
% load('/home/neumann/svn_projects/policysearchtoolbox/+Experiments/data_vicenc/test/DoubleLinkSwingUpFH_PiREPS_NoFeatures/numSamples_201401301207_01/experiment.mat')
% dataEpisodicNoFeatures = obj.getTrialData({'avgReturn'});
% 
% [dataEpisodicNoFeatures ] = Plotter.PlotterEvaluations.preparePlotData(dataEpisodicNoFeatures, 'iterations', 'avgReturn', 'settings.numSamplesEpisodes', @(x_) sprintf('num Samples = %1.3f', x_), 'NoFeatures_EpisodicPiREPS', true, [2:4], []);
% Plotter.PlotterEvaluations.plotData(dataEpisodicNoFeatures);
% 
% %% initial  Variance Episodic 
% 
%load('/home/vgomez/policysearchtoolbox/+Experiments/data/test/DoubleLinkSwingUpFH_SquaredContextFeatures_TimeDependentPolicy_EpisodicPiREPS/SigmaActions_201502191333_01/experiment.mat')
%load('/home/vgomez/policysearchtoolbox/+Experiments/data/test/DoubleLinkSwingUpFH_SquaredContextFeatures_TimeDependentPolicy_EpisodicPiREPS/SigmaActions_201502201037_01/experiment.mat')
load('/home/vgomez/policysearchtoolbox/+Experiments/data/test/DoubleLinkSwingUpFH_SquaredContextFeatures_TimeDependentPolicy_EpisodicPiREPS/SigmaActions_201503291325_01/experiment.mat')
dataPiREPSNoise = obj.getTrialData({'avgReturn'});

[plotDataPiREPSNoise ] = Plotter.PlotterEvaluations.preparePlotData(dataPiREPSNoise, 'iterations', 'avgReturn', 'settings.initSigmaActions', @(x_) sprintf('Sigma0 = %1.3f', x_^2), 'EpisodicInitialSigma_PiREPS', true, [], []);
Plotter.PlotterEvaluations.plotData(plotDataPiREPSNoise);

% load('/home/neumann/svn_projects/policysearchtoolbox/+Experiments/data_vicenc/test/DoubleLinkSwingUpFH_EpisodicPiREPS/SigmaActions_201401292054_01/experiment.mat')
% dataPiREPSNoise = obj.getTrialData({'avgReturn'});
% 
% [plotDataPiREPSNoise ] = Plotter.PlotterEvaluations.preparePlotData(dataPiREPSNoise, 'iterations', 'avgReturn', 'settings.initSigmaActions', @(x_) sprintf('Sigma0 = %1.3f', x_^2), 'EpisodicInitialSigma_PiREPS', true, [], []);
% Plotter.PlotterEvaluations.plotData(plotDataPiREPSNoise);
% 
% %% Model-based
%load('/home/vgomez/policysearchtoolbox/+Experiments/data/test/DoubleLinkSwingUpFH_SquaredContextFeatures_SquaredFeatures_TimeDependentPolicy_EpisodicPiREPS/numSamples_201502191241_01/experiment.mat')
%load('/home/vgomez/policysearchtoolbox/+Experiments/data/test/DoubleLinkSwingUpFH_SquaredContextFeatures_SquaredFeatures_TimeDependentPolicy_EpisodicPiREPS/numSamples_201503310031_01/experiment.mat');

%load('/home/vgomez/policysearchtoolbox/+Experiments/data/test/DoubleLinkSwingUpFH_SquaredContextFeatures_SquaredFeatures_TimeDependentPolicy_EpisodicPiREPS/numSamples_201504260007_01/experiment.mat');
%load('/home/vgomez/policysearchtoolbox/+Experiments/data/test/DoubleLinkSwingUpFH_SquaredContextFeatures_SquaredFeatures_TimeDependentPolicy_EpisodicPiREPS/numSamples_201504271839_01/experiment.mat');
load('/home/vgomez/policysearchtoolbox/+Experiments/data/test/DoubleLinkSwingUpFH_SquaredContextFeatures_SquaredFeatures_TimeDependentPolicy_EpisodicPiREPS/numSamples_201505081756_01/experiment.mat')

dataPiREPSModel = obj.getTrialData({'avgReturn'});
[dataPiREPSModel ] = Plotter.PlotterEvaluations.preparePlotData(dataPiREPSModel, 'episodes', 'avgReturn', 'settings.numSamplesEpisodes', @(x_) sprintf('N = %.0d', x_), 'ModelBased_PiREPS', true, [], []);
Plotter.PlotterEvaluations.plotData(dataPiREPSModel);

% load('/home/neumann/svn_projects/policysearchtoolbox/+Experiments/data_vicenc/test/numSamples_201401302222_01/experiment.mat')
% dataPiREPSModel = obj.getTrialData({'avgReturn'});
% 
% [dataPiREPSModel ] = Plotter.PlotterEvaluations.preparePlotData(dataPiREPSModel, 'episodes', 'avgReturn', 'settings.numSamplesEpisodes', @(x_) sprintf('N = %.0d', x_), 'ModelBased_PiREPS', true, [1], []);
% Plotter.PlotterEvaluations.plotData(dataPiREPSModel);

%% Epsilon 
%load('/home/neumann/svn_projects/policysearchtoolbox/+Experiments/data_vicenc/test/DoubleLinkSwingUpFH_EpisodicPiREPS/epsilon_201401292113_01/experiment.mat')
%load('/home/vgomez/policysearchtoolbox/+Experiments/data/test/DoubleLinkSwingUpFH_SquaredContextFeatures_TimeDependentPolicy_EpisodicPiREPS/epsilon_201502172327_01/experiment.mat');
load('/home/vgomez/policysearchtoolbox/+Experiments/data/test/DoubleLinkSwingUpFH_SquaredContextFeatures_TimeDependentPolicy_EpisodicPiREPS/epsilon_201503310021_01/experiment.mat')
dataEpsilon = obj.getTrialData({'avgReturn'});

%[dataEpsilon ] = Plotter.PlotterEvaluations.preparePlotData(dataEpsilon, 'iterations', 'avgReturn', 'settings.epsilonAction', @(x_) sprintf('epsilon = %1.2f', x_), 'Epsilon_PiREPS', true, [1 3 5], []);
[dataEpsilon ] = Plotter.PlotterEvaluations.preparePlotData(dataEpsilon, 'iterations', 'avgReturn', 'settings.epsilonAction', @(x_) sprintf('epsilon = %1.2f', x_), 'Epsilon_PiREPS', true, [], []);
Plotter.PlotterEvaluations.plotData(dataEpsilon);



%% Step-Based vs episodic


stepVsEpisodeBased = Plotter.PlotterEvaluations.mergePlots(plotDataPiREPSSamples, [1 2], dataEpisodicPiREPSamples, [1 2 3], 'test');
%stepVsEpisodeBased = Plotter.PlotterEvaluations.mergePlots(plotDataPiREPSSamples, [1 2], dataEpisodicPiREPSamples, [3], 'test');
%stepVsEpisodeBased = Plotter.PlotterEvaluations.mergePlots(stepVsEpisodeBased, [1 2 3], dataEpisodicPiREPSamples2, [1 2], 'EpisodeStepBasedComparison', true);
 
stepVsEpisodeBased.evaluationLabels{1} = 'Step Based, N = 800';
stepVsEpisodeBased.evaluationLabels{2} = 'Step Based, N = 400';
stepVsEpisodeBased.evaluationLabels{3} = 'Episode Based, N = 2000';
stepVsEpisodeBased.evaluationLabels{4} = 'Episode Based, N = 800';
stepVsEpisodeBased.evaluationLabels{5} = 'Episode Based, N = 400';

stepVsEpisodeBased.evalProps(1).lineStyle = '-';
stepVsEpisodeBased.evalProps(2).lineStyle = '-';
stepVsEpisodeBased.evalProps(3).lineStyle = '--';
stepVsEpisodeBased.evalProps(4).lineStyle = '--';
stepVsEpisodeBased.evalProps(5).lineStyle = '--';

Plotter.PlotterEvaluations.plotData(stepVsEpisodeBased);
%% Algorithms

algComparison = Plotter.PlotterEvaluations.mergePlots(plotDataPiREPSSamples, [1], dataEpisodicNoFeatures, [2], 'test');
algComparison = Plotter.PlotterEvaluations.mergePlots(algComparison, [1 2], plotDataPowerLambda, [4], 'AlgorithmComparison', true);
algComparison = Plotter.PlotterEvaluations.mergePlots(algComparison, [1 2 3], plotDataPowerOpenLoop, [1], 'AlgorithmComparison', true);

algComparison.evaluationLabels{1} = 'PI REPS';
algComparison.evaluationLabels{2} = 'No Features';
algComparison.evaluationLabels{3} = 'PI2';
algComparison.evaluationLabels{4} = 'Open Loop PI2';

Plotter.PlotterEvaluations.plotData(algComparison);

%% Animations
load('/home/neumann/svn_projects/policysearchtoolbox/+Experiments/data_vicenc/test/DoubleLinkSwingUpFH_PiREPS/numSamples_201401290125_01/eval001/trial001/trial.mat')
trial.transitionFunction.animate(trial.data.getDataEntry('states', 45, 1:35))
Plotter.plot2svg('animation2Link1', gcf);

trial.transitionFunction.animate(trial.data.getDataEntry('states', 45, 35:65))
Plotter.plot2svg('animation2Link2', gcf);

%% Trajectors distributions
load('/home/neumann/svn_projects/policysearchtoolbox/+Experiments/data_vicenc/test/DoubleLinkSwingUpFH_EpisodicPiREPS/noiseStd_201401290131_01/eval001/trial001/trial.mat')
Plotter.PlotterData.plotTrajectoriesMeanAndStd(trial.data, 'states', 1:2:3)

load('/home/neumann/svn_projects/policysearchtoolbox/+Experiments/data_vicenc/test/DoubleLinkSwingUpFH_EpisodicPiREPS/noiseStd_201401290131_01/eval005/trial001/trial.mat')
Plotter.PlotterData.plotTrajectoriesMeanAndStd(trial.data, 'states', 1:2:3)

%% 4 Link

%load('/home/vgomez/policysearchtoolbox/+Experiments/data/test/QuadLinkSwingUpFH_SquaredContextFeatures_TimeDependentPolicy_EpisodicPiREPS/numSamples_201502191229_01/experiment.mat')
%load('/home/vgomez/policysearchtoolbox/+Experiments/data/test/QuadLinkSwingUpFH_SquaredContextFeatures_TimeDependentPolicy_EpisodicPiREPS/numSamples_201503302355_01/experiment.mat')
load('/home/vgomez/policysearchtoolbox/+Experiments/data/test/QuadLinkSwingUpFH_SquaredContextFeatures_TimeDependentPolicy_EpisodicPiREPS/numSamples_201504201531_01/experiment.mat');
%load('/home/neumann/svn_projects/policysearchtoolbox/+Experiments/data_vicenc/test/QuadLinkSwingUpFH_EpisodicPiREPS/numSamples_201401291134_01/experiment.mat')
data4Link = obj.getTrialData({'avgReturn'});

[data4Link ] = Plotter.PlotterEvaluations.preparePlotData(data4Link, 'iterations', 'avgReturn', 'settings.numSamplesEpisodes', @(x_) sprintf('N = %.0d', x_), '4LinkLearning', true, [], []);
%[data4Link ] = Plotter.PlotterEvaluations.preparePlotData(data4Link, 'iterations', 'avgReturn', 'settings.numSamples', @(x_) sprintf('N = %.0d', x_), '4LinkLearning', true, [1 2 4], []);
Plotter.PlotterEvaluations.plotData(data4Link);

%% Animations
%load('/home/vgomez/policysearchtoolbox/+Experiments/data/test/QuadLinkSwingUpFH_SquaredContextFeatures_TimeDependentPolicy_EpisodicPiREPS/numSamples_201503302355_01/eval001/trial001/trial.mat')
%load('/home/vgomez/policysearchtoolbox/+Experiments/data/test/QuadLinkSwingUpFH_SquaredContextFeatures_TimeDependentPolicy_EpisodicPiREPS/numSamples_201504201531_01/eval001/trial001/trial.mat')
%load('/home/vgomez/policysearchtoolbox/+Experiments/data/test/QuadLinkSwingUpFH_SquaredContextFeatures_TimeDependentPolicy_EpisodicPiREPS/numSamples_201504201531_01/eval001/trial001/trial.mat')
%load('/home/vgomez/policysearchtoolbox/+Experiments/data/test/DoubleLinkSwingUpFH_SquaredContextFeatures_SquaredFeatures_TimeDependentPolicy_EpisodicPiREPS/numSamples_201504271839_01/eval003/trial001/trial.mat')
load('/home/vgomez/policysearchtoolbox/+Experiments/data/test/DoubleLinkSwingUpFH_SquaredContextFeatures_SquaredFeatures_TimeDependentPolicy_EpisodicPiREPS/numSamples_201505081756_01/eval001/trial002/trial.mat')

jointPos = trial.data.steps(1).states(:,1:2:end);  % (every 2nd due to position velocity coding)
trial.transitionFunction.animate(jointPos)
Plotter.plot2svg('animation4Link1', gcf);

%load('/home/neumann/svn_projects/policysearchtoolbox/+Experiments/data/test/QuadLinkSwingUpFH_EpisodicPiREPS/numSamples_201401281959_01/eval001/trial001/trial.mat')
%trial.transitionFunction.animate(trial.data.getDataEntry('states', 5, 1:35))
trial.transitionFunction.animate(trial.data.contexts)
Plotter.plot2svg('animation4Link1', gcf);

trial.transitionFunction.animate(trial.data.getDataEntry('states', 5, 35:65))
Plotter.plot2svg('animation4Link2', gcf);


