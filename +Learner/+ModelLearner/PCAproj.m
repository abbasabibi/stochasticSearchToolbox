

classdef PCAproj < Learner.SupervisedLearner.SupervisedLearner
    
    properties(SetObservable, AbortSet)
        
        inputDataNormalization = true;
        outputDataNormalization = true;
        
        
        
        numPara = 2;
        
        
    end
    
    % Class methods
    methods
        
     
        function obj = PCAproj(dataManager, linearfunctionApproximator, varargin)
            
            obj = obj@Learner.SupervisedLearner.SupervisedLearner(dataManager, linearfunctionApproximator, varargin{:});
            
            
            obj.linkProperty('numPara');
            
            
        end
        
           function [theta] = LinearRegression (obj,X,Y, ridge)
            
            theta = ( X' * X + ridge * eye(size(X,2))) \ X' * Y ;
            %theta = pinv( X' * X ) * X' * Y ;
            
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
        
        function U = PCA(obj,X)
            
            [U,S,V] = svd(X'*X);
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
            
       
            [ pcaX   ]  = obj.PCA ( trainX ) ;
        
            [ bestW ]  = (pcaX( : , 1:obj.numPara))' ;

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
