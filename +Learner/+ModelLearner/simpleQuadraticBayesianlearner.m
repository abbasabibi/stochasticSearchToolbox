

classdef simpleQuadraticBayesianlearner < Learner.SupervisedLearner.SupervisedLearner
    
   
     properties
       
        parameterPrior = 0;
        
    end
    
    properties(SetObservable, AbortSet)
        
        inputDataNormalization = true;
        outputDataNormalization = false;
        
        %SIGMA = 1; % noise ~ N(0,SIGMA)
        %TAU = 10e-4
        bayesNoiseSigma =100;
        bayesParametersSigma = 100;
        
        numContext = 0;
        
        numStep = 1;
        
        trainX;
        trainY;
        weights;
        numPara;
    end
    
    % Class methods
    methods
        function obj = simpleQuadraticBayesianlearner(dataManager, linearfunctionApproximator, varargin)
            
            obj = obj@Learner.SupervisedLearner.SupervisedLearner(dataManager, linearfunctionApproximator, varargin{:});
            
            obj.linkProperty('bayesNoiseSigma');
            obj.linkProperty('bayesParametersSigma');

            obj.linkProperty('numContext');

            obj.numPara = dataManager.getNumDimensions('parameters');
            
            obj.numContext = obj.dataManager.getNumDimensions('contexts');
            obj.parameterPrior = zeros(1,0.5*obj.numPara*(obj.numPara+1) + obj.numPara + 1);
            
        end
        
%             function [] = updateModel(obj, data)
%             % alternate function call for learnFunction()
%           %  obj.learnFunction(obj,contexts,parameters,returns,inputWeights)
%           contexts = data.getDataEntry('contexts');
%           weights = data.getDataEntry('importanceWeights');
%           parameters = data.getDataEntry('parameters');
%           returns = data.getDataEntry('returns');
%           
%           [values indices] =  sort(weights,'descend');
%           
%           numSamplesToKeep = min(size(returns,1),3000);
%           obj.learnFunction(contexts(indices(1:numSamplesToKeep),:),parameters(indices(1:numSamplesToKeep),:),returns(indices(1:numSamplesToKeep),:),weights(indices(1:numSamplesToKeep),:));
%            
%             end
        
            
        
        function [features]= Quadratic(obj, inputMatrix)
            
            numStates = size ( inputMatrix , 2 );
            numFeatures = 2 * numStates + numStates * (numStates - 1 ) / 2;
            features = zeros(size(inputMatrix,1), numFeatures);
            
            index = 0;
            
            features(:, index +  (1:numStates)) = inputMatrix(:,1:numStates);
            
            index = index + numStates + 1;
            
            for i = 1:numStates
                features(:, index : (index + numStates - i)) = bsxfun(@times, inputMatrix(:, i:numStates), inputMatrix(:, i));
                index = index + numStates - i + 1;
            end
            
        end
        
        

        
        
        
        
        
        function [parameters] = bayesianLearner(obj, inputData, outputData, importanceWeights)
            %weights = exp(outputData);
            
            
            
           % [~,index] = sort(outputData,'descend');
            
            trainX = inputData;
            trainY = outputData;
           % weights = weights(index(1:15));
            weights = bsxfun(@times, -(1./(outputData)) , importanceWeights );
            
            tauThetaMat = eye(size(inputData,2)) * obj.bayesParametersSigma;
            tauThetaMat(1,1) = 10^10;
            
            A = ( 1/obj.bayesNoiseSigma ) * ( (bsxfun(@times,trainX,weights))'*trainX ) + inv(tauThetaMat);
            parameters = A\(tauThetaMat\obj.parameterPrior') + (1/obj.bayesNoiseSigma)*eye(size(A,1)) / A * (bsxfun(@times,trainX,weights))' * trainY ;
           % parameters =(1/obj.bayesNoiseSigma)*eye(size(A,1)) / A * (bsxfun(@times,trainX,weights))' * trainY ;

            
            
        end
        
        function [dataMean stDev normData] = normalization(obj, inputMatrix, weights)
            
            %dataMean = mean(inputMatrix,1);
            weights = weights/sum(weights);
            dataMean =  sum(bsxfun(@times,inputMatrix,weights),1) ;
            
            %stDev    = std(inputMatrix,1,1) ;
            
            stDev = sqrt(sum(bsxfun(@times,bsxfun(@minus,inputMatrix,dataMean).^2,weights)));
            
            normData = inputMatrix  - repmat(dataMean , size(inputMatrix,1) , 1 );
            normData = normData    ./  repmat(stDev,size(inputMatrix,1), 1 );
            
            
        end
        
        
        function value = getContextModelExpectation (obj,inputData, outputData)
            
            
            
            trainX = inputData ;
            trainY = outputData ;
            
            
            meanInput =zeros(1,size(inputData,2));
            stdInput  = ones(1,size(inputData,2));
            meanOutput = zeros(1,size(outputData,2));
            stdOutput = ones(1,size(outputData,2));
            
            
            if (obj.inputDataNormalization)
                
                [meanInput stdInput trainX] = obj.normalization(trainX) ;
                
            end
            
            if (obj.outputDataNormalization)
                
                [meanOutput stdOutput trainY] = obj.normalization(outputData) ;
                
            end
    
            
            quadProjTrainX = obj.Quadratic(trainX);
            quadProjTrainX = [ones(size(quadProjTrainX,1),1) quadProjTrainX];
            
            
            parameters = obj.bayesianLearner(quadProjTrainX,trainY);
            
            value = quadProjTrainX * parameters ;
            value = value .* stdOutput + meanOutput;
            
            
            
            
        end
        

   function [] = learnFunction(obj,parameters,returns,inputWeights)
            
  
       
       if(nargin < 4)
       
            inputWeights = ones(size(returns,1),1);
           
       else
           inputWeights = inputWeights./sum(inputWeights);
       
          
           
       end
            inputData = [parameters];
            outputData  = returns;
            
            lambda = size(outputData,1);
            
            %[~,index] = sort(outputData,'descend');     
            %inputData = inputData(index(1:lambda),:);
            %outputData = outputData(index(1:lambda));
            %inputWeights =inputWeights(index(1:lambda));
           % weights = weights(index(1:lambda));
       
            %obj.bayesNoiseSigma = std(returns);
            %if(obj.numContext>0)
                
             %   value = obj.getContextModelExpectation(inputData(:,1:obj.numContext),outputData);
             %   outputData = outputData - value;
                
            %end
            
            meanInput =zeros(1,size(inputData,2));
            stdInput  = ones(1,size(inputData,2));
            meanOutput = zeros(1,size(outputData,2));
            stdOutput = ones(1,size(outputData,2));
            
            
            
            
            
            
 
            
   
            
            trainX = inputData;%(:,1+obj.numContext:end) ;
            trainY = outputData ;
            
            
            
            if (obj.inputDataNormalization)
                
                [meanInput stdInput trainX] = obj.normalization(trainX,inputWeights) ;
                
            end
            
            if (obj.outputDataNormalization)
                
                [meanOutput stdOutput trainY] = obj.normalization(outputData,inputWeights) ;
                
            end
            
            obj.trainX = trainX;
            obj.trainY = trainY;
            obj.weights = inputWeights;
            
            context =[];
    
            trainX = [context trainX];
   
            quadProjTrainX = obj.Quadratic(trainX);
            quadProjTrainX = [ones(size(quadProjTrainX,1),1) quadProjTrainX];
                
                
            parameters = obj.bayesianLearner(quadProjTrainX,trainY,inputWeights);
               % priorParameters(i,:) = parameters;
            bias = parameters (1);
            r = (parameters (2:obj.numPara+1))';
                
            AQuadratic = zeros(obj.numPara);
            ind = logical(tril(ones(obj.numPara)));
            AQuadratic(ind) = parameters (obj.numPara+2:end);
            R = (AQuadratic + AQuadratic') / 2;

            stdInputinvmat = diag((1./stdInput));
            stdOutputmat = diag(stdOutput) ;
            
            A= (stdInputinvmat * R *stdInputinvmat);
            newR =stdOutputmat* A ;
            newr = -stdOutputmat* (meanInput*A' +meanInput*A -r*stdInputinvmat);
            newBias =stdOutputmat* (meanInput*A*meanInput' - r*stdInputinvmat*meanInput' + bias)+meanOutput;
            
            obj.functionApproximator.setParameters(newR, newr,newBias);
            
            
        end
    end
    
end
