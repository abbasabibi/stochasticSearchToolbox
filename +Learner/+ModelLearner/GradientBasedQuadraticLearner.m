

classdef GradientBasedQuadraticLearner < Learner.SupervisedLearner.SupervisedLearner
    
    
    properties
        
        parameterPrior = 0;
        
        R;
        r;
        r0;
        
        deravitiveCheckFlag = true;
        
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
        function obj = GradientBasedQuadraticLearner(dataManager, linearfunctionApproximator, varargin)
            
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
            
            numStates = size ( inputMatrix , 2 );
            numFeatures = numStates + 1;
            features = zeros(size(inputMatrix,1), numFeatures);
            
            
            features(:,1) = ones(size(features,1),1) ;
            features(:, 2:numFeatures) = inputMatrix(:,1:numStates);
            
            %index = index + numStates + 1;
            
        end
        
        function [features]= quadraticFeatures(obj, inputMatrix)
            
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
            %weights = exp(outputData);
            
            % [~,index] = sort(outputData,'descend');
            obj.parameterPrior = zeros(1,size(inputData,2));
            
            trainX = inputData;
            trainY = outputData;
            % weights = weights(index(1:15));
            %  weights = bsxfun(@times, -(1./(outputData)) , importanceWeights );
            %weights = bsxfun(@times, outputWeights , importanceWeights );
            
            weights = outputWeights;
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
        
        
       
        
        function [] = learnFunction(obj,parameters,returns,inputWeights)
            
            
            obj.deravitiveCheckFlag = false;
            if(nargin < 4)
                
                inputWeights = ones(size(returns,1),1);
                
            else
                inputWeights = inputWeights./sum(inputWeights);
                
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
                
                [meanInput stdInput trainX] = obj.normalization(trainX,inputWeights) ;
                
            end
            
            if (obj.outputDataNormalization)
                
                [meanOutput stdOutput trainY] = obj.normalization(outputData,inputWeights) ;
                
            end
            
            obj.trainX = trainX;
            obj.trainY = trainY;
            obj.weights = inputWeights;
            
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
            D(D > 0) = -1e-6;
            obj.R = U * D * U';
            
            
            %quadraticOutput = diag(trainX * obj.R * trainX') ;
            quadraticOutput = sum((trainX * obj.R) .* (trainX),2);
            quadProjTrainX = obj.linearFeatures(trainX);
            parameters = obj.bayesianLearner(quadProjTrainX,trainY - quadraticOutput,inputWeights,inputWeights);

            obj.r0 = parameters (1);
            obj.r = (parameters (2:end));
            
            A = chol(-1 * obj.R);
            
            B = triu(ones(obj.numPara,obj.numPara));
            v = A(B==1) ;

            params = [obj.r0 ; obj.r ; v ];
            
            options = obj.getOptimizationOptions();

             dualFunctionAnonymous = @(params) quadraticObjFunc(obj, params);
            
            [newParams,fval] = fminunc(dualFunctionAnonymous,params, options);

            obj.r0 = newParams (1);
            obj.r = (newParams (2:obj.numPara+1))';
            
            A = B ;
            A(B==1) = newParams(obj.numPara+2:end);
            
            obj.R = -1 * (A'*A);
            
           % quadraticOutput = diag(obj.trainX * obj.R * obj.trainX')' ;
            
           % LinearOutput = obj.trainX*obj.r';
            
           % sumTerm = ((quadraticOutput' + LinearOutput + obj.r0) - obj.trainY) .^ 2;
            
           % g = 0.5 * sum(sumTerm, 1);
            
            
            stdInputinvmat = diag((1./stdInput));
            stdOutputmat = diag(stdOutput) ;
            
            A= (stdInputinvmat * obj.R *stdInputinvmat);
            newR =stdOutputmat* A ;
            newr = -stdOutputmat* (meanInput*A' +meanInput*A -obj.r*stdInputinvmat);
            newBias =stdOutputmat* (meanInput*A*meanInput' - obj.r*stdInputinvmat*meanInput' + obj.r0)+meanOutput;
            
            obj.functionApproximator.setParameters(newR, newr,newBias);
            
                              
        end
        
        
            function optimizationOptions = getOptimizationOptions(obj)
            
            display = 'off';   
            useGradient = 'on';
            numOptimizationsDualFunction = 1000;
    
             ALG ='trust-region-reflective';
            
            %'sqb'
            %'active-set' 
            %'trust-region-reflective'
            %'interior-point'
%             optimizationOptions = optimset('GradObj',obj.useGradient, 'Display',display,'MaxFunEvals', obj.numOptimizationsDualFunction * 5,...
%                 'Algorithm', 'interior-point','TolX', 1e-30, 'TolFun', 1e-30, ...
%                 'MaxIter', obj.numOptimizationsDualFunction);

            optimizationOptions = optimset('GradObj',useGradient, 'Display',display,'MaxFunEvals', numOptimizationsDualFunction * 500,...
                'Algorithm', ALG,'TolX', 1e-8, 'TolFun', 1e-8, ...
                'MaxIter', numOptimizationsDualFunction , 'DerivativeCheck', 'off');
            end
        
       function [] = deravitivecheck(obj, params)
           
           epsilon = 0.0001;
           
           dg = ones(length(params),1);
           
           for(i=1:length(params))
               
                params1 = params;
                params2 = params;
                
                params1(i) = params(i) + epsilon;
                params2(i) = params(i) - epsilon;
                
                [g1, ~]  = obj.quadraticObjFunc2(params1);
                [g2, ~]  = obj.quadraticObjFunc2(params2);
                
                dg(i) = (g1-g2) / (2*epsilon);
                
           
           end
           
           [~, dgAnalytic]  = obj.quadraticObjFunc2(params);
           
        dg - dgAnalytic ;
           
       end

           
        
       function [g, gD] = quadraticObjFunc(obj, params)
           
            if(obj.deravitiveCheckFlag == true)
            obj.deravitivecheck(params);
            obj.deravitiveCheckFlag = false;
            end
            
            r0 = params (1);
            r = (params (2:obj.numPara+1));
            
            B = triu(ones(obj.numPara,obj.numPara));
            
            A = B ;
            A(B==1) = params(obj.numPara+2:end); 
            
            R = -1*(A'*A);
            
           % quadraticOutput = diag(obj.trainX * R * obj.trainX')' ;
            quadraticOutput = sum((obj.trainX * R) .* (obj.trainX),2);
            
            LinearOutput = obj.trainX*r;
            
            sumTerm = ((quadraticOutput + LinearOutput + r0) - obj.trainY) ;
            
            g = 0.5 * sum(sumTerm .^ 2, 1);
            
            
            % computeDeravitives
            dr0 = sum(sumTerm , 1);
            dr = sum(bsxfun(@times, obj.trainX, sumTerm)',2);
            
            dAsumTerm = bsxfun(@times, obj.trainX, sumTerm)' * obj.trainX;

            
            dA = -2 * A * dAsumTerm;
            
            v = dA(B==1);
            
            
            gD = [dr0; dr; v]; 
            
            
                        
       end
        
       function [g, gD] = quadraticObjFunc2(obj, params)
           
        
            r0 = params (1);
            r = (params (2:obj.numPara+1));
            
            B = triu(ones(obj.numPara,obj.numPara));
            
            A = B ;
            A(B==1) = params(obj.numPara+2:end); 
            
            R = -1*(A'*A);
            
           % quadraticOutput = diag(obj.trainX * R * obj.trainX')' ;
            quadraticOutput = sum((obj.trainX * R) .* (obj.trainX),2);
            
            LinearOutput = obj.trainX*r;
            
            sumTerm = ((quadraticOutput + LinearOutput + r0) - obj.trainY) ;
            
            g = 0.5 * sum(sumTerm .^ 2, 1);
            
            
            % computeDeravitives
            dr0 = sum(sumTerm , 1);
            dr = sum(bsxfun(@times, obj.trainX, sumTerm)',2);
            
            dAsumTerm = bsxfun(@times, obj.trainX, sumTerm)' * obj.trainX;

            
            dA = -2 * A * dAsumTerm;
            
            v = dA(B==1);
            
            
            gD = [dr0; dr; v]; 
            
            
                        
        end
        
       
    end
    
end
