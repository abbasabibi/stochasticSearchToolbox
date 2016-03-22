classdef PolicyEvalMonteCarloPreprocessor < DataPreprocessors.DataPreprocessor & Data.DataManipulator
    
   properties
      policyEvalName;
      rewardToComeName;
      qlearner;
      
      % variables for the recursive estimation
      recursive;
      lastQVals;
      lastRewardsToCome;
%       approximatorSignleCol;
   end
   
   properties (SetObservable, AbortSet)
       numTimeSteps;   
   end
   
   % Class methods
   methods
      function obj = PolicyEvalMonteCarloPreprocessor(trial, recursive, inputVars, qlearnerClass, qFApprox, policyEvalName, layerName)
            obj = obj@DataPreprocessors.DataPreprocessor();
            obj = obj@Data.DataManipulator(trial.dataManager);            
            obj.linkProperty('numTimeSteps');

            if (trial.isProperty('learnerDataName')  && ~isempty(trial.learnerDataName))
                obj.dataNamePreprocessor = trial.learnerDataName;
            end
            
            if (~exist('recursive', 'var') || isempty(recursive))
                recursive = true;
            end            
            obj.recursive = recursive;

            
            if (~exist('inputVars', 'var') || isempty(inputVars))
                inputVars = {'rewardsToCome', 'SquaredStatesActions'};
            end
            
            if(~iscell(inputVars) || length(inputVars) ~= 2)
                error('inputVars should be a cell containing two entries');
            end
            
            if (~exist('qlearnerClass', 'var') || isempty(qlearnerClass))   
                qlearnerClass = @Learner.SupervisedLearner.LinearFeatureFunctionMLLearner;
            end
            
            if (~exist('qFApprox', 'var') || isempty(qFApprox))   
                qFApprox = Functions.FunctionLinearInFeatures(obj.dataManager, {inputVars{1}}, {inputVars{2}}, 'qApproximator');
            end
            
            if (~exist('policyEvalName', 'var'))
                policyEvalName = 'qValue';
            end
                      
            if (~exist('layerName', 'var'))
                layerName = 'steps';
            end
            
            qFApprox.initObject();
            obj.qlearner = qlearnerClass(obj.dataManager, qFApprox);
           
            %%%for test only
%             fApproxSingleCol = Functions.FunctionLinearInFeatures(dataManager, {inputVars{1}}, {inputVars{1}}, 'qApproximatorSingleCol');
%             fApproxSingleCol.initObject();
%             obj.approximatorSignleCol = qlearnerClass(dataManager, fApproxSingleCol);
            
            obj.policyEvalName = policyEvalName;
            obj.dataManager.addDataEntry([layerName, '.', policyEvalName], 1);
            
            obj.addDataManipulationFunction('computeQValue', inputVars, {obj.policyEvalName});            
      end 
      
      function [qvalue] = computeQValue(obj, rewardsToCome, stateActionFeatures)
%           disp(var(rewardsToCome));
%           variableSign = zeros(1, size(stateActionFeatures, 2));
%           for col=1:size(stateActionFeatures, 2)
%             obj.approximatorSignleCol.learnFunction(stateActionFeatures(:, col), rewardsToCome);
%             qvalue = obj.approximatorSignleCol.functionApproximator.getExpectation(size(stateActionFeatures, 1), stateActionFeatures(:, col));
%             variableSign(col) = var(qvalue - rewardsToCome)/var(rewardsToCome);
%           end
%           [variableSign, idx] = sort(variableSign);
%           cut = find(variableSign > .95, 1, 'first');
%           disp([idx(1:cut); variableSign(1:cut)]');
% test
%           unexVar = var(qvalue - rewardsToCome)/var(rewardsToCome);
%           qvalue = unexVar * rewardsToCome + (1-unexVar) * qvalue;
          if(obj.recursive)
              rewards = rewardsToCome - obj.lastRewardsToCome;
              obj.qlearner.learnFunction(stateActionFeatures, rewards + obj.lastQVals);
          else
              obj.qlearner.learnFunction(stateActionFeatures, rewardsToCome);
          end
          
          qvalue = obj.qlearner.functionApproximator.getExpectation(size(stateActionFeatures, 1), stateActionFeatures);
         
          if(obj.recursive)
              obj.lastQVals = qvalue;
              obj.lastRewardsToCome = rewardsToCome;
          end
          disp(var(qvalue - rewardsToCome)/var(rewardsToCome)); %%% 1-r2: unexplained variance/normalized mean square error
%          dbstop in DataPreprocessors.PolicyEvalMonteCarloPreprocessor at 75;
%          pause;
      end   
            
      function data = preprocessData(obj, data)
          if(obj.recursive)
              obj.lastQVals = zeros(size(data, 1), 1);
              obj.lastRewardsToCome = zeros(size(data, 1), 1);
          end
          
          for t = obj.numTimeSteps:-1:1
              obj.callDataFunction('computeQValue', data, :, t);
          end
      end
      
   end
end
