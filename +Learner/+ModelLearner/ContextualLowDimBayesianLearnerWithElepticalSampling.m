

classdef ContextualLowDimBayesianLearnerWithElepticalSampling < Learner.SupervisedLearner.SupervisedLearner
    
    properties(SetObservable, AbortSet)
        
        inputDataNormalization = true;
        outputDataNormalization = true;
        
        %SIGMA = 1; % noise ~ N(0,SIGMA)
        %TAU = 10e-4
        bayesNoiseSigma =1;
        bayesParametersSigma = 10e-3;
        
        numPara = 4;
        numProjMat = 200;
        
        numContext = 0;
        
        projectContext = true;
        
        trainX;
        trainY;
        
        numStep = 1;
        
    end
    
    % Class methods
    methods
        function obj = ContextualLowDimBayesianLearnerWithElepticalSampling(dataManager, linearfunctionApproximator, varargin)
            
            obj = obj@Learner.SupervisedLearner.SupervisedLearner(dataManager, linearfunctionApproximator, varargin{:});
            
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
        
        
        function [xx, cur_log_like] = elliptical_slice(obj,xx, prior, log_like_fn, cur_log_like, angle_range, varargin)
%ELLIPTICAL_SLICE Markov chain update for a distribution with a Gaussian "prior" factored out
%
%     [xx, cur_log_like] = elliptical_slice(xx, chol_Sigma, log_like_fn);
% OR
%     [xx, cur_log_like] = elliptical_slice(xx, prior_sample, log_like_fn);
%
% Optional additional arguments: cur_log_like, angle_range, varargin (see below).
%
% A Markov chain update is applied to the D-element array xx leaving a
% "posterior" distribution
%     P(xx) \propto N(xx;0,Sigma) L(xx)
% invariant. Where N(0,Sigma) is a zero-mean Gaussian distribution with
% covariance Sigma. Often L is a likelihood function in an inference problem.
%
% Inputs:
%              xx Dx1 initial vector (can be any array with D elements)
%
%      chol_Sigma DxD chol(Sigma). Sigma is the prior covariance of xx
%  or:
%    prior_sample Dx1 single sample from N(0, Sigma)
%
%     log_like_fn @fn log_like_fn(xx, varargin{:}) returns 1x1 log likelihood
%
% Optional inputs:
%    cur_log_like 1x1 log_like_fn(xx, varargin{:}) of initial vector.
%                     You can omit this argument or pass [].
%     angle_range 1x1 Default 0: explore whole ellipse with break point at
%                     first rejection. Set in (0,2*pi] to explore a bracket of
%                     the specified width centred uniformly at random.
%                     You can omit this argument or pass [].
%        varargin  -  any additional arguments are passed to log_like_fn
%
% Outputs:
%              xx Dx1 (size matches input) perturbed vector
%    cur_log_like 1x1 log_like_fn(xx, varargin{:}) of final vector

% Iain Murray, September 2009
% Tweak to interface and documentation, September 2010

% Reference:
% Elliptical slice sampling
% Iain Murray, Ryan Prescott Adams and David J.C. MacKay.
% The Proceedings of the 13th International Conference on Artificial
% Intelligence and Statistics (AISTATS), JMLR W&CP 9:541-548, 2010.

D = numel(xx);
if (nargin < 4) || isempty(cur_log_like)
    cur_log_like = obj.logliklihoodfun(xx, varargin{:});
end
if (nargin < 5) || isempty(angle_range)
    angle_range = 0;
end

% Set up the ellipse and the slice threshold
if numel(prior) == D
    % User provided a prior sample:
    nu = reshape(prior, size(xx));
else
    % User specified Cholesky of prior covariance:
    if ~isequal(size(prior), [D D])
        error('Prior must be given by a D-element sample or DxD chol(Sigma)');
    end
    nu = reshape(prior'*randn(D, 1), size(xx));
end
hh = log(rand) + cur_log_like;

% Set up a bracket of angles and pick a first proposal.
% "phi = (theta'-theta)" is a change in angle.
if angle_range <= 0
    % Bracket whole ellipse with both edges at first proposed point
    phi = rand*2*pi;
    phi_min = phi - 2*pi;
    phi_max = phi;
else
    % Randomly center bracket on current point
    phi_min = -angle_range*rand;
    phi_max = phi_min + angle_range;
    phi = rand*(phi_max - phi_min) + phi_min;
end

% Slice sampling loop
while true
    % Compute xx for proposed angle difference and check if it's on the slice
    xx_prop = xx*cos(phi) + nu*sin(phi);
    cur_log_like = obj.logliklihoodfun(xx_prop, varargin{:});
    if cur_log_like > hh
        % New point is on slice, ** EXIT LOOP **
        break;
    end
    % Shrink slice to rejected point
    if phi > 0
        phi_max = phi;
    elseif phi < 0
        phi_min = phi;
    else
        error('BUG DETECTED: Shrunk to current position and still not acceptable.');
    end
    % Propose new angle difference
    phi = rand*(phi_max - phi_min) + phi_min;
end
xx = xx_prop;
        end
        
        
        
        function [W loglik] = RandomProj(obj, desiredDim, currentDim)
            
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
            
            loglik = logliklihoodfun(W) ;
        end
        
       function [W loglik]= ESRandomProj(obj,desiredDim, currentDim, initialSample)
           
           
            
%             if (~obj.projectContext)
%                 W= randn (desiredDim-obj.numContext , currentDim);
%                 
%                 
%                 if(obj.numContext>0)
%                     contextCol = zeros(obj.numContext,currentDim);
%                     
%                     
%                     for i=1:obj.numContext
%                         
%                         contextCol(i,i) = 1;
%                     end
%                     
%                     W = [contextCol;W];
%                     
%                 end
%             else
%                 W= randn (desiredDim , currentDim);
%             end

                   

                 D = desiredDim*currentDim;
%                  obj.PS =eye(D);
%                  cholPS = chol(PS);
                 %xxPriorDraw = cholPS'*randn(D,1);
                 %start = reshape(currentMat,desiredDim*currentDim,1);
                
                 if nargin < 4
                    W = randn(D,1);  
                    
                 else
                     
                    W = initialSample;
                    W = reshape(W,desiredDim*currentDim,1);

                 
                 end
                 
%                  if(obj.numStep < 1)
%                  loglik = obj.logliklihoodfun(W);   
%                  end
                 
                 for i=1:obj.numStep
                 
                 %logLikFcn = @(params) logliklihoodfun(obj, params);
                 [W, loglik] = obj.elliptical_slice( W, eye(D));
                  
                 
                 end
                 
                 W = reshape(W,desiredDim , currentDim) ;

        end
        
        
        
        
        function [likelihood] = Weights(obj, inputData, outputData)
            
            sigmaMat = obj.bayesNoiseSigma * eye(size(outputData,1)) ;
            %sigmaMat(1,1) = 0;
            
            tauThetaMat = eye(size(inputData,2)) * obj.bayesParametersSigma;
            tauThetaMat(1,1) = 10^10;
            
            
            mean = zeros(1 , size(outputData,1));
            coavarianceMat = sigmaMat + inputData*tauThetaMat*inputData';
            
            cholCov = chol(coavarianceMat);
            v = 2 * sum(log(diag(chol((2*pi).*coavarianceMat))));
            %v = sum(log(eig((2*pi).*coavarianceMat)));
            xc = bsxfun(@minus, outputData',  mean);
            
            prodHalf = xc / cholCov;
            
            likelihood = -0.5 * (v + (prodHalf * prodHalf'));
            
        end
        
        
        function [parameters] = bayesianLearner(obj, inputData, outputData)
            
            
            trainX = inputData;
            trainY = outputData;
            
            tauThetaMat = eye(size(inputData,2)) * obj.bayesParametersSigma;
            tauThetaMat(1,1) = 10^10;
            
            A = ( 1/obj.bayesNoiseSigma ) * ( trainX'*trainX ) + inv(tauThetaMat);
            parameters = (1/obj.bayesNoiseSigma)*eye(size(A,1)) / A * trainX' * trainY ;
            
            
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
        
        function [logliklihood] = logliklihoodfun(obj,w)
            
            % dualFunctionAnonymous = @(params) dualFunction(obj, params);
           if (~isequal(size(w), [obj.numPara size(obj.trainX,2)]))
             w = reshape(w, obj.numPara , size(obj.trainX,2));
           end
           
            projTrainX = (w * obj.trainX')' ;
          
            quadProjTrainX = obj.Quadratic(projTrainX);
            quadProjTrainX = [ones(size(quadProjTrainX,1),1) quadProjTrainX];
            
            inputData = quadProjTrainX;
            outputData = obj.trainY;
            
            sigmaMat = obj.bayesNoiseSigma * eye(size(outputData,1)) ;
            %sigmaMat(1,1) = 0;
            
            tauThetaMat = eye(size(inputData,2)) * obj.bayesParametersSigma;
            tauThetaMat(1,1) = 10^10;
            
            
            mean = zeros(1 , size(outputData,1));
            coavarianceMat = sigmaMat + inputData*tauThetaMat*inputData';
            
            cholCov = chol(coavarianceMat);
            v = 2 * sum(log(diag(chol((2*pi).*coavarianceMat))));
            %v = sum(log(eig((2*pi).*coavarianceMat)));
            xc = bsxfun(@minus, outputData',  mean);
            
            prodHalf = xc / cholCov;
            
            logliklihood = -0.5 * (v + (prodHalf * prodHalf'));
                         
        end
        
   function [] = learnFunction(obj,contexts,parameters,returns)
            
            inputData = [contexts parameters];
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
            
            obj.trainX = trainX;
            obj.trainY = trainY;
            %likelihoodVec(1) = obj.logliklihoodfun(zeros(obj.numPara*size(trainX,2),1));
            w = randn(obj.numPara,size(trainX,2));
             i = 1;
             numSingularMatrix = 0;
             numMatricQuery= 0 ;
            for i=1:obj.numProjMat
            % while(i <= obj.numProjMat)    
%            while(i <= obj.numProjMat)    
    
               % [w likelihood] = obj.RandomProj(obj.numPara , size(trainX,2));
                
             %  w = randn(obj.numPara,size(trainX,2));
%                if(i<10)
%                    
%                obj.numStep =10;
%                
%                else
%                    
%                obj.numStep =1;
%                
%                end
               
               [w likelihood]= obj.ESRandomProj(obj.numPara , size(trainX,2));
                %obj.RandomProj(obj, desiredDim, currentDim)
                
                likelihoodVec (i) = likelihood ;
                
                
                %likelihood = obj.Weights(quadProjTrainX,trainY);

                
                projMatrices (:,:,i) = w;
                 
                projTrainX = (w * trainX')' ;
                
                
                quadProjTrainX = obj.Quadratic(projTrainX);
                quadProjTrainX = [ones(size(quadProjTrainX,1),1) quadProjTrainX];
                
                
                parameters = obj.bayesianLearner(quadProjTrainX,trainY);
   
                
                AQuadratic = zeros(obj.numPara);
                ind = logical(tril(ones(obj.numPara)));
                AQuadratic(ind) = parameters (obj.numPara+2:end);
                R(:,:,i) = (AQuadratic + AQuadratic') / 2;
                
%                        if(~all(eig(R(:,:,i))<0))
%                      %i = i-1;
%                      numSingularMatrix = numSingularMatrix+1;
%                      continue;
%                      %R(:,:,i) = obj.fixTheMatrix(R(:,:,i));
%                       %  numSingularMatrix = numSingularMatrix+1;
%            
%                        end
%                    
                       
                 
                bias(i) = parameters (1);
                r(i,:) = parameters (2:obj.numPara+1);
                
               
   

             %   i = i+1;
                
                
             end
            
            %numSingularMatrix
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
            
           % [newR] = Learner.SupervisedLearner.regularizeHessian(newR);
            
            obj.functionApproximator.setParameters(newR, newr,newBias);
            
            
        end
    end
    
end
