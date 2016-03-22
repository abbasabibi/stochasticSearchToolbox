classdef HiREPS_base < Learner.WeightedML.REPS_base
    
    properties(SetObservable,AbortSet )
       
        epsilonOption = 1;
    end
    
    properties(SetAccess=public )    
        xi;
        responsibilitiesName = '';
        outputRespName = 'outputResponsibilities';
    end
    
   
    
    methods
        
        function obj = HiREPS_base(dataManager, policyLearner, rewardName, weightName, responsibilitiesName, stateFeatureName, expectedStateFeatureName, varargin)         
            obj = obj@Learner.WeightedML.REPS_base(dataManager, policyLearner, rewardName, weightName, stateFeatureName, expectedStateFeatureName, varargin{:});  

            if (exist('responsibilitiesName', 'var'))
                obj.responsibilitiesName = responsibilitiesName;
                obj.addAdditionalInputs(responsibilitiesName);
                obj.outputRespName = ['output',upper(responsibilitiesName(1)),responsibilitiesName(2:end)];
            end
            
            obj.registerWeightingFunction();

            obj.xi = ones(obj.numDecisionSteps + 1, 1);

            obj.linkProperty('epsilonOption');
            
            dataManager.addDataEntry('XiEta', 1);
            
       
        end
        
        function [resps, weighting, XiEta] = computeWeighting(obj, varargin)
            repsData    = getREPSDataStructure(obj, varargin{:});
            [params]    = obj.optimizeDualFunction(repsData, obj.getOptimizationOptions());
            
            obj.setParametersFromOptimization(params);
            [resps, weighting] = obj.computeWeightingFromEtaAndTheta(repsData, obj.eta, obj.theta, obj.xi);
            
            
            obj.divKL   = obj.getKLDivergence(repsData.weighting, weighting);
            obj.featureDiff = obj.computeFeatureDiff(repsData, weighting);
            
            XiEta       = obj.xi ./ obj.eta;
            
        end
        
         %% computeWeightingFromEtaAndTheta
        function [resps, weighting] = computeWeightingFromEtaAndTheta(obj, repsData, eta, theta, xi)
            features.phi = repsData.stateFeatures;
            features.psi = repsData.expectedFeatures;
            features.meanInit = zeros(1, size(features.phi,1));
            features.numPerTimeStep = size(features.phi,1) ;
            resps = repsData.weighting;
            reward = repsData.reward;
            responsibilities = repsData.responsibilities;
            
            numSamples = size(features.phi ,2) / (obj.numDecisionSteps+1);
            
            
            
            if(~exist('theta','var') || isempty(theta))
                theta = obj.theta(:);
            end
            
            if(~exist('eta','var') || isempty(eta))
                eta = obj.eta;
            end
            advantage = obj.computeAdvantageStruct(theta, eta, xi, features, responsibilities, resps, reward);
            
%             weighting = zeros(numSamples,obj.numDecisionSteps+1);
%             ij = true([obj.numDecisionSteps+1, numSamples ]);
%             weighting = bsxfun(@rdivide,advantage.wgtExpBndLimPerOption,advantage.sumWgtExpBndLim)';
%             weighting = reshape(weighting',[],1);
            resps = advantage.wgtExpBndLimPerOption';            
            assert(~isnan(any(resps(:))));
            
            weighting   = sum(resps,2);
            resps       = bsxfun(@rdivide, resps, weighting);
            
            weighting   = weighting / sum(weighting);
            resps(isnan(resps)) = 0;
            
        end

        function updateModel(obj, data)
%             obj.policyLearner.functionApproximator.callDataFunction('computeResponsibilities', data)
            obj.updateModel@Learner.WeightedML.REPS_base(data);
        end


        %% InitLearner
        function obj = initLearner(obj, environment, scenario, settings)
            obj.initLearner@Learner.WeightedML.REPS_base(environment, scenario, settings);            
            obj.xi   = ones(obj.numDecisionSteps + 1, 1);
        end
        
        
        %% GetParametersForOptimization
        function [params, lowerBound, upperBound] = getParametersForOptimization(obj)
            [params, lowerBound, upperBound] = obj.getParametersForOptimization@Learner.WeightedML.REPS_base();
            params      = [params; obj.xi./obj.eta];
            lowerBound  = [lowerBound; zeros(numel(obj.xi), 1)];
            upperBound  = [upperBound; 10 * ones(numel(obj.xi),1)];
        end
        
        %% SetParametersFromOptimization
        function obj = setParametersFromOptimization(obj, params)
            obj.setParametersFromOptimization@Learner.WeightedML.REPS_base(params);
            obj.xi = params((obj.numFeatures+1) * (obj.numDecisionSteps + 1) + (1:obj.numDecisionSteps + 1) );
            obj.xi = obj.xi .* obj.eta;
        end
        

        %% optimizeDualFunction
        function [newParams] = optimizeDualFunction(obj, repsData, optimizationOptions)
            
            timeOptimization = tic();
            [curTheta, curEta, curXiEta, val, numIterations] = obj.optimizeInternal(repsData);
            timeOptimization = toc(timeOptimization);
            
            
            msg = 'Optimization ended with a value of:';
            fprintf('%50s %.3g\n',msg, val);
            msg = 'Optimization took:';
            fprintf('%50s %.3g seconds\n', msg, timeOptimization);
            msg = 'Optimization used:';
            fprintf('%50s %d iterations\n', msg, numIterations);
            
            if(obj.numFeatures > 0)
                msg = 'Thetas reach from:';
                fprintf('%50s %.3g \t to %.3g\n', msg,  min(curTheta), max(curTheta));
                msg = 'Feature differences reach from:';
                fprintf('%50s %.3g \t to %.3g\n', msg, min(obj.featureDiff), max(obj.featureDiff));
            end
            msg = 'Etas reach from:';
            fprintf('%50s %.3g \t to %.3g\n', msg, min(curEta), max(curEta));
            msg = 'XiEtas reach from:';
            fprintf('%50s %.3g \t to %.3g\n', msg, min(curXiEta), max(curXiEta));
            
            newParams = [curTheta; curEta; curXiEta];
        end
        
        
       
%         
        %% computeAdvantageStruct
        function advantage = computeAdvantageStruct(obj, theta, eta, xi, features, responsibilities, weighting, reward)
            numSampledTimeSteps = obj.numDecisionSteps+1;
            numSamplesPerStep   = size(reward,2)/numSampledTimeSteps;
            [advantage.lim, advantage.max] = obj.computeAdvantage(theta, features, reward);
            
            advantage.bndLim = reshape(bsxfun(@rdivide,advantage.lim,eta)',1,[]);
            advantage.bndLim(isnan(advantage.bndLim)) = [];
            
            xiEta = xi./eta;
            
            xiEtaMat            = repmat(xiEta', numSamplesPerStep, 1); 
            xiEtaMat            = xiEtaMat(:);
            
%             advantage.xiEtaMat  = xiEtaMat;
            
            weightedResp        = bsxfun(@power, responsibilities, (1+xiEtaMat) );
            advantage.respPow   = weightedResp;
            
            weighting           = bsxfun(@times, weightedResp', weighting);
            advantage.wgtExpBndLimPerOption = bsxfun(@times,weighting,exp(advantage.bndLim));
            
            weighting           = sum(weighting,1);
            
            advantage.wgtExpBndLim      = bsxfun(@times,weighting,exp(advantage.bndLim));
            advantage.sumWgtExpBndLim   = sum(advantage.wgtExpBndLim,2);
            
            entropyResp         = -mean(  sum ( responsibilities .* log(responsibilities + 10^-20), 2) );
%             entropyResp         = -mean(  sum (bsxfun(@times,responsibilities, weighting') .* log(responsibilities + 10^-20),2));
%             entropyResp         = sum(entropyResp) / sum(weighting);
            advantage.kappa     = obj.epsilonOption * entropyResp; 
        end
        


        %% dualFunctionCompleteTemplate
        function [value, gradient, hessian] = dualFunctionCompleteTemplate(obj, gradientFunc, hessianFunc, theta, eta, xiEta, features, responsibilities, weighting, reward)            
            
            if(obj.epsilonOption > 2 && false)
                xi = 0;
            else
                xi = xiEta .* eta;
            end
            advantage = obj.computeAdvantageStruct(theta, eta, xi, features, responsibilities, weighting, reward);
            
            value = obj.getDualValue(theta, eta, xi, features, weighting, advantage);
            assert(~isnan(value) & ~isinf(value) );
            if(nargout>1)
                gradient = gradientFunc(features, weighting, advantage, theta, eta, xi, responsibilities);
                assert(~any(isnan(gradient)) & ~any(isinf(gradient)))
            end
            hessian = [];
            if(nargout>2)
                hessian = hessianFunc(theta, eta, xi, features, advantage, responsibilities);
                assert( ~any(any(isnan(hessian))) & ~any(any(isinf(hessian))) )
            end
        end
        
        %% dualFunctionComplete
        function [value, gradient, hessian] = dualFunctionComplete(obj, theta, eta, xiEta, features, responsibilities, weighting, reward)            
            gradientFunc    = @obj.getCompleteGradient;
            hessianFunc     = [];
            [value, gradient] = obj.dualFunctionCompleteTemplate(gradientFunc, hessianFunc, theta, eta, xiEta, features, responsibilities, weighting, reward);
        end
        
        %% dualFunctionEtaXi
        function [value, gradient, hessian] = dualFunctionCompleteEtaXi(obj, theta, eta, xiEta, features, responsibilities, weighting, reward)                        
            gradientFunc    = @obj.getCompleteGradientEtaAndXiEta;
            hessianFunc     = [];
            [value, gradient] = obj.dualFunctionCompleteTemplate(gradientFunc, hessianFunc, theta, eta, xiEta, features, responsibilities, weighting, reward);
        end
        
        %% dualFunctionCompleteTheta
        function [value, gradient, hessian] = dualFunctionCompleteTheta(obj, theta, eta, xiEta, features, responsibilities, weighting, reward)                        
            gradientFunc    = @obj.getCompleteGradientTheta;
            hessianFunc     = @(theta, eta, xi, features, advantage, responsibilities)obj.getThetaHessian(eta, features, advantage);
            [value, gradient, hessian] = obj.dualFunctionCompleteTemplate( gradientFunc, hessianFunc, theta, eta, xiEta, features, responsibilities, weighting, reward);
        end
        
        
        %% getDualValue
        function dualValue = getDualValue(obj, theta, eta, xi, features, weighting, advantage)            
            dualValue = obj.getDualValue@Learner.WeightedML.REPS_base(theta,eta,features,weighting,advantage);
            dualValue = dualValue + advantage.kappa * sum(xi);          
        end
        
        %% getCompleteGradient
        function gradient = getCompleteGradient(obj, features, weighting, advantage, theta, eta, xi, responsibilities)
            gradientTheta       = obj.getCompleteGradientTheta(features, weighting, advantage, theta, eta, xi, responsibilities);
            gradientEtaAndXiEta = obj.getCompleteGradientEtaAndXiEta(features, weighting, advantage, theta, eta, xi, responsibilities);
            gradient            = [gradientTheta; gradientEtaAndXiEta];            
        end
        
        
        %% getCompleteGradientTheta
        function gradient = getCompleteGradientTheta(obj, features, weighting, advantage, theta, eta, xi, responsibilities)
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
        end
        
        %% getCompleteGradientEtaAndXiEta
        function gradient = getCompleteGradientEtaAndXiEta(obj, features, weighting, advantage, theta, eta, xi, responsibilities)
            etaGradient     = obj.getEtaGradient(eta, xi, weighting, advantage);   
            if(obj.epsilonOption > 2 && false)
                xiEtaGradient   = 0;
            else
                xiEtaGradient   = obj.getXiEtaGradient(eta, weighting, advantage, responsibilities);
            end
            
            gradient        = [etaGradient; xiEtaGradient];
        end

        
        %% getEtaGradient
        function gradient = getEtaGradient(obj, eta, xi, weighting, advantage)
            gradient = obj.getEtaGradient@Learner.WeightedML.REPS_base(weighting, advantage);
            gradient = gradient + xi./eta * advantage.kappa;
        end
        
      %% getXiGradient
        function gradient = getXiEtaGradient(obj, eta, weighting, advantage,responsibilities)
            logResp = log(responsibilities + 1e-20);
            gradient = advantage.kappa * eta + ...
                eta * sum( weighting.* sum( advantage.respPow .* logResp, 2)' .* exp(advantage.bndLim) ) / advantage.sumWgtExpBndLim;
        end
         
        
        %% getCompleteHessian
        function hessian = getCompleteHessian(obj, theta, eta, xi, features, advantage, responsibilities)
%             etaEtaHessian       = obj.getEtaHessian(eta, xi, advantage);
%             xiEtaXiEtaHessian   = getxiEtaXiEtaHessian(obj, eta, weighting, advantage, responsibilities);
            if(obj.numFeatures > 0)
                thetaHessian = obj.getThetaHessian(eta, features, advantage);
                thetaEtaHessian = obj.getThetaEtaHessian(theta, eta, features, advantage);
                hessian = [thetaHessian thetaEtaHessian ;thetaEtaHessian' etaHessian];
            else
                hessian = etaHessian;
            end
        end
        
        
        %% getEtaHessian
        function hessian = getEtaHessian(obj, eta, xi, advantage)
            hessian = obj.getEtaHessian@Learner.WeightedML.REPS_base(eta, advantage);
            hessian = hessian - xi./(eta.^2) * advantage.kappa;
        end
        %% getxiEtaXiEtaHessian
        function hessian = getxiEtaXiEtaHessian(obj, eta, weighting, advantage, responsibilities)
            error('shouldnt go here, not implemented')
            logResp     = log(responsibilities + 1e-20);
            Z           = advantage.sumWgtExpBndLim; 
            ZDash       = sum( weighting.* sum( advantage.respPow .* logResp, 2)' .* exp(advantage.bndLim) );
            ZDashDash   = sum( weighting.* sum( advantage.respPow .* logResp.^2, 2)' .* exp(advantage.bndLim) );
            hessian     = eta * (ZDashDash .* Z - ZDash.^2)/ Z.^2;
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
        
        function [] = printMessage(obj, data)
            if(exist('data','var') && ~isempty(data) )
                msg = 'Average Return:';
                fprintf('%50s %.3g\n', msg, mean(data.getDataEntry('returns')));
                
                options = data.getDataEntry('options');
                uniqueOptions = unique(options);
                msg = '#Active Options:';
                fprintf('%50s %d\n', msg, numel(uniqueOptions));
            end
            obj.printDivKL(obj.divKL);
        end
        
        function featureDiff = computeFeatureDiff(obj, repsData, weighting)
            %             featureDiff = 0;
            %             if(~isempty(repsData.stateFeatures))
            %                 featureDiff = sum(bsxfun(@times, repsData.stateFeatures', weighting)) - repsData.meanInit;
            %             end
            featureDiff = 0;
            if(~isempty(repsData.stateFeatures))
                if( isempty(obj.expectedStateFeatureName) )
                    featureDiff = sum(bsxfun(@times, repsData.stateFeatures', weighting)) - repsData.meanInit;
                else
                    featureDiff         = (repsData.stateFeatures - repsData.expectedFeatures)*weighting;
                    idx0                = featureDiff==0;
                    featureDiff(~idx0)  = bsxfun(@rdivide,featureDiff(~idx0),std(repsData.stateFeatures(~idx0,:),0,2));
                end
            end
            obj.featureDiff = featureDiff;
        end

        
    end
    
    methods (Access = protected)
        function [] = registerWeightingFunction(obj)                        
            obj.addDataManipulationFunction('computeWeighting', {obj.rewardName, obj.additionalInputData{:} }, {obj.outputRespName, obj.outputWeightName, 'XiEta'});                        
        end
        
    end
    

end