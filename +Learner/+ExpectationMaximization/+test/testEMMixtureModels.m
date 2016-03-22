clear variables;
close all;

dataManager = Data.DataManager('steps');
settings = Common.Settings();

%rng(2);
dimState    = 0; 

dimAction   = 2;
% dataManager.addDataEntry('states', dimState);
dataManager.addDataEntry('actions', dimAction);
dataManager.addDataEntry('options', 1, 1, 3);
dataManager.addDataEntry('rewardWeighting', 1);

settings.setProperty('numOptions',3);
% dataManager.addDataEntry('responsibilities', settings.getProperty('numOptions') ); %Is that correct?

dataManager.addDataEntry('rewardWeighting', 1);

dataManager.finalizeDataManager();

numSamples = 100;
newData = dataManager.getDataObject(numSamples);
% newData.setDataEntry('states', randn(numSamples,dimState));
%newData.setDataEntry('options', randi(settings.getProperty('numOptions'),numSamples,1));

%gaussian doesnt update cov
%likelihood doesnt have 2*pi in calculation

gaussianDist  = Distributions.Gaussian.GaussianLinearInFeatures(dataManager, 'actions', '', 'ActionPolicy');
%we dont want no states for now
% gaussianDist  = Distributions.Gaussian.GaussianStateDistribution %<- DOESNT WORK I WANT A DIST JUST OVER ACTIONS
% gaussianDist  = @Distributions.Gaussian.GaussianLinearInFeatures;
optionLearner = Learner.SupervisedLearner.LinearGaussianMLLearner(dataManager, gaussianDist);
optionInitializer = @Distributions.Gaussian.GaussianLinearInFeatures;
%this seems a bit weird. We first have to create a dist to init the
%learner, but then the mmlearner will set a different dist for the
%optionlearner. 

gatingDist    = Distributions.Discrete.ConstantDiscreteDistribution(dataManager, 'options', 'Gating');
gatingLearner = Learner.ClassificationLearner.PriorDistributionLearner(dataManager, gatingDist, false); %false or true???

% The mixture model now also contains the gating. the gating can be also
% state dependend!
mixtureModel  = Distributions.MixtureModel.MixtureModel(dataManager, gatingDist, optionInitializer, 'actions', '', 'options');
mixtureModelLearner = Learner.SupervisedLearner.MixtureModelLearner(dataManager, mixtureModel, optionLearner, gatingLearner, 'responsibilities');

settings.setProperty('keepOptionsShape', 0);
EMLearner     = Learner.ExpectationMaximization.EMMixtureModels(dataManager, mixtureModel, mixtureModelLearner);

mixtureModel.initObject();
gatingDist.initObject();


% sampleFromDistribution is now a function alias, that points first to the
% sample function from the gating and then to the sample function of the
% mixture components (which also takes the actions). Hence, both entries
% are created, the options and the actions
mixtureModel.callDataFunction('sampleFromDistribution', newData);

qSA = mixtureModel.callDataFunctionOutput('getDataProbabilities', newData);

%%
numOptions = 3;
samples = zeros(numSamples*numOptions,dimState+dimAction);
responsibilities = ones(numSamples*numOptions,numOptions);
for o = 1 : numOptions 
    mu(o, :) = randn(1,dimState+dimAction) * 10;
    sigma = [3, 0; 0, 1] * 30;
    sigmaCorr = [0 , 1; 1, 0] * (rand * 2 - 1) * sqrt(sigma(1,1) * sigma(2,2));
%     sigmaCorr = rand(2)*4;
%     sigmaCorr = (sigmaCorr' + sigmaCorr)/2;
    sigma = sigma + sigmaCorr;
    idx = (o-1) * numSamples;
    samples(idx+1 : idx + numSamples,:) = mvnrnd(mu(o, :),sigma,numSamples);
    responsibilities(idx+1 : idx+numSamples,o) = ones(numSamples,1)*3;
end

responsibilities = bsxfun(@rdivide, responsibilities, sum(responsibilities,2));
newData = dataManager.getDataObject(numSamples*numOptions);
newData.setDataEntry('actions', samples);

%%
% 
EMLearner.setAnalyseModelFunction(@Learner.ExpectationMaximization.test.analyseModel2DMixtureModelStateFree);
EMLearner.setInitLearner(Learner.ExpectationMaximization.InitGMMLearner(dataManager, mixtureModelLearner));

EMLearner.setWeightName('rewardWeighting');
newData.setDataEntry('rewardWeighting', rand(300,1));

EMLearner.updateModel(newData);

figure;plot(EMLearner.logLikelihood);


%%
% 
% %First test the linear regression
% learnerFunction.updateModel(newData);
% 
% %this is what we set initially
% [weights, bias]
% 
% %this is what we estimated
% [gaussianDist.weights, gaussianDist.bias]
% 
% %Now test the estimation of the covariance (note: The distribution learner
% %does both for you, regression and covariance estimation
% learnerDistribution = Learner.SupervisedLearner.LinearGaussianMLLearner(dataManager, gaussianDist);
% learnerDistribution.updateModel(newData);
% 
% %this is what we set initially
% [Sigma2]
% 
% %this is what we estimated
% [gaussianDist.getCovariance()]
% 
% % Now do the same stuff with a weighting
% 
% newData.setDataEntry('rewardWeighting', ones(newData.getNumElements(),1));
% learnerDistribution.setWeightName('rewardWeighting');
% learnerDistribution.updateModel(newData);
% 
% %this is what we set initially
% [Sigma2]
% 
% %this is what we estimated
% [gaussianDist.getCovariance()]

