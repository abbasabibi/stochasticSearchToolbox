classdef RLByWeightedML < Learner.RLLearner & Data.DataManipulator
    
    properties
        outputWeightName;
        rewardName
        
        additionalInputData = {};
        policyLearner;
    end
    
    % Class methods
    methods
        function obj = RLByWeightedML(dataManager, policyLearner, rewardName, outputWeight, level)
            obj = obj@Learner.RLLearner();
            obj = obj@Data.DataManipulator(dataManager);
            
            obj.policyLearner = policyLearner;
            
            if (~exist('rewardName', 'var'))
                rewardName = 'returns';
            end
            
            if (exist('outputWeight', 'var'))
                obj.outputWeightName = outputWeight;
            else
                obj.outputWeightName = [rewardName, 'Weighting'];
            end
            obj.rewardName = rewardName;
            
            if (~isempty(obj.policyLearner))
                obj.policyLearner.setWeightName(obj.outputWeightName);
            end
            
            if (~obj.dataManager.isDataEntry(obj.outputWeightName))
                if (~exist('level', 'var'))
                    depth       = dataManager.getDataEntryDepth(obj.rewardName);
%                     subManager  = dataManager.getDataManagerForDepth(depth);
%                     level       = subManager.dataName;
                    obj.dataManager.addDataEntryForDepth(depth, obj.outputWeightName, 1);
%                     level = '';
                else
                    level = [level, '.'];
                    obj.dataManager.addDataEntry([level, obj.outputWeightName], 1);
                end
%                 obj.dataManager.addDataEntry([level, obj.outputWeightName], 1);
            end
            obj.registerWeightingFunction();
        end
        
        
        function [] = updateModel(obj, data)
            obj.callDataFunction('computeWeighting', data);
            
            if (~isempty(obj.policyLearner))
                obj.policyLearner.updateModel(data);
            end
        end
        
        function [] = setWeightName(obj, outputWeightName)
            obj.outputWeightName = outputWeightName;
            obj.registerWeightingFunction();
        end
        
        function [] = setRewardName(obj, rewardName)
            obj.rewardName = rewardName;
            obj.registerWeightingFunction();
        end
        
        function [] = setAdditionalInputs(obj, varargin)
            obj.additionalInputData = varargin;
            obj.registerWeightingFunction();
        end
        
        function [] = addAdditionalInputs(obj, input)
            obj.additionalInputData{end + 1} = input;
            obj.registerWeightingFunction();
        end
        
        %%
        function [divKL] = getKLDivergence(obj, qWeighting, pWeighting)
            
            p = pWeighting;
            p = p / sum(p);
            
            q = qWeighting;
            q = q / sum(q);
            
            index = p > 10^-10;
            divKL = sum(p(index)  .* log(p(index) ./ q(index)));
            
        end
    end
    
    methods(Abstract)
        [weights] = computeWeighting(obj, varargin);
    end
    
    methods (Access = protected)
        function [] = registerWeightingFunction(obj)
            obj.addDataManipulationFunction('computeWeighting', {obj.rewardName, obj.additionalInputData{:}}, {obj.outputWeightName});
        end
        
    end
end
