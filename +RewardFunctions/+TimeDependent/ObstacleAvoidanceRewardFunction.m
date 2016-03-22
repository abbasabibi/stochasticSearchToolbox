classdef ObstacleAvoidanceRewardFunction < RewardFunctions.TimeDependent.TimeDependentRewardFunction & RewardFunctions.RewardFunctionSeperateStateActionInterface
    
    properties(SetObservable, AbortSet)

        obstacleFactor = 10^4;
        obstacleSize = 1.5;
        
        uFactor
        
        planarKinematics
        numTimeSteps
    end
    
    
    methods
        function obj = ObstacleAvoidanceRewardFunction(sampler, planarKinematics)
            obj = obj@RewardFunctions.TimeDependent.TimeDependentRewardFunction(sampler);
            obj = obj@RewardFunctions.RewardFunctionSeperateStateActionInterface();    
            
            obj.planarKinematics = planarKinematics;            
            
            obj.linkProperty('obstacleFactor');                       
            obj.linkProperty('obstacleSize'); 
            obj.linkProperty('uFactor');
            
            obj.linkProperty('numTimeSteps');
        end        
                
        
        function [reward, stateReward, actionReward] = rewardFunction(obj, q, u, nextStates, timeSteps)
            stateReward =  obj.getObstacleReward(q, timeSteps);
            actionReward = - sum(bsxfun(@times, u.^2, obj.uFactor),2);
            reward = actionReward + stateReward;            
        end
        
        function [vargout] = sampleFinalRewardInternal(obj, finalStates, timeSteps)
            vargout = obj.getObstacleReward(finalStates, timeSteps + 1);
        end
        
        function [obstacleReward] = getObstacleReward(obj, q, timeSteps)
            obstacleReward = zeros(size(q,1),1);
            lengthRobot = sum(obj.planarKinematics.lengths);
            
            numJoints = obj.planarKinematics.dimState / 2;
            minRangeStates = [0, -pi * ones(1, numJoints-1)];
            maxRangeStates = [2 * pi, pi * ones(1, numJoints-1)];
            
            rewardStateLimits = zeros(size(q,1),numJoints);
            Pos = q(:, 1:2:end);
         
            posDiffMin = bsxfun(@minus, Pos, minRangeStates);
            posDiffMax = bsxfun(@minus, Pos, maxRangeStates);
            
            indicesMin = posDiffMin < 0;   
            indicesMax = posDiffMax > 0;   
                        
            rewardStateLimits(indicesMin) = rewardStateLimits(indicesMin) - 10^3 * posDiffMin(indicesMin).^2;
            rewardStateLimits(indicesMax) = rewardStateLimits(indicesMax) - 10^3 * posDiffMax(indicesMax).^2;
                                    
            phase = timeSteps / obj.numTimeSteps;
            obstaclePosX = lengthRobot - phase * 2 * lengthRobot;
            obstaclePos = [obstaclePosX, ones(length(timeSteps), 1) * (-lengthRobot + obj.obstacleSize / 2)];
            for i = 1:(obj.planarKinematics.dimState / 2)
                endEffectorPos = obj.planarKinematics.getForwardKinematics(q(:, 1:2:end), i);
                distance = sqrt(sum(bsxfun(@minus, obstaclePos, endEffectorPos).^2, 2));
                index = distance < (obj.obstacleSize / 2);
                               
                obstacleReward(index) = obstacleReward(index) - obj.obstacleFactor * (1 + distance(index));               
            end
            
            obstacleReward = obstacleReward + sum(rewardStateLimits, 2);
        end           
    end
end
