classdef LocallyWeightedPolicyLearner < Learner.SupervisedLearner.SupervisedLearner
    %LOCALLYWEIGHTEDPOLICYLEARNER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        policy
    end
    
    methods
        function obj =  LocallyWeightedPolicyLearner(dataManager, policy, weightName, varIn, varOut)
            obj = obj@Learner.SupervisedLearner.SupervisedLearner(dataManager, [], weightName, varIn, varOut);
            obj.policy = policy;
        end
        
        function [] = learnFunction(obj, inputData, outputData, weighting)
                                    
            if (~exist('weighting', 'var'))
                weighting = ones(size(inputData,1),1);
            end
            %numSamples   = size(inputData,1); 
            %--> optimize bandwidth!
            obj.policy.trainingInput = inputData(1:2:end,:);
            obj.policy.trainingOutput = outputData(1:2:end,:);
            obj.policy.weighting = weighting(1:2:end);
            valInput = inputData(2:2:end,:);
            valOutput = outputData(2:2:end,:);
            valWeighting = weighting(2:2:end);           
            
            initparams = obj.policy.kernel.getHyperParameters();
            
%             optimizer = Optimizer.CMAOptimizer(2,[-1000,-1000],[1000,1000]);
% 
%             optimizer.setPrintIterations(true);
%             optimizer.maxNumOptiIterations = 400;
%             optimizer.CMAOptimizerInitialRange = 1.0;
%             tic
%             [paramsCMA, valCMA, numIterationsCMA] = optimizer.optimize(@(bandwidth)-obj.policy.likelihood(valInput, valOutput, valWeighting,exp(bandwidth)), log(initbandwidth));
%             toc
%             tic
             objfun = @(logparams)-obj.policy.likelihood( ...
                 valInput, valOutput, valWeighting,exp(logparams));
             [paramsopt] = fminunc( objfun, log(initparams)); 

            obj.policy.kernel.setHyperParameters(exp(paramsopt));
            
            %now set real dataset
            obj.policy.trainingInput = inputData;
            obj.policy.trainingOutput = outputData;
            obj.policy.weighting = weighting;
            

            
        end        
        
    end
    
end

