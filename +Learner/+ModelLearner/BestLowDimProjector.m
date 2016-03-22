



classdef BestLowDimProjector < Learner.SupervisedLearner.SupervisedLearner
    
    properties(SetObservable, AbortSet)
        
        inputDataNormalization = true;
        outputDataNormalization = true;
        
       
        numPara = 3,
        numProjMat = 1000;
        
    end
    
    % Class methods
    methods
        function obj = BestLowDimProjector(dataManager, linearfunctionApproximator, varargin)
            
            obj = obj@Learner.SupervisedLearner.SupervisedLearner(dataManager, linearfunctionApproximator, varargin{:});
            

            obj.linkProperty('numPara');
            obj.linkProperty('numProjMat');
            
        end
        
        function [features]= Quadratic(obj,inputMatrix)
            
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
        
        
        function W = RandomProj (obj,desiredDim, currentDim)
            
            W= randn (desiredDim , currentDim) ;
        end
        
        
        function avgErr = Regression (obj,trainX , trainY , testX , testY)
            
            theta = obj.LinearRegression(trainX,trainY,10^-4);
            avgErr= var(  ( testX  * theta ) - testY );
            
        end
        
        function [theta] = LinearRegression (obj,X,Y, ridge)
            
            theta = ( X' * X + ridge * eye(size(X,2))) \ X' * Y ;
            
        end
        
        function [parameters] = bayesianLearner (obj,inputData, outputData)
            
            
            trainX = inputData;
            trainY = outputData;
            
            A = ( 1/obj.bayesNoiseSigma ) * ( trainX'*trainX ) + ( 1/obj.bayesParametersSigma )*eye(size(trainX,2)) ;
            parameters = (1/obj.bayesNoiseSigma)*eye(size(A,1)) / A * trainX' * trainY ;
            
            
        end
        
        function [dataMean stDev normData] = normalization(obj,inputMatrix)
            
            dataMean = mean(inputMatrix,1);
            stDev    = std(inputMatrix,1,1) ;
            
            
            normData = inputMatrix  - repmat(dataMean , size(inputMatrix,1) , 1 );
            normData = normData    ./  repmat(stDev,size(inputMatrix,1), 1 );
            
            
        end
        
        
        
        function [] = learnFunction(obj, inputData, outputData)
            
           meanInput =zeros(1,size(inputData,2));
           stdInput  = ones(1,size(inputData,2));
           meanOutput = zeros(1,size(outputData,2));
           stdOutput = ones(1,size(outputData,2));
            
            
            trainX = inputData ;
            trainY = outputData ;
            
            if (obj.inputDataNormalization)
                
                [meanInput stdInput trainX] = obj.normalization(inputData) ;
                
            end
            
            if (obj.outputDataNormalization)
                
                [meanOutput stdOutput trainY] = obj.normalization(outputData) ;
                
            end
            
            minVal = 200000;
            bestW=0;
            fun = @obj.Regression;% @Learner.SupervisedLearner.Regression;
            
            for i=1:obj.numProjMat
                
  
                w = obj.RandomProj(obj.numPara , size(trainX,2));
                projTrainX = (w * trainX')' ;
                
                
                quadProjTrainX =obj.Quadratic(projTrainX);
                quadProjTrainX = [ones(size(quadProjTrainX,1),1) quadProjTrainX];
                
                vals  = crossval(fun,quadProjTrainX,trainY,'kfold',10);
                
                if(mean(vals) < minVal)
                    minVal = mean(vals);
                    bestW = w ;
                end
                
                
            end
            
            [ ptrainX ]  = ( bestW * trainX')';
            ptrainX = obj.Quadratic ( ptrainX ) ;
            ptrainX = [ ones( size( ptrainX , 1 ) , 1 ) ptrainX ];
            
            theta = obj.LinearRegression(ptrainX,trainY,10^-5);
            
            bias = theta (1);
            r = theta (2:obj.numPara+1);
            
            AQuadratic = zeros(obj.numPara);
            ind = find(tril(ones(obj.numPara)));
            AQuadratic(ind) = theta (obj.numPara+2:end);
            R = (AQuadratic + AQuadratic') / 2;
            
            R=(bestW' * R * bestW);
            r=(r' * bestW);
            bias =   bias ;
            
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
