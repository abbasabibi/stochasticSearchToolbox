classdef LogisticRegressionLearner < Learner.SupervisedLearner.SupervisedLearner
    
    
    properties
        logLikelihoodIterations
        useDesiredProbs
    end
    
    properties (SetObservable,AbortSet)
        logisticRegressionRegularizer   = 1e-7;
%         logisticRegressionNumIterations = 1000;
%         logisticRegressionLearningRate  = 1e-2;
        logisticRegressionToleranceX    = 1e-15;
        logisticRegressionToleranceF    = 1e-9;
        isDebug = false;
    end
    
    % Class methods
    methods
        function obj = LogisticRegressionLearner(dataManager, softMaxApproximator, useDesiredProbs, varargin)
            obj = obj@Learner.SupervisedLearner.SupervisedLearner(dataManager, softMaxApproximator, varargin{:});
            
            if (~exist('useDesiredProbs', 'var'))
                useDesiredProbs = false;
            end
            
            if (useDesiredProbs)
                outputLvl   = obj.dataManager.getDataEntryDepth(softMaxApproximator.outputVariable);
                subManager  = obj.dataManager.getDataManagerForDepth(outputLvl);
                outputName  = [softMaxApproximator.outputVariable, 'DesiredProbs'];
%                 subManager.addDataEntry( outputName, subManager.getMaxRange(softMaxApproximator.outputVariable) );
                subManager.addDataEntry( outputName, 1 );
            
                obj.setOutputVariableForLearner(outputName)
            end
            
            obj.linkProperty('logisticRegressionRegularizer');
%             obj.linkProperty('logisticRegressionNumIterations');
%             obj.linkProperty('logisticRegressionLearningRate');
            
            obj.linkProperty('logisticRegressionToleranceX');
            obj.linkProperty('logisticRegressionToleranceF');
            
            obj.linkProperty('isDebug', 'isDebugLogisticRegressionLearner');
            
        end
        
        %%
        function [error, dE, ddE] = errorFunction(obj,w, inputData, outputData, weighting)
            lambda  = obj.logisticRegressionRegularizer /10;
            obj.functionApproximator.setTheta(w');
            
            itemProb    = obj.functionApproximator.getItemProbabilities(size(inputData,1), inputData);
            itemProb    = itemProb(:,1);
            diff        = (itemProb- outputData) .* weighting;
            
%             itemProb(itemProb==0) = realmin;
%             obj.logLikelihoodIterations(end+1) = -sum(outputData .* log(itemProb).*weighting);
            
            R = (itemProb.*(1-itemProb)) .* weighting;
%             R = diag(R);
%             ddE     = inputData'*R*inputData;
            ddE = bsxfun(@times, inputData, R)' * inputData;
            
            tmp         = (ddE + lambda*eye(size(inputData,2)) );              
            condition   = rcond(tmp);            
            while(condition < obj.logisticRegressionRegularizer  && lambda > 0)
              lambda  = 10 * lambda;
              tmp     = (ddE + lambda*eye(size(inputData,2)) );              
              condition = rcond(tmp);
              assert(lambda<10);
            end

            
            logProb                 = outputData .* log(itemProb);
            outputData2             = (1-outputData);
            itemProb2               = (1-itemProb);
%             itemProb2               = max(itemProb2, 1e-30);
            logProbNegated          = outputData2 .* log(itemProb2);
            logProb(outputData==0)  = 0;
            logProbNegated( outputData2 ==0 )  = 0;
            error                   = -sum( (logProb +logProbNegated).* weighting) + lambda * 0.5 * w' * w;
            
            dE      = inputData' * diff + lambda*w;
            ddE     = tmp;
            
        end
        
        
        %%
        function [] = learnFunction(obj, inputData, outputData, weighting)
             
          if (~exist('weighting', 'var'))
            weighting = ones(size(inputData,1),1);
          end
          minWeighting  = 1e-50;
          inputData     = inputData(weighting > minWeighting,:);
          outputData    = outputData(weighting > minWeighting,:);
          weighting     = weighting(weighting > minWeighting);
          
          w = obj.functionApproximator.theta';
          
          options = obj.getOptimizationOptions();
          optimFunc = @(w)obj.errorFunction(w, inputData, outputData, weighting);
          w = fminunc(optimFunc, w, options);
          obj.functionApproximator.setTheta(w');
          

        end
        
        
        %%
        function [options] = getOptimizationOptions(obj)
            
            if (obj.isDebug)
                display = 'iter';
            else
                display = 'off';
            end
            useGrad     = 'on';
            useHessian  = 'on';
            
            if (exist('optimoptions'))
                options = optimoptions(@fminunc,'GradObj',useGrad,'Hessian',useHessian,'Algorithm','trust-region',...
                    'Display', display,'TolX',obj.logisticRegressionToleranceX,'TolFun',obj.logisticRegressionToleranceF);
            else
                options = optimset('GradObj',useGrad,'Hessian',useHessian,'Algorithm','trust-region-reflective',...
                    'Display', display,'TolX',obj.logisticRegressionToleranceX,'TolFun',obj.logisticRegressionToleranceF);
            end
        end
        
        
%         %%
%         function [] = learnFunction(obj, inputData, outputData, weighting)
%           
%           if (~exist('weighting', 'var'))
%             weighting = ones(size(inputData,1),1);
%           end
%           
%           w = obj.functionApproximator.theta';
%           
%           for i = 1 : obj.logisticRegressionNumIterations
%             lambda  = obj.logisticRegressionRegularizer /10;
%             itemProb= obj.functionApproximator.getItemProbabilities(size(inputData,1), inputData);
%             itemProb = itemProb(:,1);
%             error   = (itemProb- outputData) .* weighting;
%             
%             itemProb(itemProb==0) = realmin;
%             obj.logLikelihoodIterations(i) = -sum(outputData .* log(itemProb).*weighting);
%             
%             R = (itemProb.*(1-itemProb)) .* weighting;
% %             R = diag(R);
% %             ddE     = inputData'*R*inputData;
%             ddE = bsxfun(@times, inputData, R)' * inputData;
%             
%             condition = 0;
%             while(condition < eps * 1.1 )
%               lambda  = 10 * lambda;
%               tmp     = (ddE + lambda*eye(size(inputData,2)) );              
%               condition = rcond(tmp);
%               assert(lambda<10);
%             end
%             
%             
% %             if(i > 1)
% %                 logLikeDifference = obj.logLikelihoodIterations(i) - obj.logLikelihoodIterations(i-1);
% %                 if(logLikeDifference< -1e-3)
% %                     warning(['llh diff is negative in LogisticRegressionLearner logLikeDifference=',num2str(logLikeDifference)]);
% %                 end
% %             end
%             
%            
%             
%             w = w - obj.logisticRegressionLearningRate* ( tmp \ (inputData' * error + lambda*w));
%             obj.functionApproximator.setTheta(w');
% %             norm(error)
% %             dE = inputData' * error
% 
%           end
          

          
          
          
%           fprintf('LogisticRegression took %d Iterations\n', i);
% %           toc
%           obj.logLikelihoodIterations = obj.logLikelihoodIterations(1:i);
          
%         end
    end
    
end


%%

