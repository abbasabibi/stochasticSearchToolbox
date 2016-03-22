classdef MultiClassLogisticRegressionLearner < Learner.SupervisedLearner.SupervisedLearner
    
    
    properties
        logLikelihoodIterations
        useDesiredProbs
        
        inputData
        outputData
        weighting
        phiAll
        numClasses
        featureSize
        resetTheta = false;
    end
    
    properties (SetObservable,AbortSet)
        softMaxRegressionRegularizer    = 1e-7;

        softMaxRegressionToleranceX     = 1e-15;
        softMaxRegressionToleranceF     = 1e-9;
        
        isDebug = false;
    end
    
    % Class methods
    methods
        function obj = MultiClassLogisticRegressionLearner(dataManager, softMaxApproximator, useDesiredProbs, varargin)
            obj = obj@Learner.SupervisedLearner.SupervisedLearner(dataManager, softMaxApproximator, varargin{:});
            
            if (~exist('useDesiredProbs', 'var')) %Instead of hard class assignments
                useDesiredProbs = false;
            end
            
            if (useDesiredProbs)
                outputLvl   = obj.dataManager.getDataEntryDepth(softMaxApproximator.outputVariable);
                subManager  = obj.dataManager.getDataManagerForDepth(outputLvl);
                outputName  = [softMaxApproximator.outputVariable, 'DesiredProbs'];
                subManager.addDataEntry( outputName, subManager.getMaxRange(softMaxApproximator.outputVariable) );
                
                obj.setOutputVariableForLearner(outputName)
            end
            
            obj.featureSize = dataManager.getNumDimensions(softMaxApproximator.inputVariables);
            
            obj.numClasses = obj.functionApproximator.numItems;

            obj.functionApproximator.setThetaAllItems(zeros(obj.numClasses, obj.featureSize));
            
            
            obj.linkProperty('softMaxRegressionRegularizer');
            obj.linkProperty('softMaxRegressionToleranceX');
            obj.linkProperty('softMaxRegressionToleranceF');
            
            obj.linkProperty('isDebug', 'DebugMode');
        end
        
        function [error,gradient,hessian] = errorFunction(obj,x)
            lambda = obj.softMaxRegressionRegularizer;
            I = eye(obj.numClasses);
        
            obj.functionApproximator.setThetaAllItems(x);
            
            itemProb  = obj.functionApproximator.getItemProbabilities(size(obj.inputData,1), obj.inputData);
            
            error = itemProb - obj.outputData;
            error = bsxfun(@times, error , obj.weighting);
            
            dE = bsxfun(@times, permute(error,[3 2 1]), permute(obj.phiAll,[2 3 1]));%[feature, option, state]
            dE = sum(dE,3); % [feature, option]
            
            if nargout >= 3
%                 ddE = zeros(obj.numClasses * obj.featureSize, obj.numClasses * obj.featureSize);
%                 
%                 for o = 1 : obj.numClasses
%                     idxO = (o-1) * obj.featureSize + 1;
%                     for k = 1 : obj.numClasses
%                         idxK = (k-1) * obj.featureSize + 1;
%                         if o>k
%                             ddE(idxO : idxO+obj.featureSize-1, idxK : idxK+obj.featureSize-1) = ddE(idxK : idxK+obj.featureSize-1, idxO : idxO+obj.featureSize-1);
%                         else
%                             errorSquare = itemProb(:,o) .* (I(o,k)-itemProb(:,k)) .* obj.weighting;
%                             phiAllWeighted = bsxfun(@times, obj.phiAll, errorSquare);
%                             ddE(idxO : idxO+obj.featureSize-1, idxK : idxK+obj.featureSize-1) = obj.phiAll' * phiAllWeighted;
% 
%                             %tmp = bsxfun(@times, phiSquare, permute(errorSquare,[3 2 1]));
%                             %ddE(idxO : idxO+featureSize-1, idxK : idxK+featureSize-1) = sum(tmp,3 );
% 
%                         end
%                     end
%                end
                % More efficient mex implementation
                ddE = Learner.ClassificationLearner.ComputeHessianMultiClassLogisticMex(obj.phiAll, itemProb, obj.weighting);

                condition = 0;
                while(condition < eps * 1.1 )
                    lambda  = 10 * lambda;
                    tmp     = (ddE + lambda * eye(size(ddE)));
                    condition = rcond(tmp);
                    assert(lambda<100);
                end
                hessian = tmp;
            end
            
            w = obj.functionApproximator.thetaAllItems';
            w = w(:);
            
            %w = w - 1e2/sum(abs(dE(:))) * tmp^-1 * (dE(:) + lambda * w);
            %w = w - 1e-5 * dE(:) ;
            w = dE(:) + lambda * w;
            %w = obj.softMaxRegressionLearningRate *( tmp \ (dE(:) + lambda * w));
            assert(~isnan(sum(w(:))));
            gradient = zeros(size(x));            
            for o = 1 : obj.numClasses
                idx = (o-1) * obj.featureSize+1;
                gradient(o,:) = w(idx : idx+obj.featureSize-1);
            end
            logProb = obj.outputData .* log(itemProb);
            logProb(obj.outputData==0)=0;
            error = -sum(sum(logProb,2).*obj.weighting) + lambda * 0.5 * w' * w;

            
            
        end
        
        function [] = learnFunction(obj, inputData, outputData, weighting)
            
            if(~isempty(inputData) && ~isempty(outputData) )
                
                if (~exist('weighting', 'var') || isempty(weighting) )
                    weighting = ones(size(inputData,1),1);
                end
                
                
                
                if (size(outputData, 2) == 1 && obj.numClasses > 1)
                    outputData = full(ind2vec(outputData'))';
                    if (size(outputData,2) < obj.numClasses)
                        outputData = [outputData, zeros(size(outputData,1),obj.numClasses - size(outputData,2))];
                    end
                end
                
                
                if(obj.resetTheta)
                    thetaAllItems = zeros(obj.numClasses, obj.featureSize);
                else
                    thetaAllItems = obj.functionApproximator.thetaAllItems;
                end
                obj.outputData  = outputData(weighting>1e-8,:);
                obj.inputData   = inputData(weighting>1e-8,:);
                obj.weighting   = weighting(weighting>1e-8);
                obj.phiAll      = inputData(weighting>1e-8,:);
                
                options = obj.getOptimizationOptions();
%                 tic
                thetaAllItems = fminunc(@obj.errorFunction,thetaAllItems,options);
                obj.functionApproximator.setThetaAllItems(thetaAllItems);
%                 toc
            end
        end
        
        function [options] = getOptimizationOptions(obj)
            display = 'off';
            if (obj.isDebug)
                display = 'iter';
            end
            if (exist('optimoptions', 'builtin'))
                options = optimoptions(@fminunc,'GradObj','on','Hessian','on','Algorithm','trust-region','Display',display,'TolX',obj.softMaxRegressionToleranceX,'TolFun',obj.softMaxRegressionToleranceF);
            else
                options = optimset('GradObj','on','Hessian','on','Algorithm','trust-region-reflective','Display',display,'TolX',obj.softMaxRegressionToleranceX,'TolFun',obj.softMaxRegressionToleranceF);
            end
        end
    end
    
end


%%

