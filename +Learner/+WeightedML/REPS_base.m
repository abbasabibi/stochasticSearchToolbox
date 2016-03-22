classdef REPS_base < Learner.WeightedML.RLByWeightedML
    
    properties(SetObservable,AbortSet )
        numDecisionSteps=0;       

        epsilonAction=0.5;
        repsRegularizationTheta=0;
    end
    
    properties(SetAccess=public )

        divKL;
        theta;
        eta;
        numFeatures= 0;
        
        featureDiff = 0;
        
        stateFeatureName = '';
        expectedStateFeatureName = '';
    end
    
    % Class methods
    methods (Abstract)
        repsdata = getREPSDataStructure(obj, varargin)     
        [optTheta, optEta, val, numIterations] = optimizeInternal(obj, repsdata, optimizationOptions);
        printDivKL(divKL);
    end
    
    methods
        
        function obj = REPS_base(dataManager, policyLearner, rewardName, weightName, stateFeatureName, expectedStateFeatureName, varargin)         
            obj = obj@Learner.WeightedML.RLByWeightedML(dataManager, policyLearner, rewardName, weightName, varargin{:});  

            

            if (exist('stateFeatureName', 'var') && ~isempty(stateFeatureName) )
                obj.stateFeatureName = stateFeatureName;
                obj.addAdditionalInputs(stateFeatureName);
                obj.numFeatures = dataManager.getNumDimensions(stateFeatureName);
            else
                obj.stateFeatureName = '';
            end
            if (exist('expectedStateFeatureName', 'var') &&  ~isempty(expectedStateFeatureName) )
                obj.expectedStateFeatureName = expectedStateFeatureName;
                obj.addAdditionalInputs(expectedStateFeatureName);
            else
                obj.expectedStateFeatureName = '';
            end
            
            %obj.dataManager.addDataEntry(['steps.',weightName], 1);
                        
            obj.theta = zeros(obj.numFeatures, obj.numDecisionSteps + 1);
            obj.eta   = ones(obj.numDecisionSteps + 1, 1);
            obj.linkProperty('numDecisionSteps'); 
            obj.linkProperty('epsilonAction');            
            obj.linkProperty('repsRegularizationTheta');     
        end
        
        function [weighting] = computeWeighting(obj, varargin)
            repsData = getREPSDataStructure(obj, varargin{:});
            [params] = obj.optimizeDualFunction(repsData, obj.getOptimizationOptions());
            
            obj.setParametersFromOptimization(params);
            weighting = obj.computeWeightingFromEtaAndTheta(repsData, obj.eta, obj.theta);
            
            obj.divKL = obj.getKLDivergence(repsData.weighting, weighting);
            obj.featureDiff = obj.computeFeatureDiff(repsData, weighting);
            
        end
        

        
        function obj = initLearner(obj, environment, scenario, settings)
            obj.initLearner@Learner.EpisodicREPS(environment, scenario, settings);
            
            obj.theta = zeros(obj.numFeatures, obj.numDecisionSteps + 1);
            obj.eta   = ones(obj.numDecisionSteps + 1, 1);
        end
        
        %%
        function obj = resetTheta(obj)
            obj.theta = zeros(obj.numFeatures, obj.numDecisionSteps + 1);
        end
        
        
        
        function [divKL] = getKLDivergence(obj, sampleWeighting, weighting)
            
            divKL = obj.getKLDivergenceInternal(sum(weighting,2), sampleWeighting');
            
        end
        
        function [divKL] = getKLDivergenceInternal(obj, newDistribution, oldDistribution)
            oldDistribution = bsxfun(@rdivide, oldDistribution, sum(oldDistribution,1));
            newDistribution = bsxfun(@rdivide, newDistribution, sum(newDistribution,1));
            divKL = obj.nansum(newDistribution.*log(newDistribution./oldDistribution),1)';
        end
        
        function [params, lowerBound, upperBound] = getParametersForOptimization(obj)
            params = [obj.theta(:); obj.eta];
            lowerBound = [- ones(numel(obj.theta), 1) * inf;  1e-12 * ones(numel(obj.eta), 1)];
            upperBound = 1e12 * ones(size(lowerBound));
        end
        
        function obj = setParametersFromOptimization(obj, params)
            obj.theta = reshape(params(1:(obj.numFeatures * (obj.numDecisionSteps + 1))), obj.numFeatures,  obj.numDecisionSteps + 1);
            obj.eta = params(obj.numFeatures * (obj.numDecisionSteps + 1) + (1:obj.numDecisionSteps + 1));
        end
        
        function [newParams] = optimizeDualFunction(obj, repsdata, optimizationOptions)
            
            timeOptimization = tic();
            [curTheta, curEta, val, numIterations] = obj.optimizeInternal(repsdata, optimizationOptions);
            timeOptimization = toc(timeOptimization);
            
            fprintf('Optimization ended with a value of %f and took %f seconds for %d iterations.\n', val, timeOptimization, numIterations);
            fprintf('Thetas reach from %f to %f\n', min(curTheta), max(curTheta));
            fprintf('Etas reach from %f to %f\n', min(curEta), max(curEta));
            
            newParams = [curTheta; curEta];
        end
        
        
        
        function [weighting] = computeWeightingFromEtaAndTheta(obj, repsData, eta, theta)
            features.phi = repsData.stateFeatures;
            features.psi = repsData.expectedFeatures;
            features.meanInit = zeros(1, size(features.phi,1));
            features.numPerTimeStep = size(features.phi,1) ;
            weighting = repsData.weighting;
            reward = repsData.reward;
            
            numSamples = size(features.phi ,2) / (obj.numDecisionSteps+1);
            
            
            
            if(~exist('theta','var') || isempty(theta))
                theta = obj.theta(:);
            end
            
            if(~exist('eta','var') || isempty(eta))
                eta = obj.eta;
            end
            
            advantage = obj.computeAdvantageStruct(theta, eta, features, weighting, reward);
            
            weighting = zeros(numSamples,obj.numDecisionSteps+1);
            ij = true([obj.numDecisionSteps+1,size(features.phi ,2)/(obj.numDecisionSteps+1) ]);
            weighting(ij') = sum(bsxfun(@rdivide,advantage.wgtExpBndLim,advantage.sumWgtExpBndLim),1);
            weighting = reshape(weighting',[],1);
        end
        
        
        %% Compute Advantage        
        function [advantage, maxAdvantage] = computeAdvantage(obj, theta, features, reward)
            numSampledTimeSteps = obj.numDecisionSteps+1;
            numSamples = size(reward,2)/numSampledTimeSteps;
            
            if(obj.numFeatures > 0)
                i = repmat(1:numSampledTimeSteps,features.numPerTimeStep, 1);
                j = 1:features.numPerTimeStep * numSampledTimeSteps;
                
                val = sparse(i(:),j(:), theta)*features.phi;
                nextVal = sparse(i,j,theta)*features.psi;
                
                adv = reward + nextVal - val;
                
                advantage = NaN(numSampledTimeSteps,numSamples);
                ij = reshape(1:numSampledTimeSteps*numSamples,numSampledTimeSteps,numSamples)';
                advantage(ij) = sum(adv,1);
            else
                advantage = reward;
            end
            
            maxAdvantage = max(advantage,[],2);
            
            advantage = bsxfun(@minus,advantage,maxAdvantage);
        end
        
        function advantage = computeAdvantageStruct(obj, theta, eta, features, weighting, reward)
            
            [advantage.lim, advantage.max] = obj.computeAdvantage(theta, features, reward);
            
            advantage.bndLim = reshape(bsxfun(@rdivide,advantage.lim,eta)',1,[]);
            advantage.bndLim(isnan(advantage.bndLim)) = [];
            
            advantage.wgtExpBndLim = bsxfun(@times,weighting,exp(advantage.bndLim));
            advantage.sumWgtExpBndLim = sum(advantage.wgtExpBndLim,2);
        end
        
        %% Objective Function
        
        function [value, gradient, hessian] = dualFunctionThetaSingleFeature(obj, theta, fixedTheta, eta, featureIdx, features, weighting, reward)
            
            fixedTheta(featureIdx:features.numPerTimeStep:end) = theta;
            
            advantage = obj.computeAdvantageStruct(fixedTheta, eta, features, weighting, reward);
            
            value = obj.getDualValue(fixedTheta, eta, features, weighting, advantage);
            

            gradient = obj.getThetaGradient(features, advantage,theta);

            gradient = gradient(featureIdx:features.numPerTimeStep:end);
            
            hessian = obj.getThetaHessian(eta, features, advantage);
            hessian = hessian(featureIdx:features.numPerTimeStep:end,featureIdx:features.numPerTimeStep:end);
            assert(~isnan(value) & ~any(isnan(gradient)) & ~ any(any(isnan(hessian))));
            assert(~isinf(value) & ~any(isinf(gradient)) & ~ any(any(isinf(hessian))));
        end
        
        function [value, gradient, hessian] = dualFunctionSingleEta(obj, theta, eta, etaIdx, features, weighting, reward)
            
            numSamples = size(reward,2)/(obj.numDecisionSteps+1);
            
            
            phi = features.phi(:, (1:numSamples)+(etaIdx-1)*numSamples);
            psi = features.psi(:, (1:numSamples)+(etaIdx-1)*numSamples);
            
            rew = reward(etaIdx, (1:numSamples)+(etaIdx-1)*numSamples);
            wgt = weighting(etaIdx, (1:numSamples)+(etaIdx-1)*numSamples)';
            
            adv = (rew + theta'*psi - theta'*phi)';
            
            bndLimAdv = (adv - max(adv))./eta;
            expBndLimAdv = exp(bndLimAdv);
            sumWgtExpBndLimAdv = wgt'*expBndLimAdv;
            logSumWgt = log(sum(wgt));
            
            value = obj.epsilonAction*eta - eta*logSumWgt + eta.*log(sumWgtExpBndLimAdv) + obj.repsRegularizationTheta * (theta' *theta);
            
            gradient = obj.epsilonAction - logSumWgt + log(sumWgtExpBndLimAdv) - ((wgt.*bndLimAdv)'*expBndLimAdv)/sumWgtExpBndLimAdv;
            
            hessian = ((wgt.*bndLimAdv.^2)'*expBndLimAdv)/(eta*sumWgtExpBndLimAdv) - ((wgt.*bndLimAdv)'*expBndLimAdv).^2/(eta*sumWgtExpBndLimAdv.^2);
            assert(~isnan(value) & ~any(isnan(gradient)) & ~ any(any(isnan(hessian))));
            assert(~isinf(value) & ~any(isinf(gradient)) & ~ any(any(isinf(hessian))));
        end
        
        
        function [value, gradient, hessian] = dualFunctionEta(obj, theta, eta, features, weighting, reward)
            
            advantage = obj.computeAdvantageStruct(theta, eta, features, weighting, reward);
            
            value = obj.getDualValue(theta, eta, features, weighting, advantage);
            
            gradient = obj.getEtaGradient(weighting, advantage);
            
            hessian = obj.getEtaHessian(eta, advantage);
            assert(~isnan(value) & ~any(isnan(gradient)) & ~ any(any(isnan(hessian))));
            assert(~isinf(value) & ~any(isinf(gradient)) & ~ any(any(isinf(hessian))));
        end
        
        function [value, gradient, hessian] = dualFunctionTheta(obj, theta, eta, features, weighting, reward, isdb)
            
            advantage = obj.computeAdvantageStruct(theta, eta, features, weighting, reward);
            
            value = obj.getDualValue(theta, eta, features, weighting, advantage);
            
            
            gradient = obj.getThetaGradient(features, advantage, theta);
            
            hessian = obj.getThetaHessian(eta, features, advantage);
            if(exist('isdb','var') & isdb)
                value, figure(1); plot(gradient); figure(2); imagesc(hessian) %debug...
            end
            assert(~isnan(value) & ~any(isnan(gradient)) & ~ any(any(isnan(hessian))));
            assert(~isinf(value) & ~any(isinf(gradient)) & ~ any(any(isinf(hessian))));
        end
        

        
        function [value, gradient, hessian] = dualFunctionComplete(obj, theta, eta, features, weighting, reward)
            
            advantage = obj.computeAdvantageStruct(theta, eta, features, weighting, reward);
            
            value = obj.getDualValue(theta, eta, features, weighting, advantage);
            
            gradient = obj.getCompleteGradient(features, weighting, advantage, theta);
            
            hessian = obj.getCompleteHessian(theta, eta, features, advantage);
            assert(~isnan(value) & ~any(isnan(gradient)) & ~ any(any(isnan(hessian))));
            assert(~isinf(value) & ~any(isinf(gradient)) & ~ any(any(isinf(hessian))));
        end
        
        %% Dual Value
        function dualValue = getDualValue(obj, theta, eta, features, weighting, advantage)
            
            dualValue = features.meanInit * theta(1:features.numPerTimeStep) +  sum(advantage.max+eta.*(obj.epsilonAction ...
                -log(sum(weighting,2))+log(advantage.sumWgtExpBndLim))) + obj.repsRegularizationTheta * (theta' *theta);
          
        end
        
        %% Gradient
        function gradient = getThetaGradient(obj, features, advantage, theta)
            
            numSampledTimeSteps = obj.numDecisionSteps+1;
            
            phiPart = (features.phi * advantage.wgtExpBndLim') / sparse(1:numSampledTimeSteps,1:numSampledTimeSteps,advantage.sumWgtExpBndLim);
            phiPartFull = full(sum(phiPart,2));
            
            psiPart = (features.psi * advantage.wgtExpBndLim') / sparse(1:numSampledTimeSteps,1:numSampledTimeSteps,advantage.sumWgtExpBndLim);
            psiPartFull = full(sum(psiPart,2));
            if(obj.repsRegularizationTheta ~= 0)
                gradient = [features.meanInit'; zeros(size(features.phi,1)-features.numPerTimeStep ,1  )] +  psiPartFull - phiPartFull + obj.repsRegularizationTheta * theta;
            else
                gradient = [features.meanInit'; zeros(size(features.phi,1)-features.numPerTimeStep ,1  )] +  psiPartFull - phiPartFull;
            end
        end
        
        function gradient = getEtaGradient(obj, weighting, advantage)
            gradient = obj.epsilonAction - log(sum(weighting,2)) + log(advantage.sumWgtExpBndLim) -...
                bsxfun(@rdivide,sum(bsxfun(@times,advantage.wgtExpBndLim,advantage.bndLim),2),advantage.sumWgtExpBndLim);
        end
        
        function gradient = getCompleteGradient(obj, features, weighting, advantage,theta)
            if(obj.numFeatures > 0)
                if(obj.repsRegularizationTheta ~= 0)
                    thetaGradient = obj.getThetaGradient(features, advantage, theta);
                else
                    thetaGradient = obj.getThetaGradient(features, advantage);
                end
                gradient = thetaGradient;
            else
                gradient = [];
            end
            etaGradient = obj.getEtaGradient(weighting, advantage);
            gradient = [gradient; etaGradient];
        end
        
        
        %% Hessian
        function [hessian] = getThetaHessian(obj, eta, features, advantage)
            
            propAdv = bsxfun(@rdivide, advantage.wgtExpBndLim ,advantage.sumWgtExpBndLim);
            % proportional to the advantage (normalized)
            
            difFeatures = features.psi - features.phi;
            
            if(issparse(difFeatures) && nnz(difFeatures) > 0.2*numel(difFeatures))

                    difFeatures = full(difFeatures);

            end
            weights = sparse(1:size(propAdv,2),1:size(propAdv,2), sum(diag(1./eta)*propAdv,1)) ;
            hessian = difFeatures * weights * difFeatures';
            hessian = hessian - (difFeatures * propAdv') *  diag(1./eta) * (propAdv * difFeatures') + obj.repsRegularizationTheta;

        end

        

                
        
        function hessian = getEtaHessian(obj, eta, advantage)
            hessian = bsxfun(@rdivide,sum(bsxfun(@times,advantage.wgtExpBndLim,advantage.bndLim.^2),2),eta.*advantage.sumWgtExpBndLim);
            hessian = diag(hessian - bsxfun(@rdivide,sum(bsxfun(@times,advantage.wgtExpBndLim,advantage.bndLim),2).^2,eta.*advantage.sumWgtExpBndLim.^2));
        end
        
        function hessian = getThetaEtaHessian(obj, theta, eta, features, advantage)
            normAdv = bsxfun(@rdivide, advantage.wgtExpBndLim ,advantage.sumWgtExpBndLim);
            % normalized per time step
            difFeatures = features.psi - features.phi;
            
            hessian = difFeatures*normAdv'*diag(1./eta);
            hessian = hessian - difFeatures*(bsxfun(@times, advantage.bndLim,normAdv)+normAdv)'*diag(1./eta);
            hessian = hessian + bsxfun(@times, sum(bsxfun(@times, advantage.bndLim,normAdv),2)', difFeatures*normAdv'*diag(1./eta));
            hessian = hessian + obj.repsRegularizationTheta* theta;
            
        end
        
        function hessian = getCompleteHessian(obj, theta, eta, features, advantage)
            etaHessian = obj.getEtaHessian(eta, advantage);
            if(obj.numFeatures > 0)
                thetaHessian = obj.getThetaHessian(eta, features, advantage);
                thetaEtaHessian = obj.getThetaEtaHessian(theta, eta, features, advantage);
                hessian = [thetaHessian thetaEtaHessian ;thetaEtaHessian' etaHessian];
            else
                hessian = etaHessian;
            end
        end
        
        %% Misc
        function [value, gradient, gradientNumeric, hessian, hessianNumeric] = getNumericDerivatives(obj, params, fun)
            h = 10^-6;
            
            if(nargout > 3)
                [value,gradient,hessian] = fun(params);
                gradientNumeric = zeros(length(params),1);
                hessianNumeric = zeros(length(params),length(params));
                
                for i = 1:length(params)
                    paramsTemp = params;
                    
                    paramsTemp(i) = params(i)+h;
                    [g1,gD1] = fun(paramsTemp);
                    
                    paramsTemp(i) = params(i)-h;
                    [g2,gD2] = fun(paramsTemp);
                    
                    gradientNumeric(i) = (g1-g2)/(2*h);
                    hessianNumeric(:,i) = (gD1-gD2)/(2*h);
                end
            else
                [value,gradient] = fun(params);
                gradientNumeric = zeros(length(params),1);
                for i = 1:length(params)
                    paramsTemp = params;
                    
                    paramsTemp(i) = params(i)+h;
                    g1 = fun(paramsTemp);
                    
                    paramsTemp(i) = params(i)-h;
                    g2 = fun(paramsTemp);
                    
                    gradientNumeric(i) = (g1-g2)/(2*h);
                end
            end
        end
        
        function [] = printMessage(obj, trial, data)
            if(exist('data','var') && ~isempty(data) )
                fprintf('Average Return: %f\n', mean(data.getDataEntry('returns')));
            end
            obj.printDivKL(obj.divKL);
        end

        function featureDiff = computeFeatureDiff(obj, repsData, weighting)
            featureDiff = [];
        end
        
        function s = nansum(obj,X, DIM)
            % to avoid statistics toolbox usage
            Y = X;
            Y(isnan(Y)) = 0;
            s = sum(Y,DIM);
        end
    end
    
    methods (Access = protected)
        function [] = registerWeightingFunction(obj)                        
            obj.addDataManipulationFunction('computeWeighting', {obj.rewardName, obj.additionalInputData{:}}, {obj.outputWeightName});                        
        end
        
    end
    

end

