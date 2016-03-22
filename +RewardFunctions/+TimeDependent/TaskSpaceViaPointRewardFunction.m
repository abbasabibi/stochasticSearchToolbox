classdef TaskSpaceViaPointRewardFunction < RewardFunctions.TimeDependent.ViaPointRewardFunction & Data.OptionalParameterInterface
    
    properties(SetObservable, AbortSet)
    end
    
    properties
        planarKinematics
        posFeatures;
        velFeatures;
    end
    
    methods
        function obj = TaskSpaceViaPointRewardFunction(dataManager, planarKinematics, viaPointTimes, viaPoints, viaPointFactors, uFactor)
            posFeatures = Environments.Misc.PlanarKinematicsEndEffPositionFeature(dataManager, planarKinematics);
            velFeatures = Environments.Misc.PlanarKinematicsEndEffVelocityFeature(dataManager, planarKinematics);
            
            
            obj = obj@RewardFunctions.TimeDependent.ViaPointRewardFunction(dataManager, viaPointTimes, viaPoints, viaPointFactors, uFactor, {'endEffPositions', 'endEffVelocities'});
            obj = obj@Data.OptionalParameterInterface();
            obj.planarKinematics = planarKinematics;
            
            obj.posFeatures = posFeatures;
            obj.velFeatures = velFeatures;
            
            level = dataManager.getDataManagerDepth('steps') - 1;
            
            obj.registerOptionalParameter('ViaPointContext', false, 2, 0*ones(1,2), 1.5*ones(1,2), 'contexts', level);

            obj.registerTimeDependentRewardFunctions();
            
        end
   
        
        function [viaPoint] = getViapoint(obj, i, j, numSamples, varargin)
            viaPoint = obj.getViapoint@RewardFunctions.TimeDependent.ViaPointRewardFunction(i, j, numSamples, varargin{:});
            if (~isempty(varargin) > 0)
                viaPoint(:,1:2) = viaPoint(:, 1:2) + varargin{1};
            end            
        end
        
        function [vargout] = sampleFinalRewardInternal(obj, finalStates, timeSteps, varargin)
            jointPositions = finalStates(:, 1:2:end);
            jointVelocities = finalStates(:, 2:2:end);
            
            endEffPosition = obj.planarKinematics.getForwardKinematics(jointPositions);
            endEffVelocity = obj.planarKinematics.getTaskSpaceVelocity(jointPositions, jointVelocities);
            vargout = 0;
            %vargout = obj.getViaPointReward([endEffPosition, endEffVelocity], timeSteps + 1, varargin{:});
        end
        
        %return reward and quadratic approximation
        % ct = - u'H u - 2 u h - q' R q - 2 q r
        function [ct H, h, R, r] = getQuadraticCosts(obj, q, u, k)
            %TODO
        end
    end
end
