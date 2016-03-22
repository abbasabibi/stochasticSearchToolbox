clear variables;
close all;

%% EntropyBeta
%load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPS/numSamples_201405180027_02/experiment.mat')
%load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPS/numSamples_201405182303_01/experiment.mat')
%load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPSWithNoiseProjMatsNewTaskSetupMaxSamples/numSamples_201405292023_01/experiment.mat')
%load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPSWithNoiseNewTaskSetupBayesProjMatrix/numSamples_201405292323_01/experiment.mat')
%load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPSWithNoiseNewTaskSetupBayesParameterSigma/numSamples_201405292316_01/experiment.mat')
%load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPSWithNoiseNewTaskSetupBayesNoiseSigma/numSamples_201405292319_01/experiment.mat')
%load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPSWithNoiseNewTaskSetupNumPara/numSamples_201405292236_01/experiment.mat')

dataClosedFormREPSBeta= obj.getTrialData({'avgReturn'});

[plotDataClosedFormREPSBeta ] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSBeta, 'iterations', 'avgReturn', 'settings.entropyBeta', ...
    @(x_) sprintf('EntropyBeta = %1.3f', x_), 'ClosedFormREPSBeta', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataClosedFormREPSBeta);
%% Entropy Reps New setup with noise and fading diffrent init sigma
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_EntropyREPSEEntropyBetaWithNoiseNewSetupFading/numSamples_201405301931_01/experiment.mat')
dataClosedFormREPSNoiseSigma= obj.getTrialData({'avgReturn'});

[plotDataClosedFormREPSNoiseSigma] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSNoiseSigma, 'iterations', 'avgReturn', 'settings.initSigmaParameters', ...
    @(x_) sprintf('NoiseSigma = %1.3f', x_), 'ClosedFormREPSNoiseSigma', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataClosedFormREPSNoiseSigma);
%% Entropy Reps New setup without noise and fading diffrent init sigma
%load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_EntropyREPSEEntropyBetaWithOutNoiseNewSetupFading/numSamples_201405301809_01/experiment.mat')
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_EntropyREPSEEntropyBetaWithoutNoiseNewSetup/numSamples_201405301731_01/experiment.mat')

dataClosedFormREPSNoiseSigma= obj.getTrialData({'avgReturn'});

[plotDataClosedFormREPSNoiseSigma] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSNoiseSigma, 'iterations', 'avgReturn', 'settings.entropyBeta', ...
    @(x_) sprintf('NoiseSigma = %1.3f', x_), 'ClosedFormREPSNoiseSigma', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataClosedFormREPSNoiseSigma);
%% power new setup with noise
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_powerTempertureWithNoiseNewSetup/numSamples_201405301919_01/experiment.mat')
dataClosedFormREPSNoiseSigma= obj.getTrialData({'avgReturn'});

[plotDataClosedFormREPSNoiseSigma] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSNoiseSigma, 'iterations', 'avgReturn', 'settings.bayesParametersSigma', ...
    @(x_) sprintf('NoiseSigma = %1.3f', x_), 'ClosedFormREPSNoiseSigma', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataClosedFormREPSNoiseSigma);
%% BO sucks
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_BOWithoutNoise/numSamples_201405280026_01/experiment.mat')
dataClosedFormREPSNoiseSigma= obj.getTrialData({'avgReturn'});

[plotDataClosedFormREPSNoiseSigma] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSNoiseSigma, 'iterations', 'avgReturn', 'settings.bayesParametersSigma', ...
    @(x_) sprintf('NoiseSigma = %1.3f', x_), 'ClosedFormREPSNoiseSigma', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataClosedFormREPSNoiseSigma);
%% bayes noise sigma new setup with noise
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPSWithNoiseNewTaskSetupBayesParameterSigma/numSamples_201405292316_01/experiment.mat')


dataClosedFormREPSNoiseSigma= obj.getTrialData({'avgReturn'});

[plotDataClosedFormREPSNoiseSigma] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSNoiseSigma, 'iterations', 'avgReturn', 'settings.bayesParametersSigma', ...
    @(x_) sprintf('NoiseSigma = %1.3f', x_), 'ClosedFormREPSNoiseSigma', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataClosedFormREPSNoiseSigma);


%% ClosedForm HighDim
%Nes
% load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_NESWithNoiseNewTaskSetupHighDim/numSamples_201405292327_01/experiment.mat')
%closeformreps
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPSWithNoiseHighDim/numSamples_201405292331_01/experiment.mat')
%CMA
%load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_CMAwithoutNoiseNewTaskSetupHighDim/numSamples_201405292329_01/experiment.mat')
dataClosedFormREPSEpsilonAction= obj.getTrialData({'avgReturn'});

[plotDataClosedFormREPSEpsilonAction] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSEpsilonAction, 'iterations', 'avgReturn', 'settings.epsilonAction', ...
    @(x_) sprintf('EpsilonAction = %1.3f', x_), 'ClosedFormREPSEpsilonAction', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataClosedFormREPSEpsilonAction);
%% closedform new setup 200 samples epsilon action
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPSWithNoiseNewTaskSetup200Samples10000ProjMatEpsilonAction/numSamples_201405292223_01/experiment.mat')
dataClosedFormREPSEpsilonAction= obj.getTrialData({'avgReturn'});

[plotDataClosedFormREPSEpsilonAction] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSEpsilonAction, 'iterations', 'avgReturn', 'settings.epsilonAction', ...
    @(x_) sprintf('EpsilonAction = %1.3f', x_), 'ClosedFormREPSEpsilonAction', true, [], []);
Plotter.PlotterEvaluations.plotData(plotDataClosedFormREPSEpsilonAction);
%% closed form newsetup projmat
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPSWithNoiseProjMatsNewTaskSetup/numSamples_201405291947_01/experiment.mat')

dataClosedFormREPSMaxSamples= obj.getTrialData({'avgReturn'});

[plotDataClosedFormREPSProjMat] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSMaxSamples, 'iterations', 'avgReturn','settings.numProjMat', ...
    @(x_) sprintf('MaxSamples = %1.3f', x_), 'ClosedFormREPSMaxSamples', true, [], []);
Plotter.PlotterEvaluations.plotData(plotDataClosedFormREPSProjMat);
%% closedform newsetup max samples
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPSWithNoiseProjMatsNewTaskSetupMaxSamples/numSamples_201405292023_01/experiment.mat')
dataClosedFormREPSMaxSamples= obj.getTrialData({'avgReturn'});

[plotDataClosedFormREPSMaxSamples] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSMaxSamples, 'iterations', 'avgReturn','settings.maxSamples', ...
    @(x_) sprintf('MaxSamples = %1.3f', x_), 'ClosedFormREPSMaxSamples', true, [1], []);
Plotter.PlotterEvaluations.plotData(plotDataClosedFormREPSMaxSamples);
%% NES new Setup
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_NESWithNoiseNewTaskSetup/numSamples_201405291913_01/experiment.mat')
dataClosedFormREPSBeta= obj.getTrialData({'avgReturn'});

[plotDataClosedFormREPSBetaNES ] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSBeta, 'iterations', 'avgReturn', 'settings.entropyBeta', ...
    @(x_) sprintf('EntropyBeta = %1.3f', x_), 'ClosedFormREPSBeta', true, [], []);
Plotter.PlotterEvaluations.plotData(plotDataClosedFormREPSBetaNES);

%% ClosedFormNew Setup
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPSWithNoiseProjMatsNewTaskSetup1000proj/numSamples_201405291953_01/experiment.mat')
%load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPSWithNoiseNewTaskSetup/numSamples_201405291923_01/experiment.mat')

dataClosedFormREPSBeta= obj.getTrialData({'avgReturn'});

[plotDataClosedFormREPSBeta5000 ] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSBeta, 'iterations', 'avgReturn', 'settings.entropyBeta', ...
    @(x_) sprintf('EntropyBeta = %1.3f', x_), 'ClosedFormREPSBeta', true, [], []);
Plotter.PlotterEvaluations.plotData(plotDataClosedFormREPSBeta5000);
%% CMA newSetup
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_CMAwithNoiseNewTaskSetup/numSamples_201405291914_01/experiment.mat')
dataClosedFormREPSBeta= obj.getTrialData({'avgReturn'});

[plotDataClosedFormREPSBetaCMA ] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSBeta, 'iterations', 'avgReturn', 'settings.entropyBeta', ...
    @(x_) sprintf('EntropyBeta = %1.3f', x_), 'ClosedFormREPSBeta', true, [], []);
Plotter.PlotterEvaluations.plotData(plotDataClosedFormREPSBetaCMA);

%% CMA and ModelBasedReps, NES new setup
algComparison = Plotter.PlotterEvaluations.mergePlots(plotDataClosedFormREPSBetaNES, [1], plotDataClosedFormREPSEpsilonAction, [2], 'test');
algComparison = Plotter.PlotterEvaluations.mergePlots(algComparison, [1 2], plotDataClosedFormREPSBetaCMA, [1], 'AlgorithmComparison', true);
% algComparison = Plotter.PlotterEvaluations.mergePlots(algComparison, [1 2 3], plotDataClosedFormREPSBeta5000 , [1], 'AlgorithmComparison', true);
% algComparison = Plotter.PlotterEvaluations.mergePlots(algComparison, [1 2 3 4], plotDataClosedFormREPSMaxSamples, [1], 'AlgorithmComparison', true);
% algComparison = Plotter.PlotterEvaluations.mergePlots(algComparison, [1 2 3 4 5], plotDataClosedFormREPSProjMat, [1], 'AlgorithmComparison', true);


algComparison.evaluationLabels{1} = 'NES';
algComparison.evaluationLabels{2} = 'ModelBasedReps';
algComparison.evaluationLabels{3} = 'CMA';
% algComparison.evaluationLabels{4} = 'ModelBasedReps5000';
% algComparison.evaluationLabels{5} = 'ModelBased200Samples';
% algComparison.evaluationLabels{6} = 'ModelBased10000';

Plotter.PlotterEvaluations.plotData(algComparison);
Plotter.plot2svg('CMAClosedFormRepsStandardRepsPower.svg', gcf);

%% EntropyBetaMorethan2.5
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPSBetaWithNoisemorethan2.5/numSamples_201405271305_01/experiment.mat')
dataClosedFormREPSBeta= obj.getTrialData({'avgReturn'});

[plotDataClosedFormREPSBeta ] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSBeta, 'iterations', 'avgReturn', 'settings.entropyBeta', ...
    @(x_) sprintf('EntropyBeta = %1.3f', x_), 'ClosedFormREPSBeta', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataClosedFormREPSBeta);
%% EntropyBeta with noise fading
%load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPSWithnoiseandfadingentropybeta/numSamples_201405280040_01/experiment.mat')
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPSWithNoiseFadingDiffrentEntropybeta30-120/numSamples_201405281943_01/experiment.mat')

dataClosedFormREPSBeta= obj.getTrialData({'avgReturn'});

[plotDataClosedFormREPSBetafadingwithnoise ] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSBeta, 'iterations', 'avgReturn', 'settings.entropyBeta', ...
    @(x_) sprintf('EntropyBeta = %1.3f', x_), 'ClosedFormREPSBeta', true, [], []);
Plotter.PlotterEvaluations.plotData(plotDataClosedFormREPSBetafadingwithnoise);
%% EntropyBeta withOut noise fading
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPSWithOutNoiseFadingDiffrentEntropybeta30-120/numSamples_201405281941_01/experiment.mat')
%load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPSWithOutnoiseFadingEntropybeta/numSamples_201405280042_01/experiment.mat')
dataClosedFormREPSBeta= obj.getTrialData({'avgReturn'});

[plotDataClosedFormREPSBetafading ] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSBeta, 'iterations', 'avgReturn', 'settings.entropyBeta', ...
    @(x_) sprintf('EntropyBeta = %1.3f', x_), 'ClosedFormREPSBeta', true, [], []);
Plotter.PlotterEvaluations.plotData(plotDataClosedFormREPSBetafading);
%% BayesNoiseSigma
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPSBayesNoiseSigma/numSamples_201405182301_01/experiment.mat')
%load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPSBayesNoiseSigma/numSamples_201405180044_01/experiment.mat')
dataClosedFormREPSNoiseSigma= obj.getTrialData({'avgReturn'});

[plotDataClosedFormREPSNoiseSigma] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSNoiseSigma, 'iterations', 'avgReturn', 'settings.bayesNoiseSigma', ...
    @(x_) sprintf('NoiseSigma = %1.3f', x_), 'ClosedFormREPSNoiseSigma', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataClosedFormREPSNoiseSigma);
%% CmA with diffrent noises
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_CMAwithDiffrentnoises/numSamples_201405271159_01/experiment.mat')
dataClosedFormREPSNoiseSigma= obj.getTrialData({'avgReturn'});

[plotDataClosedFormREPSNoiseSigma] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSNoiseSigma, 'iterations', 'avgReturn', 'settings.viaPointNoise', ...
    @(x_) sprintf('viaPointNoise = %1.3f', x_), 'ClosedFormREPSNoiseSigma', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataClosedFormREPSNoiseSigma);
%% NES with diffrent noises
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_NESdiffrentNoise/numSamples_201405272004_01/experiment.mat')
dataClosedFormREPSNoiseSigma= obj.getTrialData({'avgReturn'});

[plotDataClosedFormREPSNoiseSigma] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSNoiseSigma, 'iterations', 'avgReturn', 'settings.viaPointNoise', ...
    @(x_) sprintf('viaPointNoise = %1.3f', x_), 'ClosedFormREPSNoiseSigma', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataClosedFormREPSNoiseSigma);
%% closed form beta 2.5 diffrent sigma parameters
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPSBetaWithNoiseEntropYBeta2.5DiffrentSigmaParameter/numSamples_201405241723_01/experiment.mat')
dataClosedFormREPSInitSigma= obj.getTrialData({'avgReturn'});

[plotDataClosedFormREPSInitSigma] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSInitSigma, 'iterations', 'avgReturn', 'settings.bayesParametersSigma', ...
    @(x_) sprintf('InitSigma = %1.3f', x_), 'ClosedFormREPSInitSigma', true, [], []);
Plotter.PlotterEvaluations.plotData(plotDataClosedFormREPSInitSigma);
%% closed form pca diffrent num parameters
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPSNumParaPCA/numSamples_201405241729_01/experiment.mat')
dataClosedFormREPSParameterSigmaNumPara= obj.getTrialData({'avgReturn'});

[plotDataClosedFormREPSParameterSigmaNumPara] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSParameterSigmaNumPara, 'iterations', 'avgReturn', 'settings.numPara', ...
    @(x_) sprintf('Sigma0 = %1.3f', x_), 'ClosedFormREPSParameterSigmaNumPara', false, [], []);
%Plotter.PlotterEvaluations.plotData(plotDataClosedFormREPSParameterSigmaNumPara);
MeanData = plotDataClosedFormREPSParameterSigmaNumPara.meansYData(1:11 , :)
meandata = mean(MeanData,2)
stdYmean = plotDataClosedFormREPSParameterSigmaNumPara.stdsYData(1:11,:,:)
meanstdYmin = mean(stdYmean(:,1,:),3);
meanstdYmax = mean(stdYmean(:,2,:),3);


a=Plotter.shadedErrorBar([1:11]',meandata,meanstdYmin',{'-b','markerfacecolor',[1,0.2,0.2]},1); hold all;

%% closed form bayesian diffrent num parameters
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPSNumParaBayesianProj/numSamples_201405250037_01/experiment.mat')
dataClosedFormREPSParameterSigmaNumPara= obj.getTrialData({'avgReturn'});

[plotDataClosedFormREPSParameterSigmaNumPara] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSParameterSigmaNumPara, 'iterations', 'avgReturn', 'settings.numPara', ...
    @(x_) sprintf('Sigma0 = %1.3f', x_), 'ClosedFormREPSParameterSigmaNumPara', false, [], []);
%Plotter.PlotterEvaluations.plotData(plotDataClosedFormREPSParameterSigmaNumPara);

MeanData = plotDataClosedFormREPSParameterSigmaNumPara.meansYData(1:11,:)
meandata = mean(MeanData,2);
stdYmean = plotDataClosedFormREPSParameterSigmaNumPara.stdsYData(1:11,:,:)
meanstdYmin = mean(stdYmean(:,1,:),3)
meanstdYmax = mean(stdYmean(:,2,:),3)
b =Plotter.shadedErrorBar([1:11]',meandata,meanstdYmin',{'-r','markerfacecolor',[1,0.2,0.2]},1)

%legend(a.mainLine,b.mainLine,4)
%% Cross Product numPara and  ParameterSigma
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPScrossProductNumParaParameterSigma/numSamples_201405182304_01/experiment.mat')
%load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPScrossProductNumParaParameterSigma/numSamples_201405180037_02/experiment.mat')
dataClosedFormREPSParameterSigmaNumPara= obj.getTrialData({'avgReturn'});

[plotDataClosedFormREPSParameterSigmaNumPara] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSParameterSigmaNumPara, 'iterations', 'avgReturn', 'settings.bayesParametersSigma', ...
    @(x_) sprintf('Sigma0 = %1.3f', x_), 'ClosedFormREPSParameterSigmaNumPara', false, [1:3:21], []);
Plotter.PlotterEvaluations.plotData(plotDataClosedFormREPSParameterSigmaNumPara);

[plotDataClosedFormREPSParameterSigmaNumPara] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSParameterSigmaNumPara, 'iterations', 'avgReturn', 'settings.bayesParametersSigma', ...
    @(x_) sprintf('Sigma0 = %1.3f', x_), 'ClosedFormREPSParameterSigmaNumPara', false, [2:3:21], []);
Plotter.PlotterEvaluations.plotData(plotDataClosedFormREPSParameterSigmaNumPara);


[plotDataClosedFormREPSParameterSigmaNumPara] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSParameterSigmaNumPara, 'iterations', 'avgReturn', 'settings.bayesParametersSigma', ...
    @(x_) sprintf('Sigma0 = %1.3f', x_), 'ClosedFormREPSParameterSigmaNumPara', false, [3:3:21], []);
Plotter.PlotterEvaluations.plotData(plotDataClosedFormREPSParameterSigmaNumPara);
%% fading discount
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPSWithNoiseFadingEntropybetaDiffrentdiscount/numSamples_201405281228_01/experiment.mat')
dataClosedFormREPSEpsilonAction= obj.getTrialData({'avgReturn'});

[plotDataClosedFormREPSEpsilonAction] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSEpsilonAction, 'iterations', 'avgReturn', 'settings.epsilonAction', ...
    @(x_) sprintf('EpsilonAction = %1.3f', x_), 'ClosedFormREPSEpsilonAction', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataClosedFormREPSEpsilonAction);
%% Epsilon Action
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPSEpsilonAction/numSamples_201405182308_01/experiment.mat')
%load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPSEpsilonAction/numSamples_201405180035_01/experiment.mat')
dataClosedFormREPSEpsilonAction= obj.getTrialData({'avgReturn'});

[plotDataClosedFormREPSEpsilonAction] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSEpsilonAction, 'iterations', 'avgReturn', 'settings.epsilonAction', ...
    @(x_) sprintf('EpsilonAction = %1.3f', x_), 'ClosedFormREPSEpsilonAction', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataClosedFormREPSEpsilonAction);
%% Init Sigma
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPSInitSigma/numSamples_201405182309_01/experiment.mat')
%load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPSInitSigma/numSamples_201405180034_01/experiment.mat')
dataClosedFormREPSInitSigma= obj.getTrialData({'avgReturn'});

[plotDataClosedFormREPSInitSigma] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSInitSigma, 'iterations', 'avgReturn', 'settings.initSigmaParameters', ...
    @(x_) sprintf('InitSigma = %1.3f', x_), 'ClosedFormREPSInitSigma', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataClosedFormREPSInitSigma);
%% Max Samples
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPSMaxSAmple/numSamples_201405182311_01/experiment.mat')

%load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPSMaxSAmple/numSamples_201405180046_01/experiment.mat')
dataClosedFormREPSMaxSamples= obj.getTrialData({'avgReturn'});

[plotDataClosedFormREPSMaxSamples] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSMaxSamples, 'iterations', 'avgReturn','settings.maxSamples', ...
    @(x_) sprintf('MaxSamples = %1.3f', x_), 'ClosedFormREPSMaxSamples', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataClosedFormREPSMaxSamples);

%% BayesNoiseSigmaWithNoise
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPSBayesNoiseSigmaWithNoise/numSamples_201405202252_01/experiment.mat')
dataClosedFormREPSNoiseSigma= obj.getTrialData({'avgReturn'});

[plotDataClosedFormREPSNoiseSigmaWithNoise] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSNoiseSigma, 'iterations', 'avgReturn', 'settings.bayesNoiseSigma', ...
    @(x_) sprintf('NoiseSigma = %1.3f', x_), 'ClosedFormREPSNoiseSigma', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataClosedFormREPSNoiseSigmaWithNoise);
%% EntropyBetaWithNoise
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPSBetaWithNoise/numSamples_201405202254_01/experiment.mat')
dataClosedFormREPSBeta= obj.getTrialData({'avgReturn'});

[plotDataClosedFormREPSBetaWithNoise ] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSBeta, 'iterations', 'avgReturn', 'settings.entropyBeta', ...
    @(x_) sprintf('EntropyBeta = %1.3f', x_), 'ClosedFormREPSBeta', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataClosedFormREPSBetaWithNoise);
%% Epsilon Action With Noise
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPSEpsilonActionWithNoise/numSamples_201405202255_01/experiment.mat')
dataClosedFormREPSEpsilonAction= obj.getTrialData({'avgReturn'});

[plotDataClosedFormREPSEpsilonActionWithNoise] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSEpsilonAction, 'iterations', 'avgReturn', 'settings.epsilonAction', ...
    @(x_) sprintf('EpsilonAction = %1.3f', x_), 'ClosedFormREPSEpsilonAction', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataClosedFormREPSEpsilonActionWithNoise);
%% Max Samples With Noise
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPSMaxSAmpleWithNoise/numSamples_201405182313_01/experiment.mat')
%load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPSMaxSAmpleWithNoise/numSamples_201405180053_01/experiment.mat')
dataClosedFormREPSMaxSamplesWithNoise= obj.getTrialData({'avgReturn'});

[plotDataClosedFormREPSMaxSamplesWithNoise] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSMaxSamplesWithNoise, 'iterations', 'avgReturn','settings.maxSamples', ...
    @(x_) sprintf('MaxSamples = %1.3f', x_), 'ClosedFormREPSMaxSamplesWithNoise', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataClosedFormREPSMaxSamplesWithNoise);
%% ClosedFromInitSigmaWithNoise
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPSInitSigmaWithNoise/numSamples_201405202256_01/experiment.mat')
dataClosedFormREPSInitSigma= obj.getTrialData({'avgReturn'});

[plotDataClosedFormREPSInitSigmaWithNoise] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSInitSigma, 'iterations', 'avgReturn', 'settings.initSigmaParameters', ...
    @(x_) sprintf('InitSigma = %1.3f', x_), 'ClosedFormREPSInitSigma', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataClosedFormREPSInitSigmaWithNoise);
%% ClosedFormWithNoiseTheBest
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPSBetaWithNoiseEntropYBeta2.5/numSamples_201405211517_01/experiment.mat')
dataClosedFormREPS= obj.getTrialData({'avgReturn'});

[plotDataClosedFormREPSbest] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPS, 'iterations', 'avgReturn', 'settings.initSigmaParameters', ...
    @(x_) sprintf('InitSigma = %1.3f', x_), 'ClosedFormREPSInitSigma', true, [], []);
Plotter.PlotterEvaluations.plotData(plotDataClosedFormREPSbest);
%% ClosedFormWithNoisePCA
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPSBetaWithNoiseEntropYBeta2.5PCA/numSamples_201405232250_01/experiment.mat')
dataClosedFormREPS= obj.getTrialData({'avgReturn'});

[plotDataClosedFormREPSbestPCA] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPS, 'iterations', 'avgReturn', 'settings.initSigmaParameters', ...
    @(x_) sprintf('InitSigma = %1.3f', x_), 'ClosedFormREPSInitSigma', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataClosedFormREPSbestPCA);


%% ClosedFormWithNoiseBestProjMat
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPSBetaWithNoiseEntropYBeta2.5BestProj/numSamples_201405232253_01/experiment.mat')
dataClosedFormREPS= obj.getTrialData({'avgReturn'});

[plotDataClosedFormREPSbestBestProj] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPS, 'iterations', 'avgReturn', 'settings.initSigmaParameters', ...
    @(x_) sprintf('InitSigma = %1.3f', x_), 'ClosedFormREPSInitSigma', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataClosedFormREPSbestBestProj);
%% PCA, Bayesian Projection, Best Projection
algComparison = Plotter.PlotterEvaluations.mergePlots(plotDataClosedFormREPSbest,[1], plotDataClosedFormREPSbestPCA, [1], 'test');
algComparison = Plotter.PlotterEvaluations.mergePlots(algComparison, [1 2], plotDataClosedFormREPSbestBestProj, [1], 'AlgorithmComparison', true);
%algComparison = Plotter.PlotterEvaluations.mergePlots(algComparison, [1 2 3], plotDataPowerOpenLoop, [1], 'AlgorithmComparison', true);

algComparison.evaluationLabels{1} = 'BayesianProj';
algComparison.evaluationLabels{2} = 'PCAProjection';
algComparison.evaluationLabels{3} = 'BestProjection';
%algComparison.evaluationLabels{4} = 'Open Loop PI2';

Plotter.PlotterEvaluations.plotData(algComparison);
%Plotter.plot2svg('CMAModelBasedRepsWithNoiseLog.svg', gcf);

%% ClosedFormWithoutNoisePCA
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPSBetaWithNoiseEntropYBeta2.5/numSamples_201405211517_01/experiment.mat')
dataClosedFormREPS= obj.getTrialData({'avgReturn'});

[plotDataClosedFormREPSbest] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPS, 'iterations', 'avgReturn', 'settings.initSigmaParameters', ...
    @(x_) sprintf('InitSigma = %1.3f', x_), 'ClosedFormREPSInitSigma', true, [], []);
Plotter.PlotterEvaluations.plotData(plotDataClosedFormREPSbest);


%% ClosedFormWithoutNoiseBestProjMat
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPSBetaWithNoiseEntropYBeta2.5/numSamples_201405211517_01/experiment.mat')
dataClosedFormREPS= obj.getTrialData({'avgReturn'});

[plotDataClosedFormREPSbest] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPS, 'iterations', 'avgReturn', 'settings.initSigmaParameters', ...
    @(x_) sprintf('InitSigma = %1.3f', x_), 'ClosedFormREPSInitSigma', true, [], []);
Plotter.PlotterEvaluations.plotData(plotDataClosedFormREPSbest);
%% Cross Product numPara and  ParameterSigma with noise
% load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPScrossProductNumParaParameterSigmaWithNoise/numSamples_201405180049_01/experiment.mat')
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPScrossProductNumParaParameterSigmaWithNoise/numSamples_201405182314_01/experiment.mat')
dataClosedFormREPSParameterSigmaNumParaWithNoise= obj.getTrialData({'avgReturn'});

[plotDataClosedFormREPSParameterSigmaNumParaWithNoise] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSParameterSigmaNumParaWithNoise, 'iterations', 'avgReturn', 'settings.numPara', ...
    @(x_) sprintf('Sigma0 = %1.3f', x_), 'ClosedFormREPSParameterSigmaNumParaWithNoise', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataClosedFormREPSParameterSigmaNumParaWithNoise);

%% CMA Init Sigma Without Noise
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_CMAwithoutnoise/numSamples_201405192258_01/experiment.mat')
%load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_CMAwithoutnoise/numSamples_201405171823_01/experiment.mat')
dataCMAInitSigma= obj.getTrialData({'avgReturn'});

[plotDataCMAInitSigma] = Plotter.PlotterEvaluations.preparePlotData(dataCMAInitSigma, 'iterations', 'avgReturn', 'settings.initSigmaParameters', ...
    @(x_) sprintf('InitSigma = %1.3f', x_), 'CMAInitSigma', true, [], []);
Plotter.PlotterEvaluations.plotData(plotDataCMAInitSigma);
%% closed form with diffrent noise
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPSBetaWithDiffrentNoiseEntropYBeta2.5/numSamples_201405261412_01/experiment.mat')
dataClosedFormREPSNoiseSigma= obj.getTrialData({'avgReturn'});

[plotDataClosedFormREPSNoiseSigma] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSNoiseSigma, 'iterations', 'avgReturn', 'settings.viaPointNoise', ...
    @(x_) sprintf('viaPointNoise = %1.3f', x_), 'ClosedFormREPSNoiseSigma', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataClosedFormREPSNoiseSigma);
%% CMA Init Sigma With Noise
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_CMAActuallywithnoise/numSamples_201405192259_01/experiment.mat')
%load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_CMAwithnoise/numSamples_201405172054_01/experiment.mat')
dataCMAInitSigma= obj.getTrialData({'avgReturn'});

[plotDataCMAInitSigmaWithNoise] = Plotter.PlotterEvaluations.preparePlotData(dataCMAInitSigma, 'iterations', 'avgReturn', 'settings.initSigmaParameters', ...
    @(x_) sprintf('InitSigma = %1.3f', x_), 'CMAInitSigma', true, [], []);
Plotter.PlotterEvaluations.plotData(plotDataCMAInitSigmaWithNoise);

%% Standard Reps Init Sigma Without Noise
%load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_StandardREPSInitSigma/numSamples_201405202301_01/experiment.mat')
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_StandardREPSInitSigmaWithoutNoise/numSamples_201405232308_01/experiment.mat')
dataRepsInitSigma= obj.getTrialData({'avgReturn'});

[plotDataRepsInitSigmaWithOutNoise] = Plotter.PlotterEvaluations.preparePlotData(dataRepsInitSigma, 'iterations', 'avgReturn', 'settings.initSigmaParameters', ...
    @(x_) sprintf('InitSigma = %1.3f', x_), 'RepsInitSigma', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataRepsInitSigmaWithOutNoise);

%% Standard Reps Max Sample
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_StandardREPSMaxSamples/numSamples_201405211359_01/experiment.mat')
dataStandardREPSMaxSamples= obj.getTrialData({'avgReturn'});

[plotStandardREPSMaxSamples] = Plotter.PlotterEvaluations.preparePlotData(dataStandardREPSMaxSamples, 'iterations', 'avgReturn','settings.maxSamples', ...
    @(x_) sprintf('MaxSamples = %1.3f', x_), 'ClosedFormREPSMaxSamples', false, [], []);
Plotter.PlotterEvaluations.plotData(plotStandardREPSMaxSamples);

%% Standard Reps Max Sample more than 500
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_StandardREPSMaxSampleswithoutNoiseMorethan500/numSamples_201405261349_01/experiment.mat')
dataStandardREPSMaxSamples= obj.getTrialData({'avgReturn'});

[plotStandardREPSMaxSamplesMoreThan500] = Plotter.PlotterEvaluations.preparePlotData(dataStandardREPSMaxSamples, 'iterations', 'avgReturn','settings.maxSamples', ...
    @(x_) sprintf('MaxSamples = %1.3f', x_), 'ClosedFormREPSMaxSamples', true, [], []);
Plotter.PlotterEvaluations.plotData(plotStandardREPSMaxSamplesMoreThan500);
%% Standard Reps Max Sample more than 200
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_StandardREPSMaxSampleswithoutNoiseMorethan200/numSamples_201405251737_01/experiment.mat')

dataStandardREPSMaxSamples= obj.getTrialData({'avgReturn'});

[plotStandardREPSMaxSamples] = Plotter.PlotterEvaluations.preparePlotData(dataStandardREPSMaxSamples, 'iterations', 'avgReturn','settings.maxSamples', ...
    @(x_) sprintf('MaxSamples = %1.3f', x_), 'ClosedFormREPSMaxSamples', false, [], []);
Plotter.PlotterEvaluations.plotData(plotStandardREPSMaxSamples);
%% Standard Reps Max Sample with Noise
%load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_StandardREPSMaxSamples/numSamples_201405211359_01/experiment.mat')
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_StandardREPSMaxSampleswithNoise/numSamples_201405232307_01/experiment.mat')
dataStandardREPSMaxSamples= obj.getTrialData({'avgReturn'});

[plotStandardREPSMaxSamples] = Plotter.PlotterEvaluations.preparePlotData(dataStandardREPSMaxSamples, 'iterations', 'avgReturn','settings.maxSamples', ...
    @(x_) sprintf('MaxSamples = %1.3f', x_), 'ClosedFormREPSMaxSamples', false, [], []);
Plotter.PlotterEvaluations.plotData(plotStandardREPSMaxSamples);
%% Epsilon Action Standard Reps Without Noise
%load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_StandardREPSEpsilonActionWithoutNoise/numSamples_201405211528_01/experiment.mat')
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_StandardREPSEpsilonActionWithOutNoise/numSamples_201405232306_01/experiment.mat')
dataStandardRepsREPSEpsilonAction= obj.getTrialData({'avgReturn'});

[plotDataStandardREPSEpsilonActionWithOutNoise] = Plotter.PlotterEvaluations.preparePlotData(dataStandardRepsREPSEpsilonAction, 'iterations', 'avgReturn', 'settings.epsilonAction', ...
    @(x_) sprintf('EpsilonAction = %1.3f', x_), 'ClosedFormREPSEpsilonAction', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataStandardREPSEpsilonActionWithOutNoise);
%% Epsilon Action less than 0.5 Standard Reps Without Noise
%load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_StandardREPSEpsilonActionWithoutNoise/numSamples_201405211528_01/experiment.mat')
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_StandardREPSEpsilonActionlessthan0.5WithOutNoise/numSamples_201405251735_02/experiment.mat')
dataStandardRepsREPSEpsilonAction= obj.getTrialData({'avgReturn'});

[plotDataStandardREPSEpsilonActionWithOutNoise] = Plotter.PlotterEvaluations.preparePlotData(dataStandardRepsREPSEpsilonAction, 'iterations', 'avgReturn', 'settings.epsilonAction', ...
    @(x_) sprintf('EpsilonAction = %1.3f', x_), 'ClosedFormREPSEpsilonAction', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataStandardREPSEpsilonActionWithOutNoise);

%% Ness With Noise mean learn rate
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_NESMeanLearnRateWithNoise/numSamples_201405262245_01/experiment.mat')
dataRepsInitSigma= obj.getTrialData({'avgReturn'});
% fault.setDefaultParameter('settings.learnRateNESMeans', 1);
% default.setDefaultParameter('settings.learnRateNESSigmas', 0.02);
% dataRepsInitSigma= obj.getTrialData({'avgReturn'});

[plotDataNESMeanRateaWithNoise] = Plotter.PlotterEvaluations.preparePlotData(dataRepsInitSigma, 'iterations', 'avgReturn', 'settings.learnRateNESMeans', ...
    @(x_) sprintf('InitSigma = %1.3f', x_), 'RepsInitSigma', true, [], []);
Plotter.PlotterEvaluations.plotData(plotDataNESMeanRateaWithNoise);
%% Ness With Noise sigma learn rate
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_NESSigmaLearnRateWithNoise/numSamples_201405262250_01/experiment.mat')
dataRepsInitSigma= obj.getTrialData({'avgReturn'});
% fault.setDefaultParameter('settings.learnRateNESMeans', 1);
% default.setDefaultParameter('settings.learnRateNESSigmas', 0.02);
% dataRepsInitSigma= obj.getTrialData({'avgReturn'});

[plotDataNESInitSigmaWithOutNoise] = Plotter.PlotterEvaluations.preparePlotData(dataRepsInitSigma, 'iterations', 'avgReturn', 'settings.learnRateNESMeans', ...
    @(x_) sprintf('Sigma = %1.3f', x_), 'RepsInitSigma', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataNESInitSigmaWithOutNoise);
%% Ness WithOut Noise mean learn rate
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_NESMeanLearnRateWithOutNoise/numSamples_201405262241_01/experiment.mat')
dataRepsInitSigma= obj.getTrialData({'avgReturn'});
% fault.setDefaultParameter('settings.learnRateNESMeans', 1);
% default.setDefaultParameter('settings.learnRateNESSigmas', 0.02);
% dataRepsInitSigma= obj.getTrialData({'avgReturn'});

[plotDataNESMeanWithOutNoise] = Plotter.PlotterEvaluations.preparePlotData(dataRepsInitSigma, 'iterations', 'avgReturn', 'settings.learnRateNESMeans', ...
    @(x_) sprintf('InitSigma = %1.3f', x_), 'RepsInitSigma', true, [], []);
Plotter.PlotterEvaluations.plotData(plotDataNESMeanWithOutNoise);
%% Ness WithOut Noise sigma learn rate
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_NESSigmaLearnRateWithOutNoise/numSamples_201405262251_01/experiment.mat')

dataRepsInitSigma= obj.getTrialData({'avgReturn'});
% fault.setDefaultParameter('settings.learnRateNESMeans', 1);
% default.setDefaultParameter('settings.learnRateNESSigmas', 0.02);
% dataRepsInitSigma= obj.getTrialData({'avgReturn'});

[plotDataRepsInitSigmaWithOutNoise] = Plotter.PlotterEvaluations.preparePlotData(dataRepsInitSigma, 'iterations', 'avgReturn', 'settings.learnRateNESSigmas', ...
    @(x_) sprintf('Sigma = %1.3f', x_), 'RepsInitSigma', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataRepsInitSigmaWithOutNoise);

%% Standard Power Temperture Without Noise
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_powerTemperture/numSamples_201405202304_01/experiment.mat')
dataPowerTemperture= obj.getTrialData({'avgReturn'});

[plotDataPowerTempertureWithOutNoise] = Plotter.PlotterEvaluations.preparePlotData(dataPowerTemperture, 'iterations', 'avgReturn', 'settings.temperatureScalingPower', ...
    @(x_) sprintf('InitSigma = %1.3f', x_), 'PowerTemperture', true, [], []);
Plotter.PlotterEvaluations.plotData(plotDataPowerTempertureWithOutNoise);
%% Standard Power Temperture With Noise
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_powerTempertureWithNoise/numSamples_201405212240_01/experiment.mat');
dataPowerTemperture= obj.getTrialData({'avgReturn'});

[plotDataPowerTempertureWithNoise] = Plotter.PlotterEvaluations.preparePlotData(dataPowerTemperture, 'iterations', 'avgReturn', 'settings.temperatureScalingPower', ...
    @(x_) sprintf('InitSigma = %1.3f', x_), 'PowerTemperture', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataPowerTempertureWithNoise);
%% CMA and ModelBasedReps, Power and Standard Reps without noise
algComparison = Plotter.PlotterEvaluations.mergePlots(plotDataCMAInitSigma, [5], plotDataClosedFormREPSBetafading, [10], 'test');
algComparison = Plotter.PlotterEvaluations.mergePlots(algComparison, [1 2], plotStandardREPSMaxSamplesMoreThan500, [7], 'AlgorithmComparison', true);
algComparison = Plotter.PlotterEvaluations.mergePlots(algComparison, [1 2 3], plotDataPowerTempertureWithOutNoise, [2], 'AlgorithmComparison', true);
algComparison = Plotter.PlotterEvaluations.mergePlots(algComparison, [1 2 3 4], plotDataNESMeanWithOutNoise, [5], 'AlgorithmComparison', true);

algComparison.evaluationLabels{1} = 'CMA';
algComparison.evaluationLabels{2} = 'ModelBasedReps';
algComparison.evaluationLabels{3} = 'Standard Reps';
algComparison.evaluationLabels{4} = 'Power';
algComparison.evaluationLabels{5} = 'NES';

Plotter.PlotterEvaluations.plotData(algComparison);
Plotter.plot2svg('CMAClosedFormRepsStandardRepsPower.svg', gcf);
%% CMA and ModelBased with noise
algComparison = Plotter.PlotterEvaluations.mergePlots(plotDataCMAInitSigmaWithNoise,[6], plotDataClosedFormREPSBetafadingwithnoise, [10], 'test');
algComparison = Plotter.PlotterEvaluations.mergePlots(algComparison, [1 2], plotDataNESMeanRateaWithNoise, [5], 'AlgorithmComparison', true);
%algComparison = Plotter.PlotterEvaluations.mergePlots(algComparison, [1 2 3], plotDataPowerOpenLoop, [1], 'AlgorithmComparison', true);

algComparison.evaluationLabels{1} = 'CMA';
algComparison.evaluationLabels{2} = 'ModelBasedReps';
algComparison.evaluationLabels{3} = 'NES';
%algComparison.evaluationLabels{4} = 'Open Loop PI2';

Plotter.PlotterEvaluations.plotData(algComparison);
Plotter.plot2svg('CMAModelBasedRepsWithNoiseLog.svg', gcf);

