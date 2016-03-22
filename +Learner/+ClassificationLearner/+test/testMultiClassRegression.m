clear variables;
close all;

dimState = 2;
numOptions = 30;
dataManager = Data.DataManager('steps');

dataManager.addDataEntry('states', dimState);
dataManager.addDataEntry('options', 1, 0, numOptions);

dataManager.addDataEntry('rewardWeighting', 1);


squaredFeatures = FeatureGenerators.SquaredFeatures(dataManager, 'states', [], true);
linearFeatures  = FeatureGenerators.LinearFeatures(dataManager, 'states', [], true);


softMaxDist             = Distributions.Discrete.SoftMaxDistribution(dataManager, 'options', squaredFeatures.outputName, 'testFunction');
softMaxDist.numItems    = numOptions;
softMaxLearner          = Learner.ClassificationLearner.MultiClassLogisticRegressionLearner(dataManager,softMaxDist, true);


dataManager.finalizeDataManager();

newData = dataManager.getDataObject(1000);
newData.setDataEntry('states', randn(1000,dimState));

softMaxDist.setThetaAllItems(rand(softMaxDist.numItems,dataManager.getNumDimensions('statesSquared')) -0.5);

%%

% numSamples = 100;
numSamplesTest = 1000;
states = newData.getDataEntry('states'); 
numSamples = size(states,1);
% statesTest = rand(numSamplesTest,2); 
statesTest = states;
colors = zeros(numSamples, 3);


centers = rand(numOptions,dimState);



for s = 1 : numSamples
  for o = 1 : numOptions
    distances(s,o) = norm(states(s,:) - centers(o,:) ) + rand(1,1) * 0.2;
  end
  [~, label(s)] = min(distances(s,:)); 
%   label(s) = ceil(norm(states(s,:))/0.5);  
  colors(s,label(s)) = 1;
end


  
%%

% model.gating = rand(numOptions,6) -0.5;
lambda = 1e-6;
alpha   = 1e-2;

I = eye(numOptions);

% [pOsBar phiAll] =  multReg(settings, model, states);
phiAll = newData.getDataEntry('statesSquared');

%%

featureSize = size(phiAll,2);
phiSquare = zeros(featureSize, featureSize, numSamples);

for s = 1 : numSamples
  phiSquare(:,:,s) = phiAll(s,:)'*phiAll(s,:); %[feature, feature, state]
end

multLabels = zeros(numSamples, numOptions);
multLabels = bsxfun(@rdivide, 1./distances, sum(1./distances,2));
for s = 1 : numSamples
%   multLabels(s, label(s)) = 1;
%   multLabels(s, label(s)) = 1 - distances(s,label(s)) ;
  weights(s) = multLabels(s,label(s));
end


figure(1);
% scatter(states(:,1),states(:,2), ones(numSamples,1) * 100, colors)
%scatter(states(:,1),states(:,2), weights * 100, colors)

%%
newData.setDataEntry('optionsDesiredProbs', multLabels);
itemProb = softMaxDist.callDataFunctionOutput('getItemProbabilities', newData);
E = -sum(sum(multLabels .* log(itemProb),2))
tic
softMaxLearner.updateModel(newData)
toc
itemProb = softMaxDist.callDataFunctionOutput('getItemProbabilities', newData);
E = -sum(sum(multLabels .* log(itemProb),2))

%%


colorsHat = zeros(numSamplesTest, 3);
labelHat  = softMaxDist.callDataFunctionOutput('getItemProbabilities', newData);
[~, labelMax] = max(labelHat');

for s = 1 : numSamplesTest
  colorsHat(s,labelMax(s)) = 1;
end

figure(2)
%scatter(statesTest(:,1),statesTest(:,2), ones(numSamplesTest,1) * 100, colorsHat)


% %%
% multLabels = bsxfun(@times, ones(numSamples, numOptions), [0.9, 0.1, 0]);
% newData.setDataEntry('optionsDesiredProbs', multLabels);
% softMaxLearner.updateModel(newData)
% labelHat  = softMaxDist.callDataFunctionOutput('getItemProbabilities', newData);

%%
dimState    = 1;
numOptions  = 2;

clear dataManager

dataManager = Data.DataManager('steps');

dataManager.addDataEntry('states', dimState);
dataManager.addDataEntry('options', 1, 0, numOptions);
dataManager.addDataEntry('rewardWeighting', 1);


softMaxDist             = Distributions.Discrete.SoftMaxDistribution(dataManager, 'options', 'states', 'testFunction');
softMaxDist.numItems    = numOptions;
softMaxLearner          = Learner.ClassificationLearner.MultiClassLogisticRegressionLearner(dataManager,softMaxDist, true);


dataManager.finalizeDataManager();

newData = dataManager.getDataObject(1000);
newData.setDataEntry('states', randn(1000,dimState));

softMaxDist.setThetaAllItems(rand(softMaxDist.numItems,dataManager.getNumDimensions(softMaxDist.inputVariables{1})) -0.5);

states = newData.getDataEntry('states'); 
multLabels = bsxfun(@times, ones(numSamples, numOptions), [0.8, 0.2]);
newData.setDataEntry('optionsDesiredProbs', multLabels);
softMaxLearner.updateModel(newData)
labelHat  = softMaxDist.callDataFunctionOutput('getItemProbabilities', newData);

figure
hold on
clear h
h(1) = plot(states,multLabels(:,1),'r*');
plot(states,multLabels(:,2),'m*');
% h(2) = plot(states,labelHat,'b*');
% legend('InputData', 'Estimated Data');

