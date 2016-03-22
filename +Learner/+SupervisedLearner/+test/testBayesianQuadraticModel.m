clear Test;
close all;

% [X,Y] = LoadData;
% 
% dataSet =[X Y];
% 
% dataSet = unique (dataSet , 'Rows');
% 
% dataSet = dataSet(randperm(size(dataSet, 1)), :);
% 
% X = dataSet (:,1:end-1);
% Y = dataSet (:,end:end);
% 
% 
% trainX = X;
% trainY = Y;
% 
% 
% numTrainSamples = 100
% 
% trainX = X(1:numTrainSamples,:);
% trainY = Y(1:numTrainSamples,:);
% 
% testX = X(numTrainSamples+1:150,:);
% testY = Y(numTrainSamples+1:150,:);

bayesianAvgErr = 0;
bestAvgErr     = 0;
PCAavgErr      = 0;
for i=1 : 50
i
    
Xinput = -3.4 : 0.01 :3.4 ;



noiseTerm =  randn(1,length(Xinput)) *2; 

%noiseTerm = 0;
%Yinput = sin(Xinput) + noiseTerm ; 
Yinput =(Xinput).^2 + noiseTerm ; 
%noiseTerm =  randn(1,length(Xinput)) / 10 ; 

Yinput = Yinput' ;
Xinput = Xinput' ;
Xinput = [Xinput Xinput+randn(length(Xinput),1)/10 2.*Xinput 2.*Xinput+Xinput+randn(length(Xinput),1)/20 1.5.*Xinput+randn(length(Xinput),1)/15 -0.5.*Xinput];

permSamples  = randperm(size( Xinput , 1 )) ;
luckySamples = permSamples (1:floor(0.5 * size( Xinput , 1 )));

trainX = Xinput(luckySamples,:);
trainY = Yinput(luckySamples,:);

testX = Xinput ;
testY = Yinput ;

testX(luckySamples , :) = []; % :-)
testY(luckySamples , :) = [];


dataManager = Data.DataManager('steps');

%dataManager.addDataEntry('contexts', 1);
dataManager.addDataEntry('parameters', 6);
dataManager.addDataEntry('returns', 1);

%dataManager.addDataEntry('contextsTest', 1);
dataManager.addDataEntry('parametersTest',6);
dataManager.addDataEntry('returnsTest', 1);

dataManager.finalizeDataManager();



% load data and set them in the datastrucuture, create data with correct
% size
newData = dataManager.getDataObject(size(trainX,1));
%newData.setDataEntry('contexts', trainX(:,1));
newData.setDataEntry('parameters', trainX);
newData.setDataEntry('returns', trainY);

testData = dataManager.getDataObject(size(testX,1));
%testData.setDataEntry('contexts', testX(:,1));
testData.setDataEntry('parameters', testX);
testData.setDataEntry('returns', testY);

quadraticFunction = Functions.LowDimSquaredFunction.BayesianLowDimSquaredFunction(dataManager, 'returns', {'parameters'}, 'squaredFunction');
quadraticFunction.initObject();



quadraticFunctionLearner = Learner.SupervisedLearner.BayesianLearner.LowDimBayesianLearner(dataManager, quadraticFunction);
quadraticFunctionLearner.updateModel(newData);
value=quadraticFunction.callDataFunctionOutput('getExpectation', testData);
%  plot(testX(:,1),(testX(:,1)).^2 ,'.k')
%     hold
%     plot(testX(:,1),value,'.')
%     plot(testX(:,1),testY , '.r')
    
     bayesianAvgErr= bayesianAvgErr + var(value - testY)/var(testY);

quadraticFunctionLearner = Learner.SupervisedLearner.BayesianLearner.BestLowDimProjector(dataManager, quadraticFunction);
quadraticFunctionLearner.updateModel(newData);
value=quadraticFunction.callDataFunctionOutput('getExpectation', testData);
%  plot(testX(:,1),(testX(:,1)).^2 ,'.k')
%     hold
%     plot(testX(:,1),value,'.')
%     plot(testX(:,1),testY , '.r')
    bestAvgErr =bestAvgErr+ var(value - testY)/var(testY);
    
quadraticFunctionLearner = Learner.SupervisedLearner.BayesianLearner.PCAproj(dataManager, quadraticFunction);    
quadraticFunctionLearner.updateModel(newData);
value=quadraticFunction.callDataFunctionOutput('getExpectation', testData);
%  plot(testX(:,1),(testX(:,1)).^2 ,'.k')
%     hold
%     plot(testX(:,1),value,'.')
%     plot(testX(:,1),testY , '.r')
    PCAavgErr =  PCAavgErr + var(value - testY)/var(testY);
    
end

bayesianAvgErr = bayesianAvgErr / 50 
bestAvgErr     = bestAvgErr /50
PCAavgErr      = PCAavgErr /50
%value=quadraticFunction.getExpectation(2,testX);


% bayesianAvgErr= var (value - testY)/var(testY)
% 
% quadraticFunctionLearner = Learner.SupervisedLearner.BayesianLearner.BestLowDimProjector(dataManager, quadraticFunction);
% quadraticFunctionLearner.updateModel(newData);
% value=quadraticFunction.getExpectation(2,testX);
% bestAvgErr = var (value - testY)/var(testY)
% 
% 
% quadraticFunctionLearner = Learner.SupervisedLearner.BayesianLearner.PCAproj(dataManager, quadraticFunction);
% quadraticFunctionLearner.updateModel(newData);
% value=quadraticFunction.getExpectation(2,testX);
% PCAavgErr = var (value - testY)/var(testY)

