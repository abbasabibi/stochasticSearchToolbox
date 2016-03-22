clear variables;
close all;

dataManager = Data.DataManager('steps');

dataManager.addDataEntry('states', 2);
dataManager.addDataEntry('actions', 2);

dataManager.addDataEntry('rewardWeighting', 1);
dataManager.finalizeDataManager();

newData = dataManager.getDataObject(1000);
newData.setDataEntry('states', randn(1000,2));

gaussianDistribution = Distributions.Gaussian.GaussianLinearInFeatures(dataManager, 'actions', {'states'}, 'ActionPolicy');

gaussianDistribution.initObject();

weights = randn(gaussianDistribution.dimOutput, gaussianDistribution.dimInput);
bias =  randn(gaussianDistribution.dimOutput,1);
Sigma2 = [0.02, 0.01; 0.01, 0.04];

gaussianDistribution.setWeightsAndBias(weights, bias);
gaussianDistribution.setCovariance(Sigma2);

gaussianDistribution.callDataFunction('sampleFromDistribution', newData);

%First test the linear regression
learnerFunction = Learner.SupervisedLearner.LinearFeatureFunctionMLLearner(dataManager, gaussianDistribution);
learnerFunction.updateModel(newData);

%this is what we set initially
[weights, bias]

%this is what we estimated
[gaussianDistribution.weights, gaussianDistribution.bias]

%Now test the estimation of the covariance (note: The distribution learner
%does both for you, regression and covariance estimation
learnerDistribution = Learner.SupervisedLearner.LinearGaussianMLLearner(dataManager, gaussianDistribution);
learnerDistribution.updateModel(newData);

%this is what we set initially
[Sigma2]

%this is what we estimated
[gaussianDistribution.getCovariance()]

% Now do the same stuff with a weighting

newData.setDataEntry('rewardWeighting', ones(newData.getNumElements(),1));
learnerDistribution.setWeightName('rewardWeighting');
learnerDistribution.updateModel(newData);

%this is what we set initially
[Sigma2]

%this is what we estimated
[gaussianDistribution.getCovariance()]

