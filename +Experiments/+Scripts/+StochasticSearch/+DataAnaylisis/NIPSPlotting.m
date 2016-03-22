%*****************************WithOut Noise plots*************************
%% Closed Form WithOut Noise
%load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPSWithOutNoiseFadingDiffrentEntropybeta30-120/numSamples_201405281941_01/experiment.mat')
%load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPSWithOutnoiseFadingEntropybeta/numSamples_201405280042_01/experiment.mat')
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPSWithoutNoiseForNIPS/numSamples_201405311043_01/experiment.mat')
dataClosedFormREPSBeta= obj.getTrialData({'avgReturn'});

[plotDataClosedFormREPSBetafading ] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSBeta, 'episodes', 'avgReturn', 'settings.entropyBeta', ...
    @(x_) sprintf('EntropyBeta = %1.3f', x_), 'ClosedFormREPSBeta', true, [], []);
Plotter.PlotterEvaluations.plotData(plotDataClosedFormREPSBetafading);

%% NES WIthout Noise
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_NESMeanLearnRateWithOutNoise/numSamples_201405262241_01/experiment.mat')
dataRepsInitSigma= obj.getTrialData({'avgReturn'});

[plotDataNESMeanWithOutNoise] = Plotter.PlotterEvaluations.preparePlotData(dataRepsInitSigma, 'episodes', 'avgReturn', 'settings.learnRateNESMeans', ...
    @(x_) sprintf('InitSigma = %1.3f', x_), 'RepsInitSigma', true, [], []);
Plotter.PlotterEvaluations.plotData(plotDataNESMeanWithOutNoise);
%% Standard Reps WithOutNoise
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_RepsDiffLambda/numSamples_201405302245_01/experiment.mat')
dataClosedFormREPSBeta= obj.getTrialData({'avgReturn'}); %%5th

[plotDataStandardReps ] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSBeta, 'episodes', 'avgReturn', 'settings.priorCovWeightParameters', ...
    @(x_) sprintf('EntropyBeta = %1.3f', x_), 'ClosedFormREPSBeta', true, [], []);
Plotter.PlotterEvaluations.plotData(plotDataStandardReps);

%% CMA Without Noise
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_CMAwithoutnoise/numSamples_201405192258_01/experiment.mat')
%load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_CMAwithoutnoise/numSamples_201405171823_01/experiment.mat')
dataCMAInitSigma= obj.getTrialData({'avgReturn'});
for i = 1:length(dataCMAInitSigma)
    dataCMAInitSigma(i).parameters{end + 1} = 'settings.numSamplesEpisodes';
    dataCMAInitSigma(i).values{end + 1} = 14;
end

[plotDataCMAInitSigma] = Plotter.PlotterEvaluations.preparePlotData(dataCMAInitSigma, 'episodes', 'avgReturn', 'settings.initSigmaParameters', ...
    @(x_) sprintf('InitSigma = %1.3f', x_), 'CMAInitSigma', true, [], []);
Plotter.PlotterEvaluations.plotData(plotDataCMAInitSigma);

%% Power WithOut Noise
%load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_powerTempertureWithOutNoiseNewSetupWithPriorCov/numSamples_201405311755_01/experiment.mat')
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_powerTemperture/numSamples_201405202304_01/experiment.mat')

dataPowerTemperture= obj.getTrialData({'avgReturn'});

[plotDataPowerTempertureWithOutNoise] = Plotter.PlotterEvaluations.preparePlotData(dataPowerTemperture, 'episodes', 'avgReturn', 'settings.temperatureScalingPower', ...
    @(x_) sprintf('InitSigma = %1.3f', x_), 'PowerTemperture',true, [], []);
Plotter.PlotterEvaluations.plotData(plotDataPowerTempertureWithOutNoise);
%% Entropy Beta Without Noise
%load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_EntropyREPSEEntropyBetaWithOutNoiseNewSetupFading/numSamples_201405302230_01/experiment.mat')
 %load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_EntropyREPSEEntropyBetaWithOutNoiseNewSetupFading/numSamples_201405311149_01/experiment.mat')
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_EntropyREPSEEntropyBetaWithOutNoiseNewSetupFadingEpsilon0.5/numSamples_201405311258_01/experiment.mat')
%load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_EntropyREPSEEntropyBetaWithOutNoiseNewSetupFading/numSamples_201405311257_01/experiment.mat') 
dataPowerTemperture= obj.getTrialData({'avgReturn'});

[plotDataEntropyReps] = Plotter.PlotterEvaluations.preparePlotData(dataPowerTemperture, 'episodes', 'avgReturn', 'settings.initSigmaParameters', ...
    @(x_) sprintf('InitSigma = %1.3f', x_), 'InitSigma', true, [], []);
Plotter.PlotterEvaluations.plotData(plotDataEntropyReps);
%% CMA and ModelBasedReps, Power and Standard Reps without noise
algComparison = Plotter.PlotterEvaluations.mergePlots(plotDataClosedFormREPSBetafading, [1], plotDataNESMeanWithOutNoise, [5], 'test');
algComparison = Plotter.PlotterEvaluations.mergePlots(algComparison, [1 2 ], plotDataCMAInitSigma, [5], 'AlgorithmComparison', true);
algComparison = Plotter.PlotterEvaluations.mergePlots(algComparison, [1 2 3 ], plotDataPowerTempertureWithOutNoise, [2], 'AlgorithmComparison', true);
%algComparison = Plotter.PlotterEvaluations.mergePlots(algComparison, [1 2 3 4 ], plotDataEntropyReps, [1], 'AlgorithmComparison', true);
%algComparison = Plotter.PlotterEvaluations.mergePlots(algComparison, [1 2 3 4 5], plotDataStandardReps, [5], 'AlgorithmComparison', true);


algComparison.evaluationLabels{1} = 'ModelBasedReps';
algComparison.evaluationLabels{2} = 'NES';
algComparison.evaluationLabels{3} = 'CMA';
algComparison.evaluationLabels{4} = 'Power';
%algComparison.evaluationLabels{5} = 'EntropyReps';
%algComparison.evaluationLabels{6} = 'Standard Reps';

algComparison.plotInterval = 5;
Plotter.PlotterEvaluations.plotData(algComparison);

Plotter.plot2svg('CMAClosedFormRepsStandardRepsPowerNoNois.svg', gcf);
 %***********************  With Noise Plots************************************************
 
 
 %% Closed Form With Noise
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPSWithNoiseNewTaskSetup200Samples10000ProjMatEpsilonAction/numSamples_201405292223_01/experiment.mat')
dataClosedFormREPSEpsilonAction= obj.getTrialData({'avgReturn'});

[plotDataClosedFormREPSEpsilonActionWithNoise] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSEpsilonAction, 'episodes', 'avgReturn', 'settings.epsilonAction', ...
    @(x_) sprintf('EpsilonAction = %1.3f', x_), 'ClosedFormREPSEpsilonAction', true, [], []);
Plotter.PlotterEvaluations.plotData(plotDataClosedFormREPSEpsilonActionWithNoise);
 %% NES WIth Noise
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_NESWithNoiseNewTaskSetup/numSamples_201405291913_01/experiment.mat')
dataClosedFormREPSBeta= obj.getTrialData({'avgReturn'});

[plotDataNESWithNoise ] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSBeta, 'episodes', 'avgReturn', 'settings.entropyBeta', ...
    @(x_) sprintf('EntropyBeta = %1.3f', x_), 'ClosedFormREPSBeta', true, [], []);
Plotter.PlotterEvaluations.plotData(plotDataNESWithNoise);
 %% CMA With Noise

load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_CMAwithNoiseNewTaskSetup/numSamples_201405291914_01/experiment.mat')
dataClosedFormREPSBeta= obj.getTrialData({'avgReturn'});
for i = 1:length(dataClosedFormREPSBeta)
    dataClosedFormREPSBeta(i).parameters{end + 1} = 'settings.numSamplesEpisodes';
    dataClosedFormREPSBeta(i).values{end + 1} = 14;
end
[plotDataCMAWithNoise ] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSBeta, 'episodes', 'avgReturn', 'settings.entropyBeta', ...
    @(x_) sprintf('EntropyBeta = %1.3f', x_), 'ClosedFormREPSBeta', true, [], []);
Plotter.PlotterEvaluations.plotData(plotDataCMAWithNoise);
 %% Power With Noise
  load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_powerTempertureWithNoiseNewSetup/numSamples_201405302235_01/experiment.mat')
  %load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_powerTempertureWithNoiseNewSetupWithPriorCov/numSamples_201405311754_01/experiment.mat')
  dataClosedFormREPSBeta= obj.getTrialData({'avgReturn'});

[plotDataPowerWithNoise ] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSBeta, 'episodes', 'avgReturn', 'settings.entropyBeta', ...
    @(x_) sprintf('EntropyBeta = %1.3f', x_), 'ClosedFormREPSBeta', true, [], []);
Plotter.PlotterEvaluations.plotData(plotDataPowerWithNoise);
 %% Entropy Beta With Noise
%load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_EntropyREPSEEntropyBetaWithNoiseNewSetupFading/numSamples_201405302233_01/experiment.mat')
%load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_EntropyREPSEEntropyBetaWithNoiseNewSetupFading/numSamples_201405311148_01/experiment.mat')
%load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_EntropyREPSEEntropyBetaWithNoiseNewSetupFadingEpsilon1/numSamples_201405311259_01/experiment.mat')
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_EntropyREPSEEntropyBetaWithNoiseNewSetupFadingEpsilon0.5/numSamples_201405311258_01/experiment.mat')
dataClosedFormREPSBeta= obj.getTrialData({'avgReturn'}); %2ndone

[plotDataENtropyBetaWithNoise ] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSBeta, 'episodes', 'avgReturn', 'settings.entropyBeta', ...
    @(x_) sprintf('EntropyBeta = %1.3f', x_), 'ClosedFormREPSBeta', true, [], []);
Plotter.PlotterEvaluations.plotData(plotDataENtropyBetaWithNoise);
%% Standard Reps With Noise
%load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_StandardREPSMaxSamples/numSamples_201405211359_01/experiment.mat')
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_StandardREPSMaxSampleswithoutNoiseMorethan200/numSamples_201405251737_01/experiment.mat')
dataStandardRepsWithNoise= obj.getTrialData({'avgReturn'});

[plotDataStandardRepsWithNoise] = Plotter.PlotterEvaluations.preparePlotData(dataStandardRepsWithNoise, 'episodes', 'avgReturn', 'settings.entropyBeta', ...
    @(x_) sprintf('EntropyBeta = %1.3f', x_), 'ClosedFormREPSBeta', true, [], []);
Plotter.PlotterEvaluations.plotData(plotDataStandardRepsWithNoise);

%% CMA and ModelBasedReps, NES With Noise
algComparison = Plotter.PlotterEvaluations.mergePlots(plotDataClosedFormREPSEpsilonActionWithNoise, [2], plotDataNESWithNoise, [1], 'test');
algComparison = Plotter.PlotterEvaluations.mergePlots(algComparison, [1 2], plotDataCMAWithNoise, [1], 'AlgorithmComparison', true);
algComparison = Plotter.PlotterEvaluations.mergePlots(algComparison, [1 2 3], plotDataPowerWithNoise , [1], 'AlgorithmComparison', true);
%algComparison = Plotter.PlotterEvaluations.mergePlots(algComparison, [1 2 3 4], plotDataENtropyBetaWithNoise, [2], 'AlgorithmComparison', true);
%algComparison = Plotter.PlotterEvaluations.mergePlots(algComparison, [1 2 3 4 5], plotDataStandardRepsWithNoise, [2], 'AlgorithmComparison', true);


algComparison.evaluationLabels{1} = 'ModelBasedReps';
algComparison.evaluationLabels{2} = 'NES';
algComparison.evaluationLabels{3} = 'CMA';
algComparison.evaluationLabels{4} = 'Power';
%algComparison.evaluationLabels{5} = 'EntropyReps';
%algComparison.evaluationLabels{6} = 'StandardReps';

algComparison = Plotter.PlotterEvaluations.smoothPlotData(algComparison, 3);
algComparison.plotInterval = 5;
Plotter.PlotterEvaluations.plotData(algComparison);
Plotter.plot2svg('CMAClosedFormRepsStandardRepsPower.svg', gcf);

%**********************************************************************************
 

%% Closed Form High Dim
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPSWithNoiseHighDim2/numSamples_201405301814_01/experiment.mat')
%outliers trial 2,8
dataClosedFormREPSBeta = obj.getTrialData({'avgReturn'});
dataClosedFormREPSBeta = Plotter.PlotterEvaluations.filterEvalData(dataClosedFormREPSBeta, 'avgReturn', -10^5);

[plotDataClosedFormHighDim ] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSBeta, 'episodes', 'avgReturn', 'settings.entropyBeta', ...
    @(x_) sprintf('EntropyBeta = %1.3f', x_), 'ClosedFormREPSBeta', true, [], []);

Plotter.PlotterEvaluations.plotData(plotDataClosedFormHighDim);
%% CMA High Dim
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_CMAwithoutNoiseNewTaskSetupHighDim/numSamples_201405302354_01/experiment.mat')
dataClosedFormREPSBeta= obj.getTrialData({'avgReturn'});
for i = 1:length(dataClosedFormREPSBeta)
    dataClosedFormREPSBeta(i).parameters{end + 1} = 'settings.numSamplesEpisodes';
    dataClosedFormREPSBeta(i).values{end + 1} = 25;
end
dataClosedFormREPSBeta = Plotter.PlotterEvaluations.filterEvalData(dataClosedFormREPSBeta, 'avgReturn', -10^5);
%outliers trial 10
[plotDataCMAHighDim ] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSBeta, 'episodes', 'avgReturn', 'settings.entropyBeta', ...
    @(x_) sprintf('EntropyBeta = %1.3f', x_), 'ClosedFormREPSBeta', true, [], []);
Plotter.PlotterEvaluations.plotData(plotDataCMAHighDim);
%% NES High Dim
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_NESWithNoiseNewTaskSetupHighDim/numSamples_201405302341_01/experiment.mat')
dataClosedFormREPSBeta= obj.getTrialData({'avgReturn'});
dataClosedFormREPSBeta = Plotter.PlotterEvaluations.filterEvalData(dataClosedFormREPSBeta, 'avgReturn', -10^5);
%outliers trial 2,7,8,9,10
[plotDataNESHighDim ] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSBeta, 'episodes', 'avgReturn', 'settings.entropyBeta', ...
    @(x_) sprintf('EntropyBeta = %1.3f', x_), 'ClosedFormREPSBeta', true, [], []);
Plotter.PlotterEvaluations.plotData(plotDataNESHighDim);

%% CMA and ModelBasedReps, NES With Noise
algComparison = Plotter.PlotterEvaluations.mergePlots(plotDataClosedFormHighDim, [1], plotDataNESHighDim, [1], 'test');
algComparison = Plotter.PlotterEvaluations.mergePlots(algComparison, [1 2], plotDataCMAHighDim, [1], 'AlgorithmComparison', true);

algComparison.evaluationLabels{1} = 'ModelBasedReps';
algComparison.evaluationLabels{2} = 'NES';
algComparison.evaluationLabels{3} = 'CMA';

algComparison = Plotter.PlotterEvaluations.smoothPlotData(algComparison, 3);
algComparison.plotInterval = 5;
Plotter.PlotterEvaluations.plotData(algComparison);
Plotter.plot2svg('AlgComparisonHighDim.svg', gcf);



%***************************************************
%% Entropy Reps Diff ENtropy Beta
%load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_EntropyRepsDiffEntropyWithOutNoise/numSamples_201405311143_01/experiment.mat')
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_EntropyRepsDiffEntropyWithOutNoiseTocomparewithLamda/numSamples_201405311432_01/experiment.mat')
dataClosedFormREPSBeta= obj.getTrialData({'avgReturn'});

[plotDataClosedFormREPSBetaCMA ] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSBeta, 'iterations', 'avgReturn', 'settings.entropyBeta', ...
    @(x_) sprintf('EntropyBeta = %1.3f', x_), 'ClosedFormREPSBeta', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataClosedFormREPSBetaCMA);

%% Entropy Reps Diffrent Lambda
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_RepsDiffLambda/numSamples_201405302245_01/experiment.mat')
dataClosedFormREPSBeta= obj.getTrialData({'avgReturn'});

[plotDataClosedFormREPSBetaCMA ] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSBeta, 'iterations', 'avgReturn', 'settings.priorCovWeightParameters', ...
    @(x_) sprintf('EntropyBeta = %1.3f', x_), 'ClosedFormREPSBeta', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataClosedFormREPSBetaCMA);


%**********************************************
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


a=Plotter.shadedErrorBar([1:11]',meandata,meanstdYmin',{'-b','markerfacecolor',[1,0.2,0.2], 'LineWidth', 2},1); hold all;

% closed form bayesian diffrent num parameters
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
b =Plotter.shadedErrorBar([1:11]',meandata,meanstdYmin',{'-r','markerfacecolor',[1,0.2,0.2], 'LineWidth', 2},1)

xlabel('Num Dimensions', 'FontSize', 18);
ylabel('Average Performance', 'FontSize', 18);
set(gca, 'FontSize', 16);
h(1) = a.mainLine;
h(2) = b.mainLine;

legend(h, {'PCA', 'Bayesian Projection'}, 'FontSize', 18, 'Location', 'South');
Plotter.plot2svg('ProjectionComparison.svg', gcf);
%*****************************************************************************

%% Closed form context
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_StandardREPSContextMaxSamples/numSamples_201406022018_01/experiment.mat')
dataClosedFormREPSBeta= obj.getTrialData({'avgReturn'});
%outliers trial 2,7,8,9,10
[plotDataClosedFormREPSBetaCMA ] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSBeta, 'iterations', 'avgReturn', 'settings.maxSamples', ...
    @(x_) sprintf('maxSampless = %1.3f', x_), 'ClosedFormREPSBeta', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataClosedFormREPSBetaCMA);

%% Max Samples
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPSContextMaxSample/numSamples_201406040116_01/experiment.mat')
dataClosedFormREPSBeta= obj.getTrialData({'avgReturn'});
%outliers trial 2,7,8,9,10
[plotDataClosedFormREPSBetaCMA ] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSBeta, 'iterations', 'avgReturn', 'settings.maxSamples', ...
    @(x_) sprintf('maxSamples = %1.3f', x_), 'ClosedFormREPSBeta', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataClosedFormREPSBetaCMA);

%% Uniform distribution
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ClosedFormREPSContextUniformDistDiffBayesParameter/numSamples_201406041416_01/experiment.mat')
dataClosedFormREPSBeta= obj.getTrialData({'avgReturn'});
%outliers trial 2,7,8,9,10
[plotDataClosedFormREPSBetaCMA ] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSBeta, 'iterations', 'avgReturn', 'settings.bayesParametersSigma', ...
    @(x_) sprintf('ParameterSigma = %1.3f', x_), 'ClosedFormREPSBeta', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataClosedFormREPSBetaCMA);

%%
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_StandardREPSContextMaxSamples/numSamples_201406022018_01/experiment.mat')
%load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/PlanarReaching_StandardREPSContext/numSamples_201406022010_01/experiment.mat')
dataClosedFormREPSBeta= obj.getTrialData({'avgReturn'});
%outliers trial 2,7,8,9,10
[plotDataClosedFormREPSBetaCMA ] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSBeta, 'iterations', 'avgReturn', 'settings.maxSamples', ...
    @(x_) sprintf('EntropyBeta = %1.3f', x_), 'ClosedFormREPSBeta', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataClosedFormREPSBetaCMA);

%%Quadratic Models
%% NES
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/QuadraticBandit_NESQuadraticWithMultNoise/numSamples_201406050912_01/experiment.mat')
dataClosedFormREPSBeta= obj.getTrialData({'avgReturn'});
%outliers trial 2,7,8,9,10
[plotDataQuadraticNES ] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSBeta, 'iterations', 'avgReturn', 'settings.maxSamples', ...
    @(x_) sprintf('EntropyBeta = %1.3f', x_), 'ClosedFormREPSBeta', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataQuadraticNES);
%% power
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/QuadraticBandit_PowerQuadraticWithMultNoise/numSamples_201406050933_01/experiment.mat')
dataClosedFormREPSBeta= obj.getTrialData({'avgReturn'});
%outliers trial 2,7,8,9,10
[plotDataQuadraticPower ] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSBeta, 'iterations', 'avgReturn', 'settings.maxSamples', ...
    @(x_) sprintf('EntropyBeta = %1.3f', x_), 'ClosedFormREPSBeta', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataQuadraticPower);
%% closedform
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/QuadraticBandit_REPSLearnedRewardQuadraticWithMultNoise/numSamples_201406050928_01/experiment.mat')
dataClosedFormREPSBeta= obj.getTrialData({'avgReturn'});
%outliers trial 2,7,8,9,10
[plotDataQuadraticClosedForm ] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSBeta, 'iterations', 'avgReturn', 'settings.maxSamples', ...
    @(x_) sprintf('EntropyBeta = %1.3f', x_), 'ClosedFormREPSBeta', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataQuadraticClosedForm);
%% CMA
load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/QuadraticBandit_CMAQuadraticWithMultNoise/numSamples_201406050932_01/experiment.mat')
dataClosedFormREPSBeta= obj.getTrialData({'avgReturn'});
%outliers trial 2,7,8,9,10
[plotDataQuadratiCMA ] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSBeta, 'iterations', 'avgReturn', 'settings.maxSamples', ...
    @(x_) sprintf('EntropyBeta = %1.3f', x_), 'ClosedFormREPSBeta', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataQuadratiCMA);
%% REPS

load('/home/gn81ireg/policysearchtoolbox/+Experiments/data/test/QuadraticBandit_REPSQuadraticWithMultNoise/numSamples_201406050913_01/experiment.mat')
dataClosedFormREPSBeta= obj.getTrialData({'avgReturn'});
%outliers trial 2,7,8,9,10
[plotDataQuadratiStandardReps ] = Plotter.PlotterEvaluations.preparePlotData(dataClosedFormREPSBeta, 'iterations', 'avgReturn', 'settings.maxSamples', ...
    @(x_) sprintf('EntropyBeta = %1.3f', x_), 'ClosedFormREPSBeta', false, [], []);
Plotter.PlotterEvaluations.plotData(plotDataQuadratiStandardReps);
%% Comparison for Quadratic Task

algComparison = Plotter.PlotterEvaluations.mergePlots(plotDataQuadraticNES, [1], plotDataQuadraticPower, [1], 'test');
algComparison = Plotter.PlotterEvaluations.mergePlots(algComparison, [1 2], plotDataQuadraticClosedForm, [1], 'AlgorithmComparison', true);
algComparison = Plotter.PlotterEvaluations.mergePlots(algComparison, [1 2 3], plotDataQuadratiCMA, [1], 'AlgorithmComparison', true);
algComparison = Plotter.PlotterEvaluations.mergePlots(algComparison, [1 2 3 4], plotDataQuadratiStandardReps, [1], 'AlgorithmComparison', true);


algComparison.evaluationLabels{1} = 'NES';
algComparison.evaluationLabels{2} = 'Power';
algComparison.evaluationLabels{3} = 'ClosedForm';
algComparison.evaluationLabels{2} = 'CMA';
algComparison.evaluationLabels{3} = 'REPS';

%algComparison = Plotter.PlotterEvaluations.smoothPlotData(algComparison, 3);
algComparison.plotInterval = 5;
Plotter.PlotterEvaluations.plotData(algComparison);
Plotter.plot2svg('AlgComparisonHighDim.svg', gcf);
