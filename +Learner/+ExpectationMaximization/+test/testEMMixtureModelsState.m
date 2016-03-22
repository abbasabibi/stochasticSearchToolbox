clear variables;
close all;

addpath('Helper');

dataManager = Data.DataManager('steps');
settings = Common.Settings();

dimState    = 1; 
dimAction   = 1;
numOptions  = 10;
dataManager.addDataEntry('states', dimState);
dataManager.addDataEntry('actions', dimAction);
dataManager.addDataEntry('options', 1, 1, numOptions);
settings.setProperty('numOptions', numOptions);
settings.setProperty('numIterationsEM',2e2);
settings.setProperty('logLikelihoodThresholdEM',1e-1);
settings.setProperty('softMaxRegressionTerminationFactor',1e-6);
settings.setProperty('debugPlottingMM',false);
% dataManager.addDataEntry('responsibilities', settings.getProperty('numOptions') ); %Is that correct?

dataManager.addDataEntry('rewardWeighting', 1);

dataManager.finalizeDataManager();

%newData.setDataEntry('options', randi(settings.getProperty('numOptions'),numSamples,1));

%gaussian doesnt update cov
%likelihood doesnt have 2*pi in calculation

gaussianDist  = Distributions.Gaussian.GaussianLinearInFeatures(dataManager, 'actions', 'states', 'ActionPolicy');
%we dont want no states for now
% gaussianDist  = Distributions.Gaussian.GaussianStateDistribution %<- DOESNT WORK I WANT A DIST JUST OVER ACTIONS
% gaussianDist  = @Distributions.Gaussian.GaussianLinearInFeatures;
optionLearner = Learner.SupervisedLearner.LinearGaussianMLLearner(dataManager, gaussianDist);
optionInitializer = @Distributions.Gaussian.GaussianLinearInFeatures;
%this seems a bit weird. We first have to create a dist to init the
%learner, but then the mmlearner will set a different dist for the
%optionlearner. 

squaredFeatures = FeatureGenerators.SquaredFeatures(dataManager, 'states', [], true);



gatingDist    = Distributions.Discrete.SoftMaxDistribution(dataManager, 'options', squaredFeatures.outputName, 'Gating');
gatingLearner = Learner.ClassificationLearner.MultiClassLogisticRegressionLearner(dataManager, gatingDist, true); %false or true???
% gatingLearner.softMaxRegressionLearningRate = 0.1;

gatingDist.setThetaAllItems(rand(dataManager.getMaxRange('options'),dataManager.getNumDimensions('statesSquared')) -0.5);


% The mixture model now also contains the gating. the gating can be also
% state dependend!
mixtureModel  = Distributions.MixtureModel.MixtureModel(dataManager, gatingDist, optionInitializer, 'actions', 'states', 'options');

mixtureModelLearner = Learner.SupervisedLearner.MixtureModelLearner(dataManager, mixtureModel, optionLearner, gatingLearner, 'responsibilities')
EMLearner     = Learner.ExpectationMaximization.EMMixtureModels(dataManager, mixtureModel, mixtureModelLearner);


mixtureModel.initObject();
gatingDist.initObject();


% sampleFromDistribution is now a function alias, that points first to the
% sample function from the gating and then to the sample function of the
% mixture components (which also takes the actions). Hence, both entries
% are created, the options and the actions
% mixtureModel.callDataFunction('sampleFromDistribution', newData);

% qSA = mixtureModel.callDataFunctionOutput('getDataProbabilities', newData);




numSamples = 100;
newData = dataManager.getDataObject(numSamples);
newData.setDataEntry('states', randn(numSamples,dimState));

%%

numSamples = 100;

x = linspace(0, 4*pi, numSamples);
% samples = [x', cos(x'); x', sin(x') + 10];
samples = [sin(x'), cos(x'); sin(x') + 0.78, cos(x') + 0.8];

%EMLearner.setAnalyseModelFunction(@Learner.ExpectationMaximization.test.analyseModel2DMixtureModelStateFree);
EMLearner.setInitLearner(Learner.ExpectationMaximization.InitGMMLearner(dataManager, mixtureModelLearner));

% responsibilities = bsxfun(@rdivide, responsibilities, sum(responsibilities,2));
newData = dataManager.getDataObject(size(samples,1));
newData.setDataEntry('states', samples(:,1));
newData.setDataEntry('actions', samples(:,2));

EMLearner.setWeightName('rewardWeighting');
newData.setDataEntry('rewardWeighting', rand(numSamples * 2,1));




% mixtureModelLearner.updateModel(newData);

EMLearner.updateModel(newData);



%%
% statesTest = rand(numSamples,1) * 4*pi;
% testData = dataManager.getDataObject(size(statesTest,1));
% testData.setDataEntry('states', statesTest);
% 
% mixtureModel.callDataFunction('sampleFromDistribution', testData);
% 
% 
% figure
% plot(testData.dataStructure.states, testData.dataStructure.actions,'*')

% plot(samples(:,1), samples(:,2),'*')
% hold all
% for o = 1 : numOptions
%     plot(mixtureModel.getOption(o).bias(1),mixtureModel.getOption(o).bias(2),'r*')
% end

%%
figure; plot(EMLearner.logLikelihood)
%%


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

