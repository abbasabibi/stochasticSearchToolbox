classdef REPS_infhorizon < Learner.WeightedML.REPS_base
    %REPS_INFHORIZON Reps for infinite horizon problems
    
    properties
    end
    
    methods
        function obj = REPS_infhorizon(dataManager, policyLearner, rewardName, weightName,stateFeatureName, expectedStateFeatureName, varargin)  

            obj@Learner.WeightedML.REPS_base(dataManager, policyLearner, rewardName, weightName, stateFeatureName, expectedStateFeatureName, 'steps')  ;
            % TODO: REPSBASE constructor bug - doesn't work if I pass {} as varargin!

            obj.numDecisionSteps = 0;
        end
        
        function [optTheta, optEta, val, numIterations] = optimizeInternal(obj, repsdata, optimizationOptions)
            features.phi = repsdata.stateFeatures;
            features.psi = repsdata.expectedFeatures; 
            features.meanInit = zeros(1, size(features.phi,1));
            features.numPerTimeStep = size(features.phi,2) ;
            
            weighting = repsdata.weighting;
            reward = repsdata.reward;
            
            [params0, lb,ub] = obj.getParametersForOptimization();

            f2 = @(params) obj.dualFunctionComplete(params(1:end-1), params(end), features, weighting, reward);
            
            %TODO - use optimization option from argument...
            
            options = optimset('GradObj','on', 'Algorithm','trust-region-reflective','Hessian','on'); 

            [params, val, ~, output] = fmincon(f2, params0, [], [], [], [], lb, ub,[],options );
            
            
            optTheta = reshape(params(1:end-1), size(obj.theta));
            optEta = params(end);
            numIterations = output.iterations;
            
            %sampleWeighting = weightingFunction(obj,features, weighting, reward, optTheta, optEta);
            %kl = getKLDivergence(obj, weighting,sampleWeighting);
            %fprintf('\tKL final:  %f\n', kl);
            
        end
        
        function repsdata = getREPSDataStructure(obj, rewards, stateFeatures, expectedFeatures, weighting)
            %TODO - make sure input args are registered! 
            %See:obj.addDataManipulationFunction('computeWeighting', {obj.rewardName, obj.additionalInputData{:}}, {obj.outputWeightName});        
            repsdata.stateFeatures    = stateFeatures';
            repsdata.expectedFeatures = expectedFeatures'; 
            repsdata.meanInit         = zeros(size(stateFeatures,1),1);
            repsdata.numPerTimeStep   = obj.numFeatures;
            repsdata.reward           = rewards';
            if(exist('weighting','var'))
                repsdata.weighting        = weighting;
            else
                n = size(repsdata.reward,1);
                repsdata.weighting  =  ones(n,1)/n;
            end
        end
        
        function printDivKL(divKL)
            fprintf('divKL: %f\n', divKL);
        end
        
        function[params] = getOptimizationOptions(obj)
            params = [];
        end
        
    end
    
end

