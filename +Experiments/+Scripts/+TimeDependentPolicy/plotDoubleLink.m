clear variables;
close all;


%% load
%load('/work/scratch/ra61casa/data/test/rewardsToCome_Vs_QValue__x_numSamples_201507301740_01/experiment.mat')
%load('/work/scratch/ra61casa/data/test/DoubleLinkSwingUpFH_TimeDependentREPS/rewardsToCome_numSamples_201507311947_01/experiment.mat');
%load('/work/scratch/ra61casa/data/test/DoubleLinkSwingUpFH_TimeDependentREPS/qValue_maxSamples_201507311959_01/experiment.mat');
%load('/work/scratch/ra61casa/data/test/DoubleLinkSwingUpFH_TimeDependentREPS/qValue_higherNumSamples_201508031658_01/experiment.mat');
%load('/work/scratch/ra61casa/data/test/DoubleLinkSwingUpFH_TimeDependentREPS/qValue_higherNumSamples_201508031504_01/experiment.mat');
%load('/work/scratch/ra61casa/data/test/DoubleLinkSwingUpFH_TimeDependentREPS/combination_rAndq_201508032128_01/experiment.mat');
%load('/work/scratch/ra61casa/data/test/DoubleLinkSwingUpFH_TimeDependentREPS/policyEval_withVvalue_201508041513_01/experiment.mat');
%load('/work/scratch/ra61casa/data/test/DoubleLinkSwingUpFH_TimeDependentREPS/recursiveClosedFormQvalue_201508101406_01/experiment.mat');
%load('/work/scratch/ra61casa/data/test/DoubleLinkSwingUpFH_TimeDependentREPS/importanceSampling_debugTrue_201508131625_01/experiment.mat');
%load('/work/scratch/ra61casa/data/test/DoubleLinkSwingUpFH_TimeDependentREPS/importanceSampling_201508131813_01/experiment.mat');
%load('/work/scratch/ra61casa/data/test/DoubleLinkSwingUpFH_TimeDependentREPS/virtualSamples_201508132017_01/experiment.mat');
%load('/work/scratch/ra61casa/data/test/DoubleLinkSwingUpFH_TimeDependentREPS/virtualSamples_201508141425_01/experiment.mat');
load('/work/scratch/ra61casa/data/test/DoubleLinkSwingUpFH_TimeDependentREPS/additionalSamples_201508181859_01/experiment.mat');
%load('/experiment.mat');
%load('/work/scratch/ra61casa/data/test/DoubleLinkSwingUpFH_TimeDependentREPS/policyEval_recursiveQvalue_201508041955_01/experiment.mat');
%% average
dataPiREPSSamples = obj.getTrialData({'avgReturn'});
% 
% %% prepare plot
% [plotDataPiREPSSamples] = Plotter.PlotterEvaluations.preparePlotData(dataPiREPSSamples, 'iterations', 'avgReturn', 'settings.numSamplesEpisodes', @(x_) sprintf('numSamples = %.0d', x_), 'n_estimator', true, [], []);
% %% plot
% Plotter.PlotterEvaluations.plotData(plotDataPiREPSSamples);
% 
% %% 
% for i=1:3:35
%     actionPerState = [1 5 10];
%     methodName = {'Vval_Importance_Sampling', 'Vval_NoISampling', 'Nval_Importance_Sampling', 'Nval_NoISampling'};
%     fname = sprintf('%s_actionPerState%d', methodName{floor(i / 9) + 1}, actionPerState(mod((i-1)/3,length(actionPerState)) + 1))
%     [plotDataPiREPSSamples] = Plotter.PlotterEvaluations.preparePlotData(dataPiREPSSamples, 'iterations', 'avgReturn', 'settings.numSamplesEpisodes', @(x_) sprintf('numSamples = %.0d', x_), fname, true, [i:i+2], []);
%     Plotter.PlotterEvaluations.plotData(plotDataPiREPSSamples);
% end

%% plotting each trial individually

for evalid = 1:length(dataPiREPSSamples)
    figure;
    hold on;
    for i =1:length(dataPiREPSSamples(evalid).trials)
        semilogy(dataPiREPSSamples(evalid).trials(i).avgReturn);
    end
    set(gca,'yscale','log');        
end

%% custom labels hack?
% put at the end of prepareplotdata
% plotDataStruct.evaluationLabels = {'$r(s,a) + V_{t+1}(s'')$ with importance sampling', '$r(s,a) + V_{t+1}(s'')$', 'Rewards To Come'}

%% debug code
% for j = 1:4
%     fprintf('eval %d\n', j);
%     for i = 1:21
%         [a, b] = sort(dataPiREPSSamples(j).trials(i).avgReturn);
%         if(~isequal(b, (1:50)'))
%             disp(i)
%         end
%     end
% end
% 
% a = [dataPiREPSSamples(3).trials(1:21).avgReturn]
% b = -log10(-a)
% plot(1:50, b)

%% comparison preparation
%%% reward to come
% load('/work/scratch/ra61casa/data/test/rewardsToCome_Vs_QValue__x_numSamples_201507301740_01/experiment.mat');
% obj.path = '/work/scratch/ra61casa/data/test/rewardsToCome_Vs_QValue__x_numSamples_201507301740_01';
% qAndR = obj.getTrialData({'avgReturn'});
% rToComeData = qAndR(5:8);
% load('/work/scratch/ra61casa/data/test/DoubleLinkSwingUpFH_TimeDependentREPS/rewardsToCome_numSamples_201507311947_01/experiment.mat');
% rHigher = obj.getTrialData({'avgReturn'});
% rToComeData = [rToComeData rHigher]; %rToCome contains numSamples = {50, 100, 200, 400, 1600, 3200}
% %%% recursive vVal
% load('/work/scratch/ra61casa/data/test/DoubleLinkSwingUpFH_TimeDependentREPS/policyEval_withVvalue_201508041513_01/experiment.mat');
% vVal = obj.getTrialData({'avgReturn'});
% vVal = vVal(1:5) % numSamples 50..800
% %%% recursive qVal 
% load('/work/scratch/ra61casa/data/test/DoubleLinkSwingUpFH_TimeDependentREPS/recursiveClosedFormQvalue_201508101406_01/experiment.mat');
% qVal = obj.getTrialData({'avgReturn'}); %numSamples 100..800
% %%% importance sampling
% load('/work/scratch/ra61casa/data/test/DoubleLinkSwingUpFH_TimeDependentREPS/virtualSamples_201508141425_01/experiment.mat');
% importance = obj.getTrialData({'avgReturn'});
% importance = importance(1:5) % numSamples 50..800
% 
% %%% plotting
% for(i = 1:5)
%     compAll = [importance(i) vVal(i) rToComeData(i)];
%     figureName = ['importanceSampling', num2str(rToComeData(i).values{1})];
%     [plotData] = Plotter.PlotterEvaluations.preparePlotData(compAll, 'iterations', 'avgReturn', 'settings.numSamplesEpisodes', @(x_) sprintf('numSamples = %.0d', x_), figureName, true, [], []);
%     Plotter.PlotterEvaluations.plotData(plotData);
% end
