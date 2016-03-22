

classdef ConvexQuadraticModelLearner < Learner.SupervisedLearner.SupervisedLearner
    
    
    properties
        
        parameterPrior = 0;
        
        R;
        r;
        r0;
        
    end
    
    properties(SetObservable, AbortSet)
        
        inputDataNormalization = true;
        outputDataNormalization = false;
        
        %SIGMA = 1; % noise ~ N(0,SIGMA)
        %TAU = 10e-4
        bayesNoiseSigma =10000;
        bayesParametersSigma = 10000;
        
        trainX;
        trainY;
        
        weights;
        numPara;
        
    end
    
    % Class methods
    methods
        function obj = ConvexQuadraticModelLearner(dataManager, linearfunctionApproximator, varargin)
            
            obj = obj@Learner.SupervisedLearner.SupervisedLearner(dataManager, linearfunctionApproximator, varargin{:});
            
            obj.linkProperty('bayesNoiseSigma');
            obj.linkProperty('bayesParametersSigma');
            
            % obj.linkProperty('numContext');
            
            obj.numPara = dataManager.getNumDimensions('parameters');
            
            %obj.numContext = obj.dataManager.getNumDimensions('contexts');
            
            obj.R = zeros(obj.numPara);
            obj.r = zeros(obj.numPara , 1);
            obj.r0 = 0;
            
            obj.parameterPrior = zeros(1,0.5*obj.numPara*(obj.numPara+1) + obj.numPara + 1);
            
        end
        
        
        
        
        function [features]= Quadratic(obj, inputMatrix)
            %Quadratic and linear features
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
        
        function [features]= linearFeatures(obj, inputMatrix)
            %linear features

            numStates = size ( inputMatrix , 2 );
            numFeatures = numStates + 1;
            features = zeros(size(inputMatrix,1), numFeatures);
            
            
            features(:,1) = ones(size(features,1),1) ;
            features(:, 2:numFeatures) = inputMatrix(:,1:numStates);
            
            
        end
        
        function [features]= quadraticFeatures(obj, inputMatrix)
            %Quadratic features

            numStates = size ( inputMatrix , 2 );
            numFeatures = numStates + numStates * (numStates - 1 ) / 2;
            
            features = zeros(size(inputMatrix,1), numFeatures);
            
            index = 1;
            
            for i = 1:numStates
                features(:, index : (index + numStates - i)) = bsxfun(@times, inputMatrix(:, i:numStates), inputMatrix(:, i));
                index = index + numStates - i + 1;
            end
            
        end
        
        
        function [parameters] = bayesianLearner(obj, inputData, outputData, outputWeights, importanceWeights)
           
            %Bayesian linear regression
            obj.parameterPrior = zeros(1,size(inputData,2));
            
            trainX = inputData;
            trainY = outputData;
     
            weights = outputWeights;
        
            
            tauThetaMat = eye(size(inputData,2)) * obj.bayesParametersSigma;
            tauThetaMat(1,1) = 10^10;
            
            A = ( 1/obj.bayesNoiseSigma ) * ( (bsxfun(@times,trainX,weights))'*trainX ) + inv(tauThetaMat);
            parameters = A\(tauThetaMat\obj.parameterPrior') + (1/obj.bayesNoiseSigma)*eye(size(A,1)) / A * (bsxfun(@times,trainX,weights))' * trainY ;
            
            
            
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
        
        
        
        
        function [] = learnFunction(obj,parameters,returns,inputWeights)
            
            
            
            if(nargin < 4)
                
                inputWeightsImportance = ones(size(returns,1),1);
                
            else
                inputWeightsImportance = inputWeights./sum(inputWeights);
                
            end
            
            inputData = [parameters];
            outputData  = returns;
            
            
            meanInput =zeros(1,size(inputData,2));
            stdInput  = ones(1,size(inputData,2));
            meanOutput = zeros(1,size(outputData,2));
            stdOutput = ones(1,size(outputData,2));
            
            trainX = inputData;%(:,1+obj.numContext:end) ;
            trainY = outputData ;
            
            
            if (obj.inputDataNormalization)
                
                [meanInput stdInput trainX] = obj.normalization(trainX,inputWeightsImportance) ;
                
            end
            
            if (obj.outputDataNormalization)
                
                [meanOutput stdOutput trainY] = obj.normalization(outputData,inputWeightsImportance) ;
                
            end
            
            obj.trainX = trainX;
            obj.trainY = trainY;
            
            % Approximate multiplicative noise model. Use absolute value as
            % weighting
          
            absReward = abs(trainY - max(trainY) - 0.01 * (max(trainY) - min(trainY)));
        
            inputWeights = (1./(absReward));
        
            inputWeights = inputWeights .* inputWeightsImportance;
            
            quadProjTrainX = obj.Quadratic(trainX);
            quadProjTrainX = [ones(size(quadProjTrainX,1),1) quadProjTrainX];
            
            
            parameters = obj.bayesianLearner(quadProjTrainX,trainY,inputWeights);
            % priorParameters(i,:) = parameters;
            obj.r0 = parameters (1);
            obj.r = (parameters (2:obj.numPara+1))';
            
            AQuadratic = zeros(obj.numPara);
            ind = logical(tril(ones(obj.numPara)));
            AQuadratic(ind) = parameters (obj.numPara+2:end);
            obj.R = (AQuadratic + AQuadratic') / 2;
            
            [U, D] = eig(obj.R);
            D(D > 0) = -1e-8;
            obj.R = U * D * U';
            
            
            quadraticOutput = diag(trainX * obj.R * trainX') ;
            quadProjTrainX = obj.linearFeatures(trainX);
            parameters = obj.bayesianLearner(quadProjTrainX,trainY - quadraticOutput,inputWeights,inputWeights);
            % priorParameters(i,:) = parameters;
            obj.r0 = parameters (1);
            obj.r = (parameters (2:end))';
            
            %             for(i = 1:1000)
            %
            %               quadraticOutput = diag(trainX * obj.R * trainX') ;
            %               quadProjTrainX = obj.linearFeatures(trainX);
            %               parameters = obj.bayesianLearner(quadProjTrainX,trainY - quadraticOutput,inputWeights,inputWeights);
            %             % priorParameters(i,:) = parameters;
            %               obj.r0 = parameters (1);
            %               obj.r = parameters (2:end)';
            %
            %               linearOutput = trainX * obj.r' + obj.r0   ;
            %               quadProjTrainX = obj.quadraticFeatures(trainX);
            %               parameters = obj.bayesianLearner(quadProjTrainX,trainY - linearOutput,inputWeights,inputWeights);
            %
            %               AQuadratic = zeros(obj.numPara);
            %               ind = logical(tril(ones(obj.numPara)));
            %               AQuadratic(ind) = parameters;
            %               obj.R = (AQuadratic + AQuadratic') / 2;
            %
            %               [U, D] = eig(obj.R);
            %               D(D > 0) = -1e-15;
            %               obj.R = U * D * U';
            %
            %                 %loop over learning linear and quadratic part
            %
            %             end
            
            
            stdInputinvmat = diag((1./stdInput));
            stdOutputmat = diag(stdOutput) ;
            
            A= (stdInputinvmat * obj.R *stdInputinvmat);
            newR =stdOutputmat* A ;
            newr = -stdOutputmat* (meanInput*A' +meanInput*A -obj.r*stdInputinvmat);
            newBias =stdOutputmat* (meanInput*A*meanInput' - obj.r*stdInputinvmat*meanInput' + obj.r0)+meanOutput;
            
            obj.functionApproximator.setParameters(newR, newr,newBias);
            
            
       
        end
        
        function [g, gD] = quadraticObjFunc(obj, params)
            
            r0 = params (1);
            r = (params (2:obj.numPara+1))';
            
            B = triu(ones(obj.numPara,obj.numPara));
            
            A = B ;
            A(B==1) = params(obj.numPara+2:end);
            
            R = A'*A;
            
            quadraticOutput = diag(obj.trainX * obj.R * obj.trainX') ;
            LinearOutput = obj.trainX*r';
            
            g = 0.5 * sum(((quadraticOutput' + LinearOutput + r0) - obj.trainY) ^ 2);
            
            % computeDeravitives
            dA = 4 * g * A * obj.trainX * obj.trainX' ;
            v = dA(B==1) ;
            dr = 2 * g * sum(obj.trainX' , 1);
            dr0 = 2 * g;
            
            gD = [dr0; dr; v];
            
            
            
        end
        
        
    end
    
end
