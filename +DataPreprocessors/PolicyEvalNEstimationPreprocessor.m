classdef PolicyEvalNEstimationPreprocessor < DataPreprocessors.DataPreprocessor & Data.DataManipulator
   %%% N_t(s,a) = E_{s'~ p(.|s,a), a'~ pi_t+1(. | s')} [ Q_t+1 (s', a') ]
   properties      
      qLearner; 
      policy;
      currentTimeStep;
      saFeatureGenerator;   
      rewardGenerator;
   end
   
   properties (SetObservable, AbortSet)
       numTimeSteps; 
       nbSampledActionPerState;
   end
   
   methods
      function obj = PolicyEvalNEstimationPreprocessor(trial, inputVars, qLearnerClass, qFApprox, policyEvalName, layerName)
            obj = obj@DataPreprocessors.DataPreprocessor();
            obj = obj@Data.DataManipulator(trial.dataManager);            
            obj.linkProperty('numTimeSteps');
            obj.linkProperty('nbSampledActionPerState'); 
            
            
            obj.policy = trial.actionPolicy;
            obj.saFeatureGenerator = trial.stateActionFeatures;
            obj.rewardGenerator = trial.rewardFunction;
            
            if (trial.isProperty('learnerDataName')  && ~isempty(trial.learnerDataName))
                obj.dataNamePreprocessor = trial.learnerDataName;
            end
            
            if (~exist('inputVars', 'var') || isempty(inputVars))
                inputVars = {'states', 'rewards', 'SquaredStatesActions', 'nextStates', 'rewardsToCome'};
            end
            
            if(~iscell(inputVars))
                error('inputVars should be a cell');
            end
            
            if (~exist('qLearnerClass', 'var') || isempty(qLearnerClass))   
                qLearnerClass = @Learner.SupervisedLearner.LinearFeatureFunctionMLLearner;
            end
            
            if (~exist('qFApprox', 'var') || isempty(qFApprox))   
                qFApprox = Functions.FunctionLinearInFeatures(obj.dataManager, inputVars(2), inputVars(3), 'qApproximator');
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
      
      function [qvalue] = computeQValue(obj, states, rewards, stateActionFeatures, nextStates, rewardsToCome)
          if(obj.currentTimeStep ~= obj.numTimeSteps)          
              %%% Learning N(s,a)
              %%% getting closed form solution for gaussian policy and
              %%% squaredFeatures. should not be the general case...
              
              % getting the current gaussian policy parameters
              nextActionPolicy = obj.policy.getDistributionForTimeStep(obj.currentTimeStep + 1);
              [muAction, sigma] = nextActionPolicy.getExpectationAndSigma(size(nextStates, 1), nextStates);
              sigma = permute(sigma, [2 3 1]);
              covAction = sigma' * sigma;
              
              % extracting quad in action part of the features
              quadPart = [ones(1, size(nextStates, 2)) (2*ones(1,size(muAction, 2)))]; 
              quadPart = obj.saFeatureGenerator.getFeaturesInternal(size(quadPart, 1), quadPart);
              quadPart = quadPart(1, :) == 4;

              %
              meanFeatures = [nextStates muAction];
              meanFeatures = obj.saFeatureGenerator.getFeaturesInternal(size(meanFeatures, 1), meanFeatures);
              meanFeatures(:, quadPart) = meanFeatures(:, quadPart) + repmat(covAction(tril(ones(size(muAction, 2))) == 1)', size(meanFeatures, 1),1);

              %N(s,a)
              obj.qLearner.learnFunction(stateActionFeatures, obj.qLearner.functionApproximator.getExpectation(size(meanFeatures, 1), meanFeatures));              
          end
          
          %Learn Q(s,a)
          currPolicy = obj.policy.getDistributionForTimeStep(obj.currentTimeStep);
          states = repmat(states, obj.nbSampledActionPerState * size(states, 1), 1);
          actions = currPolicy.sampleFromDistribution(size(states, 1), states);
          virtualSaFeatures = obj.saFeatureGenerator.getFeaturesInternal(size(states, 1), [states actions]);
          virtualRewards = obj.rewardGenerator.rewardFunction(states, actions, obj.currentTimeStep * ones(size(states, 1), 1));
          if(obj.currentTimeStep ~= obj.numTimeSteps)
              obj.qLearner.learnFunction(virtualSaFeatures, virtualRewards + obj.qLearner.functionApproximator.getExpectation(size(virtualSaFeatures, 1), virtualSaFeatures));
          else
              obj.qLearner.learnFunction(virtualSaFeatures, virtualRewards);
          end
          qvalue = obj.qLearner.functionApproximator.getExpectation(size(stateActionFeatures, 1), stateActionFeatures);
          disp(var(qvalue - rewardsToCome) / var(rewardsToCome));
      end   
            
      function data = preprocessData(obj, data)
          for t = obj.numTimeSteps:-1:1
              obj.currentTimeStep = t;
              obj.callDataFunction('computeQValue', data, :, t);
          end
      end
      
   end
end


