% load('/home/vgomez/policysearchtoolbox/+Experiments/data/test/ViaPoint_SquaredContextFeatures_TrajectoryBased_ProMPLearner_EpisodicPiREPS/numSamples_201506261428_01/experiment.mat')
% data = obj.getTrialData({'avgReturn'});
% data = Plotter.PlotterEvaluations.preparePlotData(data, 'iterations', 'avgReturn', 'settings.numSamplesEpisodes', @(x_) sprintf('N = %.0d', x_), 'd', true, [], []);
% Plotter.PlotterEvaluations.plotData(data);
clear;

%load('/home/vgomez/policysearchtoolbox/+Experiments/data/test/ViaPoint_SquaredContextFeatures_TrajectoryBased_ProMPLearner_EpisodicPiREPS/allparams_201506271714_01/experiment.mat')
load('/home/vgomez/policysearchtoolbox/+Experiments/data/test/ViaPoint_SquaredContextFeatures_TrajectoryBased_ProMPLearner_EpisodicPiREPS/lambdafactor_201507022351_01/experiment.mat')

data = obj.getTrialData({'avgReturn'});

close all;

% eval = 1:3;
% for x5 = 1:2  
%     for x4 = 1:3
%         for x3 = 1:3
%             for x2 = 1:3
%                 [dataP] = Plotter.PlotterEvaluations.preparePlotData(data, 'iterations', 'avgReturn', 'settings.ctlPinvThresh', @(x_) sprintf('Thresh = %1.4f', x_), 'ViaPointPiREPSProMPs', true, eval, []);
%                 hd = Plotter.PlotterEvaluations.plotData(dataP);
%                 str = sprintf('width=%.2f,initS=%.2f,numB=%d,Reg=%e', data(eval(1)).values{10}, ...
%                     data(eval(1)).values{11}, data(eval(1)).values{12}, data(eval(1)).values{13});
%                 title(str);
%                 eval = eval+3;
%                 saveas(hd,[str '.pdf']);
%                % keyboard;
%             end
%         end
%     end
% end

eval = 1:4;
for x4 = 1:3
    for x3 = 1:2
            [dataP] = Plotter.PlotterEvaluations.preparePlotData(data, 'iterations', 'avgReturn', 'settings.ctlPinvThresh', @(x_) sprintf('Thresh = %1.4f', x_), 'ViaPointPiREPSProMPs', true, eval, []);
            hd = Plotter.PlotterEvaluations.plotData(dataP);
            str = sprintf('numB = %d, PICostActMult = %.1e', ...
                data(eval(1)).values{13}, data(eval(1)).values{14});
            title(str);
            eval = eval+4;
            saveas(hd,[str '.pdf']);
           % keyboard;
    end
end

% Plot PiREPS for comparison
load('/home/vgomez/policysearchtoolbox/+Experiments/data/test/ViaPoint_SquaredContextFeatures_TimeDependentPolicy_EpisodicPiREPS/EpisodicPiREPS_samples_201508141046_01/experiment.mat')
dataPiREPSSamples = obj.getTrialData({'avgReturn'});

[plotDataPiREPSSamples] = Plotter.PlotterEvaluations.preparePlotData(dataPiREPSSamples, ...
    'iterations', 'avgReturn', {'settings.numSamplesEpisode','settings.maxSamples'} , @(x_,y_) sprintf('num Samples = %.3d, max samples = %.3d', x_,y_), 'samples', true, [], []);
Plotter.PlotterEvaluations.plotData(plotDataPiREPSSamples );
