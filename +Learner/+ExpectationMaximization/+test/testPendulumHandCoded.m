clear variables;
close all;
addpath Helper/
Common.clearClasses;


numSamples          = 10000;
numSteps            = 5;
noiseAction         = 0;
noiseState          = 0;


% minRangeContexts = [-1.5708 0]; 
% maxRangeContexts = [4.7124 0];
minRangeContexts    = [-pi -30]; 
maxRangeContexts    = [pi 30];
maxRangeActions     = 35;


settings = Common.Settings();
settings.setProperty('numSamplesEpisodes', numSamples);
settings.setProperty('numTimeSteps', numSteps);
settings.setProperty('periodicRange', [-pi, pi]);

settings.setProperty('InitialStateDistributionMinRange', minRangeContexts);
settings.setProperty('InitialStateDistributionMaxRange', maxRangeContexts);
settings.setProperty('InitialStateDistributionType', 'Uniform');
settings.setProperty('maxTorque', maxRangeActions);
settings.setProperty('Noise_std', noiseAction);
settings.setProperty('NoiseState', noiseState);





sampler             = Sampler.EpisodeWithStepsSamplerOptions();
dataManager         = sampler.getEpisodeDataManager();
dataManager.finalizeDataManager();



environment         = Environments.DynamicalSystems.Pendulum(sampler, true); %non periodic
environment.initObject();

depth = dataManager.getDataEntryDepth('states');




initialStateSampler = Sampler.InitialSampler.InitialStateSamplerStandard(sampler);

sampler.setTransitionFunction(environment);
sampler.setInitialStateSampler(initialStateSampler);


actionCost = 0;
stateCost = [10 0; 0 0];
rewardFunction = RewardFunctions.QuadraticRewardFunctionSwingUpSimple(dataManager); %non multimodal reward
rewardFunction.setStateActionCosts(stateCost, actionCost);
returnSampler       = RewardFunctions.ReturnForEpisode.ReturnAvgReward(dataManager);



sampler.setRewardFunction(rewardFunction);
sampler.setReturnFunction(returnSampler);
sampler.getStepSampler.setIsActiveSampler(Sampler.IsActiveStepSampler.IsActiveNumSteps(dataManager));



dataManager.finalizeDataManager();
% dataManager.setRange('states', minRangeContexts, maxRangeContexts);
dataManager.setRange('actions', -500, 500);

sampler.initObject();
dataManager.finalizeDataManager();

actionPolicy = Environments.DynamicalSystems.PendulumPolicy(dataManager, 'actions', 'states');

sampler.setActionPolicy(actionPolicy);
sampler.setParallelSampling(true);


actionPolicy.initObject();


newData = dataManager.getDataObject();
sampler.createSamples(newData);


%%
Plotter.PlotterData.plotTrajectories(newData, 'states');
Plotter.PlotterData.plotTrajectories(newData, 'actions');

for i = 1 : numSteps
    statesEnd = newData.getDataEntry('states',:,i);
    ratio(i)   = sum(abs(statesEnd(:,1)) < 0.5) / numel(statesEnd(:,1));
end
figure
plot(ratio)
ratio(end)

angleRange = pi;
VResolution = 100;


[x, y] = meshgrid( linspace(-angleRange, angleRange, VResolution), linspace(-30, 30, VResolution));
x = x';
y = y';
contextVec      = [x(:), y(:)];
plotData        = dataManager.getDataObject(size(contextVec,1));
plotData.setDataEntry('states', contextVec);

for i = 1 : 1
figure(28+i); clf;
if(i == 1) 
    currModel   = actionPolicy;
    figTitle    = 'Original Policy';
else
    currModel   = mixtureModel;
    figTitle    = 'Estimated Policy';
end
% resps = currModel.gating.getItemProbabilities([],plotData.getDataEntry(mixtureModel.gating.inputVariables{1}));

% [~, optionIdx]      = max(resps,[],2);
% optionList          = unique(optionIdx);
% policyExpectation   = zeros(size(optionIdx,1),1);
% for i = 1 : length(optionList)
%     option              = optionList(i);
%     sampleSelection     = optionIdx == option;
%     contextsForOption   = contextVec(sampleSelection,:);
%     numSamples          = size(contextsForOption,1);
    
%     policyExpectation(sampleSelection) =  currModel.options{option}.getExpectation(numSamples, contextsForOption);
% end

policyExpectation = currModel.sampleAction(numSamples, contextVec);

% [~, maxRespsIdx] = max(resps,[],2);
% respsMat                        = reshape(maxRespsIdx, VResolution, VResolution);
% respsMat                        = respsMat';
% imagesc([-angleRange, angleRange],[-30, 30],respsMat);
% colorbar

policyExpectationMat            = reshape(policyExpectation, VResolution, VResolution);
policyExpectationMat            = policyExpectationMat';
imagesc([-angleRange, angleRange],[-30, 30],policyExpectationMat);
set(gca,'YDir','normal');
colorbar
title(figTitle);
pause(0.1)
end


%% Save in data structure

statesPeriodic = zeros(numSteps, numSamples);
for i = 1 : numSamples
    states{i}           = newData.getDataEntry('states',i);             
    actions{i}          = newData.getDataEntry('actions',i);       
    tmp                 = states{i};
    statesPlot(:,i)     = tmp(:,1);
    actionsPlot(:,i)    = actions{i};
end
% figure
% plot(statesPlot)
% figure
% plot(actionsPlot)

%%

data = [];
data.numElements = numSamples;
for i = 1 : numSamples
    data.steps(i,1).states        = states{i};
    data.steps(i,1).actions       = actions{i};
    data.steps(i,1).numElements   = size(actions{i},1);
end

figure
states = newData.getDataEntry('states');
actions = newData.getDataEntry('actions');
scatter(states(:,1), states(:,2), 100, actions)

% save('Helper/PendulumTrajs/dataHandCoded','data')


