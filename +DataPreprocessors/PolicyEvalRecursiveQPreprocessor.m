classdef PolicyEvalRecursiveQPreprocessor < DataPreprocessors.DataPreprocessor & Data.DataManipulator
   %%% assume for the moment that squared features are used. Will
   %%% generalize later
   properties      
      rewardToComeName;
      qLearner; 
      policy;
      currentTimeStep;
      saFeatureGenerator;
      
      %debug only-- delete later
      prevSaFeatures;
      lastQVals;
   end
   
   properties (SetObservable, AbortSet)
       numTimeSteps;   
   end
   
   methods
      function obj = PolicyEvalRecursiveQPreprocessor(trial, inputVars, qLearnerClass, qFApprox, policyEvalName, layerName)
            obj = obj@DataPreprocessors.DataPreprocessor();
            obj = obj@Data.DataManipulator(trial.dataManager);            
            obj.linkProperty('numTimeSteps');
            
            obj.policy = trial.actionPolicy;
            obj.saFeatureGenerator = trial.stateActionFeatures;
            
            if (trial.isProperty('learnerDataName')  && ~isempty(trial.learnerDataName))
                obj.dataNamePreprocessor = trial.learnerDataName;
            end
            
            if (~exist('inputVars', 'var') || isempty(inputVars))
                inputVars = {'rewards', 'SquaredStatesActions', 'nextStates', 'rewardsToCome'}; %rewards to come for debug only
            end
            
            if(~iscell(inputVars) || length(inputVars) ~= 4)
                error('inputVars should be a cell containing two entries');
            end
            
            if (~exist('qLearnerClass', 'var') || isempty(qLearnerClass))   
                qLearnerClass = @Learner.SupervisedLearner.LinearFeatureFunctionMLLearner;
            end
            
            if (~exist('qFApprox', 'var') || isempty(qFApprox))   
                qFApprox = Functions.FunctionLinearInFeatures(obj.dataManager, inputVars(1), inputVars(2), 'qApproximator');
            end
            
            if (~exist('policyEvalName', 'var'))
                policyEvalName = 'qValue';
            end
                      
            if (~exist('layerName', 'var'))
                layerName = 'steps';
            end
            
            qFApprox.initObject();
            obj.qLearner = qLearnerClass(obj.dataManager, qFApprox);
         
            obj.dataManager.addDataEntry([layerName, '.', policyEvalName], 1);
            
            obj.addDataManipulationFunction('computeQValue', inputVars, {policyEvalName});            
      end 
      
      function [qvalue] = computeQValue(obj, rewards, stateActionFeatures, nextStates, rewardsToCome)
          if(obj.currentTimeStep == obj.numTimeSteps)
              obj.qLearner.learnFunction(stateActionFeatures, rewards);
              qvalue = rewards;
          else
              %%% getting closed form solution for gaussian policy and
              %%% squaredFeatures. should not be the general case...
              
              % getting the current gaussian policy parameters
              nextActionPolicy = obj.policy.getDistributionForTimeStep(obj.currentTimeStep + 1);
              [muAction, sigma] = nextActionPolicy.getExpectationAndSigma(size(nextStates, 1), nextStates);
              sigma = permute(sigma, [2 3 1]);
              covAction = sigma' * sigma;
              
              % 
              dimState = size(nextStates, 2);
              dimAction = size(muAction, 2);
              
              % extracting quad in action part of the features
              quadPart = [ones(1, dimState) (2*ones(1,dimAction))]; 
              quadPart = obj.saFeatureGenerator.getFeaturesInternal(size(quadPart, 1), quadPart);
              quadPart = quadPart(1, :) == 4;

              %
              meanFeatures = [nextStates muAction];
              meanFeatures = obj.saFeatureGenerator.getFeaturesInternal(size(meanFeatures, 1), meanFeatures);
              meanFeatures(:, quadPart) = meanFeatures(:, quadPart) + repmat(covAction(tril(ones(dimAction)) == 1)', size(meanFeatures, 1),1);

              % debug
%               bias = obj.qLearner.functionApproximator.getExpectation(1, zeros(1, size(stateActionFeatures, 2)));
%               wq = obj.qLearner.functionApproximator.getExpectation(size(stateActionFeatures, 2), eye(size(stateActionFeatures, 2))) - bias * ones(size(stateActionFeatures, 2), 1);
%               wq(1) = wq(1) + bias;
%               objective1 = rewards + meanFeatures * wq;
%               objective2 = rewards + obj.prevSaFeatures * wq; % debug only
%               objective3 = rewards + obj.lastQVals; %debug only
              objective4 = rewards + obj.qLearner.functionApproximator.getExpectation(size(meanFeatures, 1), meanFeatures);
%               objective1 - objective4  
              obj.qLearner.learnFunction(stateActionFeatures, objective4);              
              qvalue = obj.qLearner.functionApproximator.getExpectation(size(stateActionFeatures, 1), stateActionFeatures);
              
              % iterated refining of the qValue  
%               fprintf('first estimation of the qVal, %f\n', var(qvalue - rewardsToCome)/var(rewardsToCome));
%               for i=1:20
%                   obj.qLearner.learnFunction(stateActionFeatures, qvalue - rewards);
%                   obj.qLearner.learnFunction(stateActionFeatures, rewards + obj.qLearner.functionApproximator.getExpectation(size(stateActionFeatures, 1), stateActionFeatures));
%                   qvalue = obj.qLearner.functionApproximator.getExpectation(size(stateActionFeatures, 1), stateActionFeatures);
%                   fprintf('Estimation %d of the qVal, %f\n', i, var(qvalue - rewardsToCome)/var(rewardsToCome));
%               end
          end
          obj.prevSaFeatures = stateActionFeatures;
          obj.lastQVals = qvalue;
          disp(var(qvalue - rewardsToCome)/var(rewardsToCome)); %%% 1-r2: unexplained variance/normalized mean square error
      end   
            
      function data = preprocessData(obj, data)
          for t = obj.numTimeSteps:-1:1
              obj.currentTimeStep = t;
              obj.callDataFunction('computeQValue', data, :, t);
          end
      end
      
   end
end


%               featureFilter = [ones(1, dimState) (2*ones(1,dimAction));... %for quad part
%                   ones(dimAction, dimState) (ones(dimAction)-eye(dimAction))]; %for lin part
%               featureFilter = obj.saFeatureGenerator.getFeaturesInternal(size(featureFilter, 1), featureFilter);
%               quadPart = featureFilter(1, :) == 4;
%               linPart = featureFilter(2:end, :) == 0 & ~repmat(quadPart, dimAction, 1);
%               
%               % V(s) = E_a(Q(s,a)) = q0 + muAction * q + muAction' Q muAction + tr(Q Sigma)
%               
%               % getting the weights of the qValue at t+1

%               % 
%               constPartQ = [nextStates zeros(size(nextStates, 1), dimAction)];
%               constPartQ = obj.saFeatureGenerator.getFeaturesInternal(size(nextStates, 1), constPartQ);
%               constPartQ = constPartQ * wq;
%               % 
%               linPartQ = muAction * (linPart * wq);
%               %
%               quadPartQ(triu(ones(dimAction))) = wq(quadPart);
%               temp = muAction * quadPartQ * muAction';
%               quadPartQ = temp(:,1) + trace(quadPartQ * (sigma' * sigma)) * ones(size(temp(:,1)));
%               
%               obj.qLearner.learnFunction(stateActionFeatures, rewards + constPartQ + linPartQ + quadPartQ);              

