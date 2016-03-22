classdef HiREPSIter < Learner.WeightedML.HiREPS_base
    %REPS_INFHORIZON Reps for infinite horizon problems
    
    properties(SetAccess=public, SetObservable, AbortSet)
        thetaOptimizer = [];
        etaXiOptimizer = [];
        
        
        minOptiSteps = 2;
        maxOptiSteps = 50;
        
        
        
        tolKL = 0.1;
        tolSF = 0.005;
        offsetValue = [];
        
        %for logging
        repsAvgReward;
        repsPredReward;
    end
    
    methods
        function obj = HiREPSIter(dataManager, policyLearner, rewardName, ...
                weightName, responsibilitiesName, stateFeatureName, expectedStateFeatureName, varargin)
            
            if(~exist('stateFeatureName','var'))
                stateFeatureName = '';
            end
            if(~exist('expectedStateFeatureName'))
                expectedStateFeatureName = '';
            end
            
            
            obj@Learner.WeightedML.HiREPS_base(dataManager, policyLearner, rewardName, weightName, ...
                responsibilitiesName,  stateFeatureName, expectedStateFeatureName)  ;
            % TODO: REPSBASE constructor bug - doesn't work if I pass {} as varargin!
            
            obj.linkProperty('maxOptiSteps');
            obj.linkProperty('tolKL');
            obj.linkProperty('tolSF');
            obj.numDecisionSteps = 0;
            
            obj.initThetaOptimizer();
            obj.initEtaXiOptimizer();
            obj.repsRegularizationTheta=1e-8;
        end
        
        function initThetaOptimizer(obj)
            if(isempty(obj.thetaOptimizer))
                useGradient = true;
                useHessian  = true;                
                obj.thetaOptimizer = Optimizer.FMinUnc(numel(obj.theta), useGradient, useHessian, 'HiREPS');
                obj.thetaOptimizer.setOptions();
            end
        end
        
        function initEtaXiOptimizer(obj)
            if(isempty(obj.etaXiOptimizer))
                obj.etaXiOptimizer = Optimizer.FMinCon(2,[1e-5,0] , [1e8, 10], 'HiREPS');
                obj.etaXiOptimizer.useHessian = 'off';
            end
        end
        
        
        %% optimizeInternal
        function [curTheta, curEta, curXiEta, finalVal, optiStep] = optimizeInternal(obj, repsData)
            
            features.phi            = repsData.stateFeatures;
            features.psi            = repsData.expectedFeatures;
            features.meanInit       = repsData.meanInit;
            features.numPerTimeStep = size(features.phi,1) ;
            
            
            weighting           = repsData.weighting;
            reward              = repsData.reward;
            responsibilities    = repsData.responsibilities;
            
            curTheta            = zeros(size(obj.theta(:)));
            curEta              = obj.eta;
            if(obj.epsilonOption > 2 && false)
                curXiEta = 0;
            else                
                curXiEta        = obj.xi ./ obj.eta;
            end
            
            curXi               = curXiEta .* curEta;
            obj.offsetValue     = [];
            
            
            optiStep = 1;
            belowMinStep = optiStep <= obj.minOptiSteps;
            belowMaxStep = optiStep <= obj.maxOptiSteps;
            metTerminationCriteria = false;
            [validSF, maxStdSFError] = obj.checkSF(repsData, repsData.weighting(:));
            msg = 'Init feature error:';
            fprintf('%50s %.3g\n', msg, maxStdSFError);
            
            validKL = false;
            numStepsNoKL = 0;
            while( belowMaxStep && (belowMinStep || ~metTerminationCriteria) )
                
                % Eta optimization
                if (~validKL || numStepsNoKL > 5)
                    timeEtaOptimization         = tic();
                    [curEta, curXiEta, etaVal, etaNumIterations] = obj.optimizeEtaXi(curTheta, curEta, curXiEta, features,responsibilities, weighting, reward);
                    timeEtaOptimization         = toc(timeEtaOptimization);
                    
                    curXi                       = curXiEta .* curEta;
                    [resps, rewardWeighting]    = obj.computeWeightingFromEtaAndTheta(repsData, curEta, curTheta, curXi );
                    kl                          = obj.getKLDivergence( weighting,rewardWeighting);
                    [validKL, maxAbsKLError]    = obj.checkKL(kl);
                    [validSF, maxStdSFError]    = obj.checkSF(repsData, rewardWeighting);
                    metTerminationCriteria      = validKL & validSF;
                    numStepsNoKL = 0;
                else
                    numStepsNoKL = numStepsNoKL + 1;
                end
                % End Eta Optimization
                
                % Theta Optimization
                if (~validSF)
                    timeThetaOptimization       = tic();
                    [curTheta, thetaVal, thetaNumIterations] = obj.optimizeTheta( curTheta, curEta, curXiEta, features,responsibilities, weighting, reward);
                    timeThetaOptimization       = toc(timeThetaOptimization);
                    
                    
                    [resps, rewardWeighting]    = obj.computeWeightingFromEtaAndTheta(repsData, curEta, curTheta, curXi );
                    kl                          = obj.getKLDivergence(weighting,rewardWeighting);
                    [~, maxAbsKLError]          = obj.checkKL(kl);
                    validKL                     = maxAbsKLError < obj.tolKL*obj.epsilonAction;
                    [validSF, maxStdSFError]    = obj.checkSF(repsData, rewardWeighting);
                    metTerminationCriteria      = validKL & validSF;
                end
                % End Theta Optimization
                
                %End of current OptiStep
                optiStep        = optiStep+1;
                belowMinStep    = optiStep <= obj.minOptiSteps;
                belowMaxStep    = optiStep <= obj.maxOptiSteps;                
                
                
            end
            
            obj.repsPredReward  = rewardWeighting' * reward';
            obj.repsAvgReward   = mean(reward);
            advantage           = obj.computeAdvantageStruct(curTheta, curEta,curXi, features, responsibilities, weighting, reward);
            finalVal            = obj.getDualValue(curTheta, curEta, curXiEta, features, weighting, advantage);
            
        end
        
        
        %% getREPSDataStructure
        function repsData = getREPSDataStructure(obj, rewards, stateFeatures, expectedFeatures, responsibilities, weighting)
            %TODO - make sure input args are registered!
            %See:obj.addDataManipulationFunction('computeWeighting', {obj.rewardName, obj.additionalInputData{:}}, {obj.outputWeightName});
            
            %Would need some demuxing here!            
            if(obj.numFeatures > 0)
                repsData.stateFeatures    = stateFeatures';
                repsData.numPerTimeStep   = obj.numFeatures;
                
                if( isempty(obj.expectedStateFeatureName) )
                    repsData.meanInit           = mean(repsData.stateFeatures,2)';
                    repsData.expectedFeatures   = zeros(size(repsData.stateFeatures));
                    repsData.responsibilities   = expectedFeatures; % <---------------- HORRIBLE HACK HERE! Because of demuxing.
                else
                    repsData.meanInit           = zeros(1, size(expectedFeatures,2));
                    repsData.expectedFeatures   = expectedFeatures';
                    repsData.responsibilities   = responsibilities;
                end
            else
                repsData.meanInit           = zeros(1,0);
                repsData.stateFeatures      = zeros(0, size(rewards,1));
                repsData.expectedFeatures   = zeros(0, size(rewards,1));                
                repsData.numPerTimeStep     = obj.numFeatures;
                repsData.responsibilities   = stateFeatures; % <---------------- HORRIBLE HACK HERE!
            end
            
            repsData.reward                 = rewards';
            if(exist('weighting','var'))
                repsData.weighting          = weighting;
            else
                n = length(repsData.reward);
                repsData.weighting          =  ones(1,n)/n;
            end
            
            obj.eta = ones(size(obj.eta)) ;
            if( std(rewards) > 0 )
                obj.eta = obj.eta .* std(rewards);
            end                
            obj.xi  = obj.eta;
            
        end
        
        
        
        function printDivKL(obj, divKL)
            msg = 'divKL:';
            fprintf('%50s %.3g\n', msg, divKL);
        end
        
        function[params] = getOptimizationOptions(obj)
            params = [];
        end
        
        %% optimizeTheta
        function [curTheta, thetaVal, thetaNumIterations] = optimizeTheta(obj, curTheta, curEta, curXiEta, features, responsibilities, weighting, reward)
            f       = @(theta)obj.dualFunctionCompleteTheta(theta, curEta, curXiEta, features, responsibilities, weighting, reward);
            params0 = curTheta;
            [curTheta, thetaVal, thetaNumIterations] = obj.thetaOptimizer.optimize(f, params0 );
        end
        
        %% optimizeEta
        function [curEta, curXiEta, etaVal, etaNumIterations] = optimizeEtaXi(obj,  curTheta, curEta, curXiEta,  features, responsibilities, weighting, reward)
            f           = @(params)obj.dualFunctionCompleteEtaXi(curTheta, params(1), params(2), features, responsibilities, weighting, reward);
            params0     = [curEta, curXiEta];
            [paramsOpt, etaVal, etaNumIterations] = obj.etaXiOptimizer.optimize(f, params0 );
            curEta      = paramsOpt(1);
            curXiEta    = paramsOpt(2);
            
        end

        
        %% checkKL
        function [validKL, maxAbsError] = checkKL(obj, divKL)
            maxAbsError = max(abs(divKL(:)-obj.epsilonAction));
            validKL = maxAbsError < obj.tolKL*obj.epsilonAction * 0.1;
        end
        
        %% checkSF
        function [validSF, maxStdError] = checkSF(obj, repsdata, rewardWeighting)
            stateFeatureDiff = obj.computeFeatureDiff(repsdata, rewardWeighting);
            maxStdError = max(abs(stateFeatureDiff(:)));
            validSF = maxStdError < obj.tolSF;
        end
        
%         %% getStateFeatureDifference
%         function featureDiff = getStateFeatureDifference(obj, repsData, weighting)
%             
%             featureDiff = 0;
%             if(~isempty(repsData.stateFeatures))
%                 if( isempty(obj.expectedStateFeatureName) )
%                     featureDiff = sum(bsxfun(@times, repsData.stateFeatures', weighting)) - repsData.meanInit;
%                 else
%                     featureDiff = bsxfun(@rdivide,(repsData.stateFeatures - repsData.expectedFeatures)*weighting,std(repsData.stateFeatures,0,2));
%                 end
%             end
% 
%         end
        
        
        
    end
    
end

