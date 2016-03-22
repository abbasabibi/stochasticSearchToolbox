classdef TimeVarLinearController < TrajectoryGenerators.TrajectoryTracker.AbstractTrajectoryTracker & Distributions.DistributionWithMeanAndVariance & Functions.Mapping
    
    properties(AbortSet, SetObservable)
        linearFeedbackNoiseRegularization = 0;
    end
    
    properties
        gainProvider;
    end
    
    methods
        
        function obj = TimeVarLinearController(dataManager, numJoints, gainProvider)
            obj = obj@TrajectoryGenerators.TrajectoryTracker.AbstractTrajectoryTracker(dataManager, numJoints); %
            obj = obj@Distributions.DistributionWithMeanAndVariance();
            obj = obj@Functions.Mapping(dataManager, 'actions', {{'jointPositions', 'jointVelocities','timeSteps'}}, 'trajectoryTracker'); 
            
            
            obj.gainProvider = gainProvider;
            obj.registerTrackingFunction();
            obj.registerMappingInterfaceDistribution();
            obj.restrictToRangeLogLik = true;
            
            obj.linkProperty('linearFeedbackNoiseRegularization');

        end
        
        function [] = registerTrackingFunction(obj)
            obj.addDataManipulationFunction('getTrackingControl', {'jointPositions', 'jointVelocities','timeSteps'}, {'actions'});
            obj.addDataFunctionAlias('sampleAction','getTrackingControl');
            
        end 
        
        
        function [action] = getTrackingControl(obj, jointPos, jointVel, timesteps)
            [ Kp, Kd, kff, actNoise ] = obj.gainProvider.getFeedbackGainsForT(timesteps);
            action = bsxfun(@plus, [ Kp, Kd ] * [ jointPos'; jointVel'], kff )' ...
                   + bsxfun(@times, randn(length(timesteps),obj.numJoints), sqrt(diag(actNoise))');
        end
        
        function [mu, sigma] = getExpectationAndSigma(obj, numElements, input)
            jointPos = input(:, 1:obj.numJoints);
            jointVel = input(:, obj.numJoints + (1:obj.numJoints));
            timesteps = input(:, end);
            [timeStepsUnique, idxA, idxC] = unique(timesteps);
            
            mu = zeros(numElements, obj.dimOutput);
            sigma = zeros(numElements, obj.dimOutput);
            for i = 1:length(timeStepsUnique)
                [ Kp, Kd, kff, actNoise ] = obj.gainProvider.getFeedbackGainsForT(timeStepsUnique(i));
                indexTimeStep = timesteps == timeStepsUnique(i);
                jointPos_local = jointPos(indexTimeStep, :);                
                jointVel_local = jointVel(indexTimeStep, :);
                
                mu(indexTimeStep, :) = bsxfun(@plus, [ Kp, Kd ] * [ jointPos_local, jointVel_local]', kff )';
                sigma(indexTimeStep, :) = repmat(sqrt(diag(actNoise))', sum(indexTimeStep), 1);
            end
            sigma = sigma + obj.linearFeedbackNoiseRegularization;
        end
        
    end
    
    
end