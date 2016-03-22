%load('/home/abdolmaleki/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ModelBaseREPSForReachingTaskWithoutNoise/numSamples_201405150041_01/eval001/trial010/trial.mat')
%
load('/home/abdolmaleki/policysearchtoolbox/+Experiments/data/test/PlanarReaching_ModelBaseREPSForReachingTaskWithoutNoise/numSamples_201405151504_01/eval001/trial001/trial.mat')
%

numTrainingSet = 20; 
avgOutPutbayesian = zeros(numTrainingSet,50);
avgOutPutPCA = zeros(numTrainingSet,1);
avgOutPutbayesianPCA = zeros(numTrainingSet,50);
for k = 1:numTrainingSet
    
trainData = trial.dataManager.getDataObject();
trial.sampler.numSamples = 100 ;
trial.sampler.createSamples(trainData);

testData = trial.dataManager.getDataObject();
trial.sampler.numSamples = 100 ;
trial.sampler.createSamples(testData);


%% PCA
PCArewardFunctionLearner = Learner.SupervisedLearner.BayesianLearner.PCAproj(trial.dataManager,trial.learnedRewardFunction) ;
PCArewardFunctionLearner.numPara = 7;
PCArewardFunctionLearner.updateModel(trainData);
outPut = trial.learnedRewardFunction.callDataFunctionOutput('getExpectation',testData);
avgOutPutPCA(k) = var(testData.getDataEntry('returns')-outPut)/var(testData.getDataEntry('returns'));

%% Bayesian
rewardFunctionLearner = Learner.SupervisedLearner.BayesianLearner.LowDimBayesianLearner(trial.dataManager,trial.learnedRewardFunction) ;
rewardFunctionLearner.numProjMat = 1000 ;
rewardFunctionLearner.bayesNoiseSigma = 10^-2 %10^-3;
rewardFunctionLearner.bayesParametersSigma =1 % 10^-4;
rewardFunctionLearner.numPara =7;


for(i=1 : 50)
    rewardFunctionLearner.updateModel(trainData);
    outPut = trial.learnedRewardFunction.callDataFunctionOutput('getExpectation',testData);
    avgOutPutbayesian(k,i) = var(testData.getDataEntry('returns')-outPut)/var(testData.getDataEntry('returns'));
    i
end

%% BayesianPCA 
rewardFunctionLearner = Learner.SupervisedLearner.BayesianLearner.LowDimBayesianPCALearner(trial.dataManager,trial.learnedRewardFunction) ;
rewardFunctionLearner.numProjMat = 1000 ;
rewardFunctionLearner.bayesNoiseSigma = 10^-2; %10^-3;
rewardFunctionLearner.bayesParametersSigma =1; % 10^-4;
rewardFunctionLearner.numPara =7;

for(i=1 : 50)
    rewardFunctionLearner.updateModel(trainData);
    outPut = trial.learnedRewardFunction.callDataFunctionOutput('getExpectation',testData);
    avgOutPutbayesianPCA(k,i) = var(testData.getDataEntry('returns')-outPut)/var(testData.getDataEntry('returns'));
    i
end

LearningNum = k

end