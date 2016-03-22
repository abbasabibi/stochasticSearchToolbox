clear all;
close all;

%% epsilon Action


load('~/policysearchtoolbox/+Experiments/data/test/SwingUp_RBFStates_RBFProdKernelActions_LinearQ_GPPolicy_Q_RewardBased_stateActionKernel_REPS_SA/Swing-Up_201501271555_01/experiment.mat')
dataPiREPSSamples = obj.getTrialData({'rewardEval'});

[plotDataPiREPSSamples ] = Plotter.PlotterEvaluations.preparePlotData(dataPiREPSSamples, 'iterations', 'rewardEval', 'settings.epsilonAction', @(x_) sprintf('epsilon = %.0d', x_), 'Epsilon_ACREPS', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataPiREPSSamples );


%% RerferenceSet

load('~/policysearchtoolbox/+Experiments/data/test/SwingUp_RBFStates_RBFProdKernelActions_LinearQ_GPPolicy_Q_RewardBased_stateActionKernel_REPS_SA/Swing-Up_)
dataPiREPSSamples = obj.getTrialData({'rewardEval'});

[plotDataPiREPSSamples ] = Plotter.PlotterEvaluations.preparePlotData(dataPiREPSSamples, 'iterations', 'rewardEval', 'settings.maxSizeReferenceSet', @(x_) sprintf('RefSet = %.0d', x_), 'RefSet_ACREPS', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataPiREPSSamples );

%% HyperParams

load('~/policysearchtoolbox/+Experiments/data/test/SwingUp_RBFStates_RBFProdKernelActions_LinearQ_GPPolicy_Q_RewardBased_stateActionKernel_REPS_SA/Swing-Up_GPBandWidth_Test_201501281543_01/experiment.mat')
dataPiREPSSamples = obj.getTrialData({'rewardEval'});

[plotDataPiREPSSamples ] = Plotter.PlotterEvaluations.preparePlotData(dataPiREPSSamples, 'iterations', 'rewardEval', 'settings.maxNumOptiIterationsGPOptimizationActions', @(x_) sprintf('HyperParamsIter = %.0d', x_), 'RefSet_ACREPS', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataPiREPSSamples );

%% BandWidth

load('~/policysearchtoolbox/+Experiments/data/test/SwingUp_RBFStates_RBFProdKernelActions_LinearQ_GPPolicy_Q_RewardBased_stateActionKernel_REPS_SA/Swing-Up_GPBandWidth_Test_201501291151_01/experiment.mat')
dataPiREPSSamples = obj.getTrialData({'rewardEval'});

[plotDataPiREPSSamples ] = Plotter.PlotterEvaluations.preparePlotData(dataPiREPSSamples, 'iterations', 'rewardEval', 'settings.kernelMedianBandwidthFactor', @(x_) sprintf('BandWidthFactor = %.0d', x_), 'RefSet_ACREPS', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataPiREPSSamples );

% Local Points
%% MaxSamples
load('~/policysearchtoolbox/+Experiments/data/test/SwingUp_RBFStates_RBFProdKernelActions_LinearQ_GPPolicy_Q_RewardBased_stateActionKernel_REPS_SA/Swing-Up_GPBandWidth_Test_201501291939_01/experiment.mat')
dataPiREPSSamples = obj.getTrialData({'rewardEval'});

[plotDataPiREPSSamples ] = Plotter.PlotterEvaluations.preparePlotData(dataPiREPSSamples, 'iterations', 'rewardEval', 'settings.numLocalDataPoints', @(x_) sprintf('localPoints = %.0d', x_), 'RefSet_ACREPS', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataPiREPSSamples );

% Local Points
%% New hyper params
load('~/policysearchtoolbox/+Experiments/data/test/SwingUp_RBFStates_RBFProdKernelActions_LinearQ_GPPolicy_Q_RewardBased_stateActionKernel_SampleDensityPreProc_REPS_SA/Swing-Up_GPHyperParams_201502032322_01/experiment.mat')
dataPiREPSSamples = obj.getTrialData({'rewardEval', 'explorationSigma'});

[plotDataPiREPSSamples ] = Plotter.PlotterEvaluations.preparePlotData(dataPiREPSSamples, 'iterations', 'rewardEval', 'settings.numLocalDataPoints', @(x_) sprintf('localPoints = %.0d', x_), 'RefSet_ACREPS', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataPiREPSSamples );

%% New epsilon
load('~/policysearchtoolbox/+Experiments/data/test/SwingUp_RBFStates_RBFProdKernelActions_LinearQ_GPPolicy_Q_RewardBased_stateActionKernel_SampleDensityPreProc_REPS_SA/Swing-Up_GPHyperParams_201502022246_01/experiment.mat')
dataPiREPSSamples = obj.getTrialData({'rewardEval'});

[plotDataPiREPSSamples ] = Plotter.PlotterEvaluations.preparePlotData(dataPiREPSSamples, 'iterations', 'rewardEval', 'settings.numLocalDataPoints', @(x_) sprintf('localPoints = %.0d', x_), 'RefSet_ACREPS', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataPiREPSSamples );

%% New epsilon limited
load('~/policysearchtoolbox/+Experiments/data/test/SwingUp_RBFStates_RBFProdKernelActions_LinearQ_GPPolicy_Q_RewardBased_stateActionKernel_SampleDensityPreProc_REPS_SA/Swing-Up_LimitInit_201502022259_01/experiment.mat')
dataPiREPSSamples = obj.getTrialData({'rewardEval'});

[plotDataPiREPSSamples ] = Plotter.PlotterEvaluations.preparePlotData(dataPiREPSSamples, 'iterations', 'rewardEval', 'settings.numLocalDataPoints', @(x_) sprintf('localPoints = %.0d', x_), 'RefSet_ACREPS', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataPiREPSSamples );

%% Bicycle
load('~/policysearchtoolbox/+Experiments/data/testFixed/BicycleBalance_RBFStates_RBFProdKernelActions_LinearQ_GPPolicy_Q_RewardBased_stateActionKernel_SampleDensityPreProc_REPS_SA/testLowerErr_201502041755_01/experiment.mat')
dataPiREPSSamples = obj.getTrialData({'rewardEval', 'avgLengthEval', 'explorationSigma'});

[plotDataPiREPSSamples ] = Plotter.PlotterEvaluations.preparePlotData(dataPiREPSSamples, 'iterations', 'avgLengthEval', 'settings.kernelMedianBandwidthFactor', @(x_) sprintf('kernelMedianBandwidthFactor = %.0d', x_), 'RefSet_ACREPS', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataPiREPSSamples );

%% Bicycle
load('~/policysearchtoolbox/+Experiments/data/testFixed/BicycleBalance_RBFStates_RBFProdKernelActions_LinearQ_GPPolicy_Q_RewardBased_stateActionKernel_SampleDensityPreProc_REPS_SA/testLowerErr_201502041753_02/experiment.mat')
dataPiREPSSamples = obj.getTrialData({'avgLengthEval'});

[plotDataPiREPSSamples ] = Plotter.PlotterEvaluations.preparePlotData(dataPiREPSSamples, 'iterations', 'avgLengthEval', 'settings.epsilonAction', @(x_) sprintf('epsilonAction = %.0d', x_), 'RefSet_ACREPS', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataPiREPSSamples );


%% Bicycle shitty LSPI
load('~/policysearchtoolbox/+Experiments/data/test/BicycleBalance_RBFStates_LinearQ_SoftMaxPolicy_Q_RewardBased_stateKernel_SampleDensityPreProc/LSPI_Kernel_201502110122_01/experiment.mat');
dataPiREPSSamples = obj.getTrialData({'avgLengthEval'});

[plotDataPiREPSSamples ] = Plotter.PlotterEvaluations.preparePlotData(dataPiREPSSamples, 'iterations', 'avgLengthEval', 'settings.softMaxTemperature', @(x_) sprintf('epsilonAction = %.0d', x_), 'RefSet_ACREPS', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataPiREPSSamples );

%% Double Balance
load('~/policysearchtoolbox/+Experiments/data/DoubleBalancing/DoubleLinkBalancing_RBFStates_RBFProdKernelActions_LinearQ_GPPolicy_Q_RewardBased_stateActionKernel_SampleDensityPreProc_REPS_SA/Balance_201502111143_01/experiment.mat');
dataPiREPSSamples = obj.getTrialData({'rewardEval'});

[plotDataPiREPSSamples ] = Plotter.PlotterEvaluations.preparePlotData(dataPiREPSSamples, 'iterations', 'rewardEval', 'settings.kernelMedianBandwidthFactor', @(x_) sprintf('kernelMedianBandwidthFactor = %.0d', x_), 'RefSet_ACREPS', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataPiREPSSamples );

%% Quad Balance
load('~/policysearchtoolbox/+Experiments/data/testSwingUp/QuadLinkBalancing_RBFStates_RBFProdKernelActions_LinearQ_GPPolicy_Q_RewardBased_stateActionKernel_SampleDensityPreProc_REPS_SA/Swing-Up_LimitInit_201502111547_01//experiment.mat');
dataPiREPSSamples = obj.getTrialData({'rewardEval'});

[plotDataPiREPSSamples ] = Plotter.PlotterEvaluations.preparePlotData(dataPiREPSSamples, 'iterations', 'rewardEval', 'settings.kernelMedianBandwidthFactor', @(x_) sprintf('kernelMedianBandwidthFactor = %.0d', x_), 'RefSet_ACREPS', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataPiREPSSamples );



%% New Swing up
load('~/policysearchtoolbox/+Experiments/data/swingup/SwingUp_RBFStates_RBFProdKernelActions_LinearQ_GPPolicy_Q_RewardBased_stateActionKernel_SampleDensityPreProc_REPS_SA/epsilonAction_201508141716_01/experiment.mat');
dataPiREPSSamples = obj.getTrialData({'rewardEval'});

[plotDataPiREPSSamples ] = Plotter.PlotterEvaluations.preparePlotData(dataPiREPSSamples, 'iterations', 'rewardEval', 'settings.epsilonAction', @(x_) sprintf('epsilonAction= %.0d', x_), 'EpsilonAction_ACREPS', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataPiREPSSamples );

%%
load('~/policysearchtoolbox/+Experiments/data/swingup/SwingUp_RBFStates_RBFProdKernelActions_LinearQ_GPPolicy_Q_RewardBased_stateActionKernel_SampleDensityPreProc_REPS_SA/referenceSet_201508141717_01/experiment.mat');
dataPiREPSSamples = obj.getTrialData({'rewardEval'});

[plotDataPiREPSSamples ] = Plotter.PlotterEvaluations.preparePlotData(dataPiREPSSamples, 'iterations', 'rewardEval', 'settings.maxSizeReferenceSet', @(x_) sprintf('maxSizeReferenceSet= %.0d', x_), 'EpsilonAction_ACREPS', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataPiREPSSamples );

%%
load('~/policysearchtoolbox/+Experiments/data/swingup/SwingUp_RBFStates_RBFProdKernelActions_LinearQ_GPPolicy_Q_RewardBased_stateActionKernel_SampleDensityPreProc_REPS_SA/GP_bandWidth_201508141715_01/experiment.mat');
dataPiREPSSamples = obj.getTrialData({'rewardEval'});

[plotDataPiREPSSamples ] = Plotter.PlotterEvaluations.preparePlotData(dataPiREPSSamples, 'iterations', 'rewardEval', 'settings.kernelMedianBandwidthFactor', @(x_) sprintf('kernelMedianBandwidthFactor= %f', x_), 'EpsilonAction_ACREPS', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataPiREPSSamples );


