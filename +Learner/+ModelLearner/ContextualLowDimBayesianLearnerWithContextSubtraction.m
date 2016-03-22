

classdef ContextualLowDimBayesianLearnerWithContextSubtraction < Learner.SupervisedLearner.SupervisedLearner
    
    properties(SetObservable, AbortSet)
        
        inputDataNormalization = true;
        outputDataNormalization = false;
        
        %SIGMA = 1; % noise ~ N(0,SIGMA)
        %TAU = 10e-4
        bayesNoiseSigma =1;
        bayesParametersSigma = 1;
        
        numPara = 3;
        numProjMat = 500;
        
        numContext = 0;
        
        projectContext = true;
    end
    
    % Class methods
    methods
        function obj = ContextualLowDimBayesianLearnerWithContextSubtraction(dataManager, linearfunctionApproximator, varargin)
            
            obj = obj@Learner.SupervisedLearner.SupervisedLearner(dataManager, linearfunctionApproximator,varargin{:});
            
            obj.linkProperty('bayesNoiseSigma');
            obj.linkProperty('bayesParametersSigma');
            obj.linkProperty('numPara');
            obj.linkProperty('numProjMat');
            obj.linkProperty('numContext');
            obj.linkProperty('projectContext');
            
            obj.numContext = obj.dataManager.getNumDimensions('contexts');
            obj.numPara = obj.numPara + obj.numContext;
            
        end
        
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
        
        
        
        
        function W = RandomProj(obj, desiredDim, currentDim)
            
            if (~obj.projectContext)
                W= randn (desiredDim-obj.numContext , currentDim);
                if(obj.numContext>0)
                    contextCol = zeros(obj.numContext,currentDim);
                    
                    
                    for i=1:obj.numContext
                        
                        contextCol(i,i) = 1;
                    end
                    
                    W = [contextCol;W];
                    
                end
            else
                W= randn (desiredDim , currentDim);
            end
        end
        
               
   
        function U = PCA(obj,X)
            
            [U,S,V] = svd(X'*X);
            
        end
        
        function [likelihood] = Weights(obj, inputData, outputData)
            
            sigmaMat = obj.bayesNoiseSigma * eye(size(outputData,1)) ;
            %sigmaMat(1,1) = 0;
            
            tauThetaMat = eye(size(inputData,2)) * obj.bayesParametersSigma;
            tauThetaMat(1,1) = 10^10;
            
            
            mean = zeros(1 , size(outputData,1));
            coavarianceMat = sigmaMat + inputData*tauThetaMat*inputData';
            
            cholCov = chol(coavarianceMat);
            v = 2 * sum(log(diag(cholCov)));
            xc = bsxfun(@minus, outputData',  mean);
            
            prodHalf = xc / cholCov;
            
            likelihood = -0.5 * (v + (prodHalf * prodHalf'));
            
        end
        
        
        function [parameters] = bayesianLearner(obj, inputData, outputData)
            
            
%                         trainX = inputData;
%                         trainY = outputData;
%             
%                         tauThetaMat = eye(size(inputData,2)) * obj.bayesParametersSigma;
%                         tauThetaMat(1,1) = 10^10;
%             
%                         A = ( 1/obj.bayesNoiseSigma ) * ( trainX'*trainX ) + inv(tauThetaMat);
%                         parameters = (1/obj.bayesNoiseSigma)*eye(size(A,1)) / A * trainX' * trainY ;
% 

            
            %weights = exp(outputData);
            %forWeighting = outputData;
            %forWeighting(forWeighting>=0) = -0.1;
            
            weights = -(1./(outputData));
            trainX = inputData;
            trainY = outputData; 
            parameterPrior = zeros(1,0.5*obj.numPara*(obj.numPara+1) + obj.numPara + 1);
            
            tauThetaMat = eye(size(inputData,2)) * obj.bayesParametersSigma;
            tauThetaMat(1,1) = 10^10;
            
            A = ( 1/obj.bayesNoiseSigma ) * ( (bsxfun(@times,trainX,weights))'*trainX ) + inv(tauThetaMat);
            parameters = A\(tauThetaMat\parameterPrior') + (1/obj.bayesNoiseSigma)*eye(size(A,1)) / A * (bsxfun(@times,trainX,weights))' * trainY ;
          
            
            % parameters =(1/obj.bayesNoiseSigma)*eye(size(A,1)) / A * (bsxfun(@times,trainX,weights))' * trainY ;

            
            
            
        end
        
        function [dataMean stDev normData] = normalization(obj, inputMatrix)
            
            dataMean = mean(inputMatrix,1);
            stDev    = std(inputMatrix,1,1) ;
            
            
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
            
            
            if (true)
                
                [meanInput stdInput trainX] = obj.normalization(trainX) ;
                
            end
            
            if (true)
                
                [meanOutput stdOutput trainY] = obj.normalization(outputData) ;
                
            end
            
            quadProjTrainX = obj.Quadratic(trainX);
            quadProjTrainX = [ones(size(quadProjTrainX,1),1) quadProjTrainX];
            
            
            parameters = obj.bayesianLearner(quadProjTrainX,trainY);
            
            value = quadProjTrainX * parameters ;
            value = value .* stdOutput + meanOutput;
            
            
            
            
        end
        
        
   function [] = learnFunction(obj,parameters,returns)
            
       
            inputData = [parameters];
            outputData  = returns;
            %obj.bayesNoiseSigma = std(returns);
            if(obj.numContext>0)
                
                value = obj.getContextModelExpectation(inputData(:,1:obj.numContext),outputData);
                outputData = outputData - value;
                
            end
            
            meanInput =zeros(1,size(inputData,2));
            stdInput  = ones(1,size(inputData,2));
            meanOutput = zeros(1,size(outputData,2));
            stdOutput = ones(1,size(outputData,2));
            
            
            
            
            projMatrices = zeros ( obj.numPara,size(inputData,2), obj.numProjMat) ;
            
            
            R = zeros (obj.numPara,obj.numPara,obj.numProjMat);
            r = zeros (obj.numProjMat ,obj.numPara ) ;
            bias = zeros (obj.numProjMat , 1) ;
            
            weights = zeros (obj.numProjMat,1) ;
            
            likelihoodVec = zeros(obj.numProjMat,1);
            
            trainX = inputData;%(:,1+obj.numContext:end) ;
            trainY = outputData ;
            
            
            if (obj.inputDataNormalization)
                
                [meanInput stdInput trainX] = obj.normalization(trainX) ;
                
            end
            
            if (obj.outputDataNormalization)
                
                [meanOutput stdOutput trainY] = obj.normalization(outputData) ;
                
            end
            
            context =[];
            if(false)%obj.numContext>0)
                context = inputData(:,1:obj.numContext);
                contextMean = zeros(1,obj.numContext);
                contextStd = ones(1,obj.numContext);
                meanInput = [contextMean,meanInput];
                stdInput  = [contextStd,stdInput];
            end
            
            trainX = [context trainX];
            
            
            for (i=1:obj.numProjMat)
                
                w = obj.RandomProj(obj.numPara , size(trainX,2));
                projMatrices (:,:,i) = w;
                projTrainX = (w * trainX')' ;
                
                
                quadProjTrainX = obj.Quadratic(projTrainX);
                quadProjTrainX = [ones(size(quadProjTrainX,1),1) quadProjTrainX];
                
                
                parameters = obj.bayesianLearner(quadProjTrainX,trainY);
                bias(i) = parameters (1);
                r(i,:) = parameters (2:obj.numPara+1);
                
                AQuadratic = zeros(obj.numPara);
                ind = logical(tril(ones(obj.numPara)));
                AQuadratic(ind) = parameters (obj.numPara+2:end);
                R(:,:,i) = (AQuadratic + AQuadratic') / 2;
       
                    
                likelihood = obj.Weights(quadProjTrainX,trainY);
                likelihoodVec (i) = likelihood ;

            end
            
            ssum = sum(exp(likelihoodVec - max(likelihoodVec)));
            weights = (exp(likelihoodVec - max(likelihoodVec))')/ssum;
            
            R2 =0 ;
            r2 =0;
            bias2 =0 ;
            
            for i=1:obj.numProjMat
                
                R2=R2 + weights(i).*(projMatrices(:,:,i)' * R(:,:,i) * projMatrices(:,:,i));
                r2=r2 + weights(i).*(r(i,:) * projMatrices(:,:,i) );
                bias2 = bias2 + weights(i).* bias(i) ;
                
            end
            
            stdInputinvmat = diag((1./stdInput));
            stdOutputmat = diag(stdOutput) ;
            
            A= (stdInputinvmat * R2 *stdInputinvmat);
            newR =stdOutputmat* A ;
            newr = -stdOutputmat* (meanInput*A' +meanInput*A -r2*stdInputinvmat);
            newBias =stdOutputmat* (meanInput*A*meanInput' - r2*stdInputinvmat*meanInput' + bias2)+meanOutput;
            
             if(sum(eig(newR)>0)>0)
               disp('Warning:R is not negative definite');
             end
             
            obj.functionApproximator.setParameters(newR, newr,newBias);
            
            
        end
    end
    
end
