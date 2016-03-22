classdef LinearGaussianCV < Learner.SupervisedLearner.LinearGaussianMLLearner
    
    
    % Class methods
    methods
        function obj = LinearGaussianCV(dataManager, linearfunctionApproximator, varargin)
            obj = obj@Learner.SupervisedLearner.LinearGaussianMLLearner(dataManager, linearfunctionApproximator, varargin{:});
            
        end
        
        %function [negloglikelihood] = getCVNegLogLikelihood(obj,inputData, outputData, weighting, logregularizer)
        function [negloglikelihood] = getCVNegLogLikelihood(obj,inputData, outputData, weighting, regularizer)
            
            
            
            %obj.regularizationRegression = exp(logregularizer);
            obj.regularizationRegression = regularizer;
            %n fold cross validation
            n =size(inputData,1);
            k = 2;
            negloglikelihood = 0;
            for fold = 1:k
                val_idx = zeros(n,1);
                %val_idx(round(n*(fold-1)/k+1):round(n*fold/k)) = 1;
                val_idx(fold:k:n) = 1;
                val_idx = logical(val_idx);
                train_idx = ~(val_idx);
                
                obj.learnFunction(inputData(train_idx,:), outputData(train_idx,:), weighting(train_idx,:), true)
                loglikely = obj.functionApproximator.getDataProbabilities( inputData(val_idx,:), outputData(val_idx,:));
                negloglikelihood = negloglikelihood - weighting(val_idx,:)'* loglikely;
            end
            
            
        end
        
        function [] = learnFunction(obj, inputData, outputData, weighting, parentonly)
            %parentonly is just an internal trick to be able to call parent
            %function from likelihood function
            if(~exist('parentonly','var'))
                parentonly=false;
            end
            if (~exist('weighting', 'var'))
                weighting = ones(size(inputData,1),1);
            end
            if(parentonly)
                obj.learnFunction@Learner.SupervisedLearner.LinearGaussianMLLearner(inputData, outputData, weighting);
            else
                
                %states = inputData(:, 1:2);
                %inputData = inputData(:, 3:end);
                
                %learn optimal regularizer
                
                %objfun = @(logreg) obj.getCVNegLogLikelihood(inputData, ...
                %    outputData, weighting, logreg);
                %logregopt = fminunc(objfun, log(obj.regularizationRegression) );
                %obj.regularizationRegression = exp(logregopt);
                %exp(logregopt)
                objfun = @(reg) obj.getCVNegLogLikelihood(inputData, ...
                    outputData, weighting, reg);
                regopt = fminunc(objfun, obj.regularizationRegression );
                obj.regularizationRegression = regopt;
                regopt
                
                %learn function on all data
                obj.learnFunction@Learner.SupervisedLearner.LinearGaussianMLLearner(inputData, outputData, weighting);
                
           
%                 scatter3(states(:,1),states(:,2),outputData,100*weighting/max(weighting)+min(weighting)+1,weighting)
%                 xlabel('x')
%                 ylabel('xd')
%                 figure(2)
%                 logprobs = obj.functionApproximator.getDataProbabilities(inputData, outputData);
%                 [sw,sortidxs] = sort(weighting);
%                 plot(1:size(weighting,1), weighting(sortidxs)/max(abs(weighting)), 1:size(weighting,1), logprobs(sortidxs)/max(abs(logprobs)))
%                 figure(3)
% 
%                 [z,s] = obj.functionApproximator.getExpectationAndSigma(size(inputData,1), inputData);
%                 %surf(x,y,reshape(z, size(x)));
%                 scatter3(states(:,1),states(:,2),reshape(z+s, size(states(:,1))),'r');
%                 hold on
%                 scatter3(states(:,1),states(:,2),reshape(z-s, size(states(:,1))),'b');
%                 hold off
%                 xlabel('x')
%                 ylabel('xd')
%                 true        
            end
            
        
            
        end
        
    end
    
end
