classdef REPS_infhorizon_iter <  Learner.WeightedML.REPS_base;

    methods (Static)
        function [learner] = CreateFromTrial(trial)
            rewardName='rewards';
            weightName='sampleWeights'; 
            stateFeatureName=trial.stateFeatures.outputName;
            expectedStateFeatureName=trial.modelLearner.outputName;
            learner = Learner.SteadyStateRL.REPS_infhorizon_iter(trial.dataManager, trial.policyLearner, rewardName, weightName,stateFeatureName, expectedStateFeatureName);
        end
    end    
    
   properties(SetAccess=public, SetObservable, AbortSet)
       
       thetaOptimizer = [];
       etaOptimizer = [];
       
       minOptiSteps = 2;
       maxOptiSteps = 20;
       

       
       tolKL = 0.1;
       tolSF = 0.05;
       offsetValue = [];
       
       %for logging
       repsAvgReward;
       repsPredReward;
       
       %for optimization
       usetomlab = false;
       optimalg =9;
   end
   
   % Class methods
   methods

        function obj = REPS_infhorizon_iter(dataManager, policyLearner, rewardName, weightName,stateFeatureName, expectedStateFeatureName, varargin)  


            obj@Learner.WeightedML.REPS_base(dataManager, policyLearner, rewardName, weightName, stateFeatureName, expectedStateFeatureName, 'steps')  ;
            % TODO: REPSBASE constructor bug - doesn't work if I pass {} as varargin!
            %obj.linkProperty('thetaOptimizer');
            %obj.linkProperty('etaOptimizer');

            obj.linkProperty('maxOptiSteps');
            obj.linkProperty('tolKL');
            obj.linkProperty('tolSF');

            obj.linkProperty('optimalg');
            obj.linkProperty('usetomlab');
            obj.numDecisionSteps = 0;
         
            obj.initThetaOptimizer();
            obj.initEtaOptimizer();
        end       

        function[params] = getOptimizationOptions(obj)
            params = [];
        end     

      
      function initThetaOptimizer(obj)
          if(isempty(obj.thetaOptimizer))
              
            if(obj.usetomlab)
                tomlabOptions = ProbDef;

                switch obj.optimalg
                    case 0
                        tomlabOptions.Solver.Tomlab = 'ucSolve';
                        tomlabOptions.Alg = 0; %default value
                    case 1
                        tomlabOptions.Solver.Tomlab = 'ucSolve';
                        tomlabOptions.Alg = 1;
                    case 2
                        tomlabOptions.Solver.Tomlab = 'ucSolve';
                        tomlabOptions.Alg = 2;
                    case 3
                        tomlabOptions.Solver.Tomlab = 'ucSolve';
                        tomlabOptions.Alg = 3;
                    case 4
                        tomlabOptions.Solver.Tomlab = 'ucSolve';
                        tomlabOptions.Alg = 4;
                    case 5
                        tomlabOptions.Solver.Tomlab = 'ucSolve';
                        tomlabOptions.Alg = 5;
                    case 6
                        tomlabOptions.Solver.Tomlab = 'ucSolve';
                        tomlabOptions.Alg = 6;
                    case 7
                        tomlabOptions.Solver.Tomlab = 'ucSolve';
                        tomlabOptions.Alg = 7;
                    case 8
                        tomlabOptions.Solver.Tomlab = 'ucSolve';
                        tomlabOptions.Alg = 8;
                    case 9
                        tomlabOptions.Solver.Tomlab = 'snopt';
                    case 10
                        tomlabOptions.Solver.Tomlab = 'knitro';

                end
                obj.thetaOptimizer = Optimizer.FMinUnc_tomlab(numel(obj.theta),true,true,tomlabOptions);
            else
                obj.thetaOptimizer = Optimizer.FMinUnc(numel(obj.theta),true,true);
            end
            
            obj.thetaOptimizer.setOptions();
          end
      end
      
      function initEtaOptimizer(obj)
          if(isempty(obj.etaOptimizer))
            obj.etaOptimizer = Optimizer.FMinCon(1,1e-5,1e8);
            obj.etaOptimizer.useHessian = 'user-supplied';
          end
      end
        function printDivKL(obj, divKL)
            fprintf('divKL: %f\n', divKL);
        end
        
        function repsdata = getREPSDataStructure(obj, rewards, stateFeatures, expectedFeatures, weighting)
            nonzerofeaturesidx = sum(stateFeatures.^2)~=0;
            repsdata.stateFeatures    = stateFeatures(:,nonzerofeaturesidx )';
            repsdata.expectedFeatures = expectedFeatures(:,nonzerofeaturesidx )';
            repsdata.meanInit         = zeros(size(repsdata.stateFeatures,2),1);
            repsdata.numPerTimeStep   = size(repsdata.stateFeatures,1) ;
            repsdata.reward           = rewards';
            
            obj.theta = zeros(repsdata.numPerTimeStep, obj.numDecisionSteps + 1);
            obj.numFeatures = repsdata.numPerTimeStep;
            
            if(exist('weighting','var'))
                repsdata.weighting        = weighting;
            else
                n = size(repsdata.reward,2);
                repsdata.weighting  =  ones(1,n)/n;
            end
        end
        
      function [curTheta, curEta, finalVal, optiStep] = optimizeInternal(obj, repsdata, reward)
             features.phi = repsdata.stateFeatures;
            features.psi = repsdata.expectedFeatures; 
            features.meanInit = zeros(1, size(features.phi,1));
            features.numPerTimeStep = size(features.phi,1) ;
            
            
            
            weighting = repsdata.weighting;
            reward = repsdata.reward;
            
         % curTheta = obj.theta(:);
          %curEta = obj.eta;
            curTheta = zeros(size(obj.theta(:)));
            curEta = ones(size(obj.eta));
%           Q = squeeze(data.reward_NEW(end:-1:1,:,:));
%           if(obj.normalizeReward)
%               Q = 1e5*(Q - max(Q(:)))./range(Q(:));
%           end
% 
%           Q = cumsum(Q,1);
%           Q = Q(end:-1:1,:)';
          
         
          
          obj.offsetValue = [];

                    
          optiStep = 1;
          belowMinStep = optiStep <= obj.minOptiSteps;
          belowMaxStep = optiStep <= obj.maxOptiSteps;
          metTerminationCriteria = false;
          [validSF, maxStdSFError] = obj.checkSF(repsdata, repsdata.weighting(:));
          fprintf('\t\tInit feature error: %f\n',maxStdSFError);
          %timeThetaOptimization = tic();
          %[curTheta, thetaVal, thetaNumIterations] = obj.optimizeTheta( curTheta, curEta, features, weighting, reward);
          %timeThetaOptimization = toc(timeThetaOptimization);
          
          %fprintf('\t\tEnded with a value of %f and took %f seconds for %d iterations.\n', thetaVal, timeThetaOptimization, thetaNumIterations);
          %fprintf('\t\tThetas reach from %f to %f\n', min(curTheta), max(curTheta));
    
          validKL = false;
          numStepsNoKL = 0;
          while( belowMaxStep && (belowMinStep || ~metTerminationCriteria) )
              fprintf('\nOptiStep: %d\n',optiStep);
              timeOptiStep = tic();
                                                      
              % Eta optimization
              if (~validKL || numStepsNoKL > 5)
                  fprintf('\tEta optimization\n');
                  timeEtaOptimization = tic();
                  [curEta, etaVal, etaNumIterations] = obj.optimizeEta(curTheta, curEta, features, weighting, reward);
                  timeEtaOptimization = toc(timeEtaOptimization);

                  fprintf('\t\tEnded with a value of %f and took %f seconds for %d iterations.\n', etaVal, timeEtaOptimization, etaNumIterations);
                  fprintf('\t\tEtas reach from %f to %f\n', min(curEta), max(curEta));

                  rewardWeighting = obj.computeWeightingFromEtaAndTheta(repsdata, curEta, curTheta );
                  kl = obj.getKLDivergence( weighting,rewardWeighting);
                  [validKL, maxAbsKLError] = obj.checkKL(kl);              
                  [validSF, maxStdSFError] = obj.checkSF(repsdata, rewardWeighting);
                  metTerminationCriteria = validKL & validSF;
                  fprintf('\t\tmaxAbsKLError: %g, maxAbsStdSFError: %g\n',maxAbsKLError,maxStdSFError);
                  numStepsNoKL = 0;
              else
                   fprintf('\tKL still valid, skipping KL optimization\n');
                   numStepsNoKL = numStepsNoKL + 1;                  
              end
              % End Eta Optimization
              
              % Theta Optimization
              if (~validSF)
                  fprintf('\tTheta optimization\n')
                  


                  timeThetaOptimization = tic();                            
                  [curTheta, thetaVal, thetaNumIterations] = obj.optimizeTheta( curTheta, curEta, features, weighting, reward);
                  timeThetaOptimization = toc(timeThetaOptimization);

                  fprintf('\t\tEnded with a value of %f and took %f seconds for %d iterations.\n', thetaVal, timeThetaOptimization, thetaNumIterations);
                  fprintf('\t\tThetas reach from %f to %f\n', min(curTheta), max(curTheta));

                  rewardWeighting = obj.computeWeightingFromEtaAndTheta(repsdata, curEta, curTheta );
                  kl = obj.getKLDivergence(weighting,rewardWeighting);
                  [~, maxAbsKLError] = obj.checkKL(kl);
                  validKL = maxAbsKLError < obj.tolKL*obj.epsilonAction;
                  [validSF, maxStdSFError] = obj.checkSF(repsdata, rewardWeighting);
                  metTerminationCriteria = validKL & validSF;
                  fprintf('\t\tmaxAbsKLError: %g, maxAbsStdSFError: %g\n',maxAbsKLError,maxStdSFError);
              else
                   fprintf('\tSF still valid, skipping SF optimization\n');
              end
              % End Theta Optimization
               
              %End of current OptiStep
              optiStep = optiStep+1;
              belowMinStep = optiStep <= obj.minOptiSteps;
              belowMaxStep = optiStep <= obj.maxOptiSteps;
              
              
              timeOptiStep = toc(timeOptiStep);
              

              fprintf('\tOptistep took %f seconds.\n',timeOptiStep);
              
          end
 
          obj.repsPredReward = rewardWeighting' * reward';
          obj.repsAvgReward = mean(reward);
          advantage = obj.computeAdvantageStruct(curTheta, curEta, features, weighting, reward);
          finalVal = obj.getDualValue(curTheta, curEta, features, weighting, advantage);
          
      end
      

      
      function [curTheta, thetaVal, thetaNumIterations] = optimizeTheta(obj, curTheta, curEta, features, weighting, reward)
          %obj.thetaOptimizer.outputFun = @(params, optimizerValues, optimizerState) obj.satisfiedSF(data, params, curEta, optimizerValues, optimizerState);
          
          [curTheta, thetaVal, thetaNumIterations] = obj.thetaOptimizer.optimize(@(theta) obj.dualFunctionTheta(theta, curEta, features, weighting, reward), curTheta);  
      end
      
      function [curEta, etaVal, etaNumIterations] = optimizeEta(obj,  curTheta, curEta, features, weighting, reward)
          [limAdv maxAdv] = obj.computeAdvantage(curTheta, features, reward);
          for etaIdx = 1:numel(curEta)
%               fprintf('EtaIdx: %d\n',etaIdx);
              %if(etaIdx < numel(curEta))
              %  oldDistribution = data.sampleWeighting(etaIdx:(obj.numDecisionSteps+1):end);
                %obj.etaOptimizer.outputFun = @(params, optimizerValues, optimizerState) obj.satisfiedSingleKL(oldDistribution, limAdv(etaIdx,:)', params, optimizerValues, optimizerState);
              %end
              [curEta(etaIdx), etaVal, etaNumIterations] = obj.etaOptimizer.optimize(@(eta) obj.dualFunctionSingleEta(curTheta, eta, etaIdx, features, weighting, reward), curEta(etaIdx) );
              
              
          end
      end
      
      function stop = satisfiedSingleKL(obj, oldDistribution, limAdv, curEta, optimizerValues, optimizerState)
         stop = false;
          if(strcmpi(optimizerState,'done' ) || (strcmpi(optimizerState,'iter' ) && ~mod(optimizerValues.iteration,1)))
              wgtExpBndLimAdv = oldDistribution.*exp(limAdv./curEta);
              newDistribution = wgtExpBndLimAdv./sum(wgtExpBndLimAdv);
              [stop, maxAbsError] = obj.checkKL(obj.getKLDivergenceInternal(newDistribution, oldDistribution));
%               fprintf('Optimization. Iter: %d MaxAbsKLError: %g\n',optimizerValues.iteration, maxAbsError);
          end
      end
%       
%       function stop = satisfiedKL(obj, data, curTheta, curEta, optimizerValues, optimizerState)
%          stop = false;
%           if(strcmpi(optimizerState,'done' ) || (strcmpi(optimizerState,'iter' ) && ~mod(optimizerValues.iteration,10)))
%               rewardWeighting = obj.weightingFunction(data, curTheta, curEta);
%               
%               [stop, maxAbsError] = obj.checkKL(obj.getKLDivergence(data,rewardWeighting));
%               fprintf('\t\tIter: %d MaxAbsKLError: %g\n',optimizerValues.iteration, maxAbsError);
%           end
%       end
      
%       function stop = satisfiedSF(obj, data, curTheta, curEta, optimizerValues, optimizerState)
%          stop = false;
%          if(strcmpi(optimizerState,'iter' ) && ~mod(optimizerValues.iteration,50) && optimizerValues.iteration > 0)
%               rewardWeighting = obj.weightingFunction(data, curTheta, curEta);
%               
%               [stop, maxAbsError] = obj.checkSF(repsdata, rewardWeighting);
%               fprintf('\t\tIter: %d MaxAbsSFError: %g, FunctionVal %f\n',optimizerValues.iteration, maxAbsError, optimizerValues.fval);
%          end
%       end
      
      function [validKL, maxAbsError] = checkKL(obj, divKL)
          maxAbsError = max(abs(divKL(:)-obj.epsilonAction));
          validKL = maxAbsError < obj.tolKL*obj.epsilonAction * 0.1;
      end
      
      function [validSF, maxStdError] = checkSF(obj, repsdata, rewardWeighting)
          stateFeatureDiff = obj.getStateFeatureDifference(repsdata, rewardWeighting);
          %stateFeatureDiff = stateFeatureDiff(1:end-1,:);
          maxStdError = max(abs(stateFeatureDiff(:)));
          validSF = maxStdError < obj.tolSF;
      end
      
      function StateFeatureDiff = getStateFeatureDifference(obj, repsdata, weighting)
          


         
          
          StateFeatureDiff = bsxfun(@rdivide,(repsdata.stateFeatures - repsdata.expectedFeatures)*weighting,std(repsdata.stateFeatures,0,2));
      end
      
   end
end