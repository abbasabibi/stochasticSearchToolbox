clear variables;
close all;

% rng(8)

settings = Common.Settings();
% settings.setProperty('logisticRegressionRegularizer',1e-7);
% settings.setProperty('logisticRegressionNumIterations',1000);
% settings.setProperty('logisticRegressionLearningRate',1e-2);
settings.setProperty('isDebugLogisticRegressionLearner', true);



dataManager = Data.DataManager('steps');

dataManager.addDataEntry('states', 1);
dataManager.addDataEntry('terminations', 1);
dataManager.addDataEntry('rewardWeighting', 1);

% squaredFeatures = FeatureGenerators.SquaredFeatures(dataManager, 'states', [], true);
linearFeatures = FeatureGenerators.LinearFeatures(dataManager, 'states', [], true);


% logisticDist    = Distributions.Discrete.LogisticDistribution(dataManager, 'terminations', squaredFeatures.outputName, 'testFunction');
logisticDist    = Distributions.Discrete.LogisticDistribution(dataManager, 'terminations', linearFeatures.outputName, 'testFunction');
logisticLearner = Learner.ClassificationLearner.LogisticRegressionLearner(dataManager,logisticDist, true);



dataManager.finalizeDataManager();
numSamplesTest = 1000;
newData = dataManager.getDataObject(numSamplesTest);
% newData.setDataEntry('states', randn(100,1));

% logisticDist.setTheta(rand(1,dataManager.getNumDimensions('statesSquared')) -0.5);
% logisticDist.setTheta(rand(1,dataManager.getNumDimensions('states')) -0.5);

% %%
% 
% % numSamples = 100;
% numSamplesTest = 100;
% states = newData.getDataEntry('states'); 
% numSamples = size(states,1);
% % statesTest = rand(numSamplesTest,2); 
% statesTest = states;
% colors = zeros(numSamples, 3);
% 
% 
% 
% stateRange = max(states) - min(states);
% 
% labels = ones(numSamples,1)*0.5;
% for s = 1 : numSamples
%   labels(s,1) = (states(s) - min(states) ) / stateRange;
%     if(states(s) < -1.2)
%       labels(s,1) = 0;
%     end
%     if(states(s) > 1.2)
%       labels(s,1) = 1;
%     end
% end
% 
% 
%   
% 
% 
% 
%%
states = (rand(numSamplesTest, dataManager.getNumDimensions('states'))-0.5) * 100; 
states = sort(states);
newData.setDataEntry('states', states);
labels = ones(numSamplesTest,1)*0.9 ;
newData.setDataEntry('terminationsDesiredProbs', labels);
theta = rand(1,dataManager.getNumDimensions(logisticDist.inputVariables{1})) -0.5;
logisticDist.setTheta(theta);
logisticLearner.updateModel(newData)
itemProbEstimated = logisticDist.callDataFunctionOutput('getItemProbabilities', newData);

figure
hold all
h(1)    = plot(states(:,1), labels, '*');
h(2)    = plot(states(:,1), itemProbEstimated(:,1), '*');
legend('InputData', 'Estimated Data');
% itemProb = logisticDist.callDataFunctionOutput('getItemProbabilities', newData);
% % E = -sum(sum(labels .* log(itemProb),2))
% logisticLearner.updateModel(newData)
% itemProb = logisticDist.callDataFunctionOutput('getItemProbabilities', newData);
% % E = -sum(sum(labels .* log(itemProb),2))
% 
% logisticDist.callDataFunction('sampleFromDistribution', newData);
% 
% %%
% 
% labelHat  = logisticDist.callDataFunctionOutput('getItemProbabilities', newData);
% 
% 
% 
% figure(2)
% clf
% hold all
% plot(states,labels, '*')
% plot(states,labelHat, 'o')

%%
newData = dataManager.getDataObject(numSamplesTest);
states = (rand(numSamplesTest, dataManager.getNumDimensions('states'))-0.5) * 100; 
states = sort(states);
newData.setDataEntry('states', states);
% states = newData.getDataEntry('states');
% logisticDist.callDataFunction('sampleFromDistribution', newData);
theta = rand(1,dataManager.getNumDimensions(logisticDist.inputVariables{1})) -0.5;
logisticDist.setTheta(theta);
itemProb = logisticDist.callDataFunctionOutput('getItemProbabilities', newData);


thetaStart = rand(1,dataManager.getNumDimensions(logisticDist.inputVariables{1})) -0.5;
logisticDist.setTheta(thetaStart);
newData.setDataEntry('terminationsDesiredProbs', itemProb(:,1));
logisticLearner.updateModel(newData)
itemProbEstimated = logisticDist.callDataFunctionOutput('getItemProbabilities', newData);

figure
hold all
clear h
h(1)    = plot(states(:,1), itemProb(:,1), '*');
h(2)    = plot(states(:,1), itemProbEstimated(:,1), '*');
legend('InputData', 'Estimated Data');

% theta
% logisticDist.theta
if( abs(theta - logisticDist.theta) > theta/10 )
    warning('large error')
end
figure
plot(logisticLearner.logLikelihoodIterations)
