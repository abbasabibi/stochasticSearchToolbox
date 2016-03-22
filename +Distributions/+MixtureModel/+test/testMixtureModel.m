clear variables;
close all;

dataManager = Data.DataManager('steps');
settings = Common.Settings.createNewSettings();


dataManager.addDataEntry('states', 2);
dataManager.addDataEntry('actions', 2);
dataManager.addDataEntry('options', 1, 1, 3);
settings.setProperty('numOptions',3);
dataManager.addDataEntry('rewardWeighting', 1);

dataManager.addDataEntry('logQAso', 1);

dataManager.finalizeDataManager();

newData = dataManager.getDataObject(100);
newData.setDataEntry('states', randn(100,2));


newData.setDataEntry('options', randi(settings.getProperty('numOptions'),100,1));


% optionInitializer = @Distributions.Gaussian.GaussianLinearInFeatures;
% 
% 
% gatingDist    = Distributions.Discrete.ConstantDiscreteDistribution(dataManager, 'options', 'Gating');
% gatingLearner = Learner.ClassificationLearner.PriorDistributionLearner(dataManager, gatingDist, false); %false or true???
% 
% mixtureModel = Distributions.MixtureModel.MixtureModel(dataManager, gatingDist, optionInitializer, 'actions', 'states', 'options');

%%

gaussianDist  = Distributions.Gaussian.GaussianLinearInFeatures(dataManager, 'actions', 'states', 'ActionPolicy');

optionLearner = Learner.SupervisedLearner.LinearGaussianMLLearner(dataManager, gaussianDist);
optionInitializer = @Distributions.Gaussian.GaussianLinearInFeatures;

gatingDist    = Distributions.Discrete.ConstantDiscreteDistribution(dataManager, 'options', 'Gating');
gatingLearner = Learner.ClassificationLearner.PriorDistributionLearner(dataManager, gatingDist, false); %false or true???


mixtureModel  = Distributions.MixtureModel.MixtureModel(dataManager, gatingDist, optionInitializer, 'actions', 'states', 'options');
mixtureModelLearner = Learner.SupervisedLearner.MixtureModelLearner(dataManager, mixtureModel, optionLearner, gatingLearner, 'responsibilities');


%%

mixtureModel.initObject();
gatingDist.initObject();

mixtureModel.callDataFunction('sampleFromDistribution', newData);
mixtureModel.callDataFunction('getDataProbabilities', newData);
