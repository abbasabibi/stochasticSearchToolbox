

classdef NormalQuadraticModel < Learner.SupervisedLearner.SupervisedLearner
    
   
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
        function obj = NormalQuadraticModel(dataManager, linearfunctionApproximator, varargin)
            
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
       mu = floor(size(parameters,1)/2) + 1;
       
       returns =returns-max(returns)-10;
       weighting = bsxfun(@times, -(1./(returns)) , inputWeights);
       
      
       
      %[value,index] = max(returns);
      
      %expectedOutput =  parameters(index,:) ;
      %parameters(index,:) = [];
      %returns(index,:) = [];
      %weighting(index,:) = [];
      weighting = weighting./sum(weighting);
      expectedOutput =  sum(bsxfun(@times,parameters,weighting),1) ;
      % expectedOutput =  mean(parameters(index(1:mu),:),2) ;
       
       Z = ( sum(weighting)^2 - sum(weighting.^2));
       % weighting = weighting./sum(weighting);
       difference = parameters  - repmat(expectedOutput , size(parameters,1) , 1 );         
       %difference =  expectedOutput - outputData;
                
       SigmaA = bsxfun(@times, difference, weighting)' * difference + 1e-5 * eye(size(parameters,2)) ;
       SigmaA = 1 / Z * SigmaA+1e-3*eye(size(parameters,2));
       SigmaAinv = inv(SigmaA); 
    
       newBias = -0.5*(expectedOutput*SigmaAinv*expectedOutput' + size(parameters,2)*log(2*pi) + 2*sum(log(diag(chol(SigmaA)))) );
       obj.functionApproximator.setParameters(-0.5*SigmaAinv, expectedOutput*SigmaAinv,newBias);
            
            
        end
    end
    
end
