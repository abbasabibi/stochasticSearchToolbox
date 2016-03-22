classdef RankMuLinearGaussianMLLearner2 < Learner.SupervisedLearner.LinearGaussianMLLearner
    % The <tt>LinearGaussianMLLearner</tt> is a supervised learner that uses
    % weighted maximum likelihood estimate of the covariance matrix.
    %
    % Just like its superclass <tt>LinearFeatureFunctionMLLearner</tt> this
    % class uses linear function approximator of the function class given via
    % constructor. In addition to its superclass we now need a gaussian 
    % distribution class , since this function needs to be equipped with 
    % <tt>setSigma()</tt> and <tt>setCovariance()</tt>.
    %
    % The <tt>learnFunction()</tt> will approximate the gaussian type 
    % distribution via weighted maximum likelihood estimate of the covariance matrix. The following 
    % settings have been registered and can be used to manipulate the learning
    % function. (see Common.Settings for more information on settings): 
    %
    % - <tt>maxCorr</tt> (default 1): maximum correlation coefficient in the covariance matrix.
    % - <tt>minCov</tt> (default 10^-6): minimal covariance of the diagonal elements in the sigma matrix
    % - <tt>priorCov</tt> (default 1): factor for the prior of the
    % - <tt>priorCovWeight</tt> (default 10^-16): influence of the prior
    
    properties (SetObservable,AbortSet)
     
        entropyPerEffSample = 0.01;
    end
    
    % Class methods
    methods
        function obj = RankMuLinearGaussianMLLearner2(dataManager, linearfunctionApproximator, varargin)
            % @param dataManager Data.DataManger to operate on
            % @param linearfunctionApproximator function object that will  be learned needs to be of gaussian type
            % @param varargin contains the following optional arguments in this order: weightName, inputVariables, outputVariable (see superclass SupervisedLearner)
            obj = obj@Learner.SupervisedLearner.LinearGaussianMLLearner(dataManager, linearfunctionApproximator, varargin{:});
            
            obj.linkProperty('entropyPerEffSample');
        end
        
        function [] = learnFunction(obj, inputData, outputData, weighting)
            
            if (~exist('weighting', 'var') || isempty(weighting) )
                weighting = ones(size(inputData,1),1);
            end
            
            [n, p] = size(outputData);
            
            oldMean = obj.functionApproximator.getMean();
            oldBeta = obj.functionApproximator.weights;
            
            oldCov =obj.functionApproximator.getCovariance;
            obj.learnFunction@Learner.SupervisedLearner.LinearGaussianMLLearner(inputData, outputData, weighting);
            newMean = mean(obj.functionApproximator.getExpectation(size(inputData,1), inputData));
            SigmaA = obj.functionApproximator.getCovariance; 
           

            sumW    = sum(weighting);
            weighting = weighting / sumW;
            
            Z = ( sum(weighting)^2 - sum(weighting.^2));
           
            effsampes = (1/sum(weighting.^2));
            
            
            L = chol(oldCov);
            logdetA = 2*sum(log(diag(L)));
            
            if(1 )
                L = chol(oldCov);
                oldEntropy = p/2*(1+log(2*pi))+ 2*sum(log(diag(L)));
                %desiredEntropyReduction = obj.entropyPerEffSample * effsampes;
                desiredEntropyReduction = 0.4;
                desiredEntropy = oldEntropy - desiredEntropyReduction;

                lambdaVec = logspace(-4,0, 100);
                entropyA  = zeros(100,1);
                for i = 1:length(entropyA)
                    SigmaTemp = (1-lambdaVec(i)).* oldCov + lambdaVec(i) .* SigmaA;  
                   % entropyA(i) = sum(log(eig(SigmaTemp)));
                   
                    L = chol(SigmaTemp);
                    entropyA(i) =  p/2*(1+log(2*pi))+ 2*sum(log(diag(L)));
                     
                end
                entropyDist = abs(desiredEntropy - entropyA);
                [val, ind] = min(entropyDist);
                
                SigmaA = (1-lambdaVec(ind)).* oldCov + lambdaVec(ind) .* SigmaA;
                
                newMean = oldMean * (1-lambdaVec(ind)) + lambdaVec(ind) *obj.functionApproximator.getMean();
                newBeta = oldBeta * (1-lambdaVec(ind)) + lambdaVec(ind) *obj.functionApproximator.weights;
                
                %obj.functionApproximator.setWeightsAndBias(newBeta, newMean);
               
                %SigmaA = (1 - lambda).* oldCov + lambda .* SigmaA;
                cholA = chol(SigmaA);
                obj.functionApproximator.setSigma(cholA);
                newCov = obj.functionApproximator.getCovariance;
                obj.KL = 1/2 *(trace(oldCov \ newCov ) + (newMean-oldMean)'*(oldCov \ (newMean-oldMean)) ...
                    -size(outputData,2) +  sum(log(eig(oldCov))) - sum(log(eig(newCov))));
                
           %     fprintf('Lambda: %f \n', lambdaVec(ind));
            else
                SigmaA = diag(rangeOutput) * priorCov * priorCovWeight / (1 + priorCovWeight);
                obj.functionApproximator.setCovariance(SigmaA);
            end
        end
    end
    
end
