numEpisodes         = 100;
numTimeSteps        = 150;
% dt                  = 0.01;
% dtBase              = 0.05;
% numStepsPerDecision = 5;
% restartProb         = 0.02 * dt/dtBase * numStepsPerDecision;


load('Helper/PendulumTrajs/trialHiREPS.mat');
isActiveStepSampler                 = Sampler.IsActiveStepSampler.IsActiveNumSteps(trial.dataManager, 'decisionSteps');
isActiveStepSampler.numTimeSteps    = numTimeSteps / numStepsPerDecision;
trial.sampler.stageSampler.setIsActiveSampler(isActiveStepSampler);
trial.sampler.numSamples            = numEpisodes;

trial.dataManager.setRange('contexts',[-pi,-30], [pi,30]);


tmpData                             = trial.dataManager.getDataObject(numEpisodes);
trial.sampler.createSamples(tmpData);


% Plotter.PlotterData.plotTrajectories(tmpData, 'states',1);
% title('InputData');
figure
statesPeriodic = zeros(numTimeSteps, numEpisodes);
for i = 1 : numEpisodes
    contextsNew         = tmpData.getDataEntry('states',i);
    states{i}           = contextsNew(1:numTimeSteps,:);
    actions{i}          = tmpData.getDataEntry('actions',i);
    statesPeriodic(:,i) = contextsNew(1:numTimeSteps,1); 
    statesPeriodic(abs(diff(contextsNew(1:numTimeSteps,1)))>pi,i)=nan;    
end
plot(statesPeriodic);    


%%

data = [];
data.numElements = numEpisodes;
for i = 1 : numEpisodes
    data.steps(i,1).states        = states{i};
    data.steps(i,1).actions       = actions{i};
    data.steps(i,1).numElements   = size(actions{i},1);
end