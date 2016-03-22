clear variables;
%close all;


%% 
REPSLearnedRewardNoiseMultParametersSigmaCor=['/home/abdolmaleki/policysearchtoolbox/+Experiments/data/test/QuadraticBandit_REPSLearnedRewardNoiseMultParametersSigmaCor/numSamples_201405091932_01/experiment.mat']

REPSLearnedRewardNoiseParametersSigmaCo     =['/home/abdolmaleki/policysearchtoolbox/+Experiments/data/test/QuadraticBandit_REPSLearnedRewardNoiseParametersSigmaCor/numSamples_201405091927_01/experiment.mat']

REPSLearnedRewardMaxSampleEpsilonActionCorRewardNoiseVar = ['/home/abdolmaleki/policysearchtoolbox/+Experiments/data/test/QuadraticBandit_REPSLearnedRewardMaxSampleEpsilonActionCorRewardNoiseVar/numSamples_201405091918_01/experiment.mat']

REPSLearnedRewardMaxSampleEpsilonActionCorRewardNoiseMultVar = ['/home/abdolmaleki/policysearchtoolbox/+Experiments/data/test/QuadraticBandit_REPSLearnedRewardMaxSampleEpsilonActionCorRewardNoiseMultVar/numSamples_201405091923_01/experiment.mat']

StandardREPSMaxSamplesEpsilonActionCorVarRewardNoise = ['/home/abdolmaleki/policysearchtoolbox/+Experiments/data/test/QuadraticBandit_REPSMaxSamplesEpsilonActionCorVarRewardNoise/numSamples_201405091945_01/experiment.mat']

StandardREPSMaxSamplesEpsilonActionCorVarRewardNoiseMult = ['/home/abdolmaleki/policysearchtoolbox/+Experiments/data/test/QuadraticBandit_REPSMaxSamplesEpsilonActionCorVarRewardNoiseMult/numSamples_201405092052_01/experiment.mat']

PowerTemperatureRewardNoise = ['/home/abdolmaleki/policysearchtoolbox/+Experiments/data/test/QuadraticBandit_PowerTemperatureRewardNoise/numSamples_201405092008_02/experiment.mat']

PowerTemperatureRewardNoiseMult = ['/home/abdolmaleki/policysearchtoolbox/+Experiments/data/test/QuadraticBandit_PowerTemperatureRewardNoiseMult/numSamples_201405092053_01/experiment.mat']

%% REPSLearnedRewardMaxSampleEpsilonActionCorReward
load(REPSLearnedRewardMaxSampleEpsilonActionCorRewardNoiseVar)
%load(REPSLearnedRewardMaxSampleEpsilonActionCorRewardNoiseMultVar)
%%
 evaluationData = obj.getTrialData({'rewardEval'});
 xAxis  = 'iterations';
 yDataString = 'rewardEval';
 labelProperty = {'settings.epsilonAction', 'settings.maxSamples'} ;
 labelGenerator = @(x_, y_) sprintf('KL %f, MaxSamples %f', x_, y_);
 useLogTransform = false ;
 trialIdx = [] ;
 
%% CONSTANT KL
 %  plotName = 'REPSLearnedRewardNoiseMultVarKL=0.5' ;
%  evalIdx = [1:4] ;

% plotName = 'REPSLearnedRewardNoiseMultVarKL=1' ;
% evalIdx = [5:8] ;
% 
% plotName = 'REPSLearnedRewardNoiseMultVarKL=1.5' ;
% evalIdx = [9:12] ;
% 
% plotName = 'REPSLearnedRewardNoiseMultVarKL=2' ;
% evalIdx = [13:16] ;

%% CONSTANT MaxSamples
% 
%   plotName = 'REPSLearnedRewardNoiseMultVarMaxSample=50' ;
%   evalIdx = [1:4:16] ;

%   plotName = 'REPSLearnedRewardNoiseMultVarMaxSample=150' ;
%   evalIdx = [2:4:16] ;
  
%   plotName = 'REPSLearnedRewardNoiseMultVarMaxSample=250' ;
%   evalIdx = [3:4:16] ;
%   
  plotName = 'REPSLearnedRewardNoiseMultVarMaxSample=350' ;
  evalIdx = [4:4:16] ;

%%
[plotData ] = Plotter.PlotterEvaluations.preparePlotData(evaluationData, xAxis, yDataString, labelProperty, labelGenerator, ...
                                                          plotName, useLogTransform, evalIdx, trialIdx);
Plotter.PlotterEvaluations.plotData(plotData );
%%
return





[plotData ] = Plotter.PlotterEvaluations.preparePlotData(dataEvaluation, 'iterations', 'rewardEval', {'settings.rewardNoise', 'settings.bayesParametersSigma'}, @(x_, y_) sprintf('noise %f, sigma %f', x_, y_), 'REPSLearnedReward', false, [1:4], []);
%(evaluationData, xAxis, yDataString, labelProperty, labelGenerator, plotName, useLogTransform, evalIdx, trialIdx)
Plotter.PlotterEvaluations.plotData(plotData );
%%
[plotData ] = Plotter.PlotterEvaluations.preparePlotData(dataEvaluation, 'iterations', 'rewardEval', {'settings.rewardNoise', 'settings.bayesParametersSigma'}, @(x_, y_) sprintf('noise %f, sigma %f', x_, y_), 'REPSLearnedReward', false, [1:4:24], []);
Plotter.PlotterEvaluations.plotData(plotData );

%%
[plotData ] = Plotter.PlotterEvaluations.preparePlotData(dataEvaluation, 'iterations', 'rewardEval', {'settings.rewardNoise', 'settings.bayesParametersSigma'}, @(x_, y_) sprintf('noise %f, sigma %f', x_, y_), 'REPSLearnedReward', false, [2:4:24], []);
Plotter.PlotterEvaluations.plotData(plotData );

%%
[plotData ] = Plotter.PlotterEvaluations.preparePlotData(dataEvaluation, 'iterations', 'rewardEval', {'settings.rewardNoise', 'settings.bayesParametersSigma'}, @(x_, y_) sprintf('noise %f, sigma %f', x_, y_), 'REPSLearnedReward', false, [3:4:24], []);
Plotter.PlotterEvaluations.plotData(plotData );

%%
[plotData ] = Plotter.PlotterEvaluations.preparePlotData(dataEvaluation, 'iterations', 'rewardEval', {'settings.rewardNoiseMult', 'settings.bayesParametersSigma'}, @(x_, y_) sprintf('noise %f, sigma %f', x_, y_), 'REPSLearnedReward', false, [4:4:24], []);
Plotter.PlotterEvaluations.plotData(plotData );


%% 
% 
% %% Step-Based vs episodic
% 
% 
% stepVsEpisodeBased = Plotter.PlotterEvaluations.mergePlots(plotDataPiREPSSamples, [1 2], dataEpisodicPiREPSamples, [3], 'test');
% stepVsEpisodeBased = Plotter.PlotterEvaluations.mergePlots(stepVsEpisodeBased, [1 2 3], dataEpisodicPiREPSamples2, [1 2], 'EpisodeStepBasedComparison', true);
%  
% stepVsEpisodeBased.evaluationLabels{1} = 'Step Based, N = 800';
% stepVsEpisodeBased.evaluationLabels{2} = 'Step Based, N = 400';
% stepVsEpisodeBased.evaluationLabels{3} = 'Episode Based, N = 2000';
% stepVsEpisodeBased.evaluationLabels{4} = 'Episode Based, N = 800';
% stepVsEpisodeBased.evaluationLabels{5} = 'Episode Based, N = 400';
% 
% stepVsEpisodeBased.evalProps(1).lineStyle = '-';
% stepVsEpisodeBased.evalProps(2).lineStyle = '-';
% stepVsEpisodeBased.evalProps(3).lineStyle = '--';
% stepVsEpisodeBased.evalProps(4).lineStyle = '--';
% stepVsEpisodeBased.evalProps(5).lineStyle = '--';
% 
% Plotter.PlotterEvaluations.plotData(stepVsEpisodeBased);
% %% Algorithms
% 
% algComparison = Plotter.PlotterEvaluations.mergePlots(plotDataPiREPSSamples, [1], dataEpisodicNoFeatures, [2], 'test');
% algComparison = Plotter.PlotterEvaluations.mergePlots(algComparison, [1 2], plotDataPowerLambda, [4], 'AlgorithmComparison', true);
% algComparison = Plotter.PlotterEvaluations.mergePlots(algComparison, [1 2 3], plotDataPowerOpenLoop, [1], 'AlgorithmComparison', true);
% 
% algComparison.evaluationLabels{1} = 'PI REPS';
% algComparison.evaluationLabels{2} = 'No Features';
% algComparison.evaluationLabels{3} = 'PI2';
% algComparison.evaluationLabels{4} = 'Open Loop PI2';
% 
% Plotter.PlotterEvaluations.plotData(algComparison);
