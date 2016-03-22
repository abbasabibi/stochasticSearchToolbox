classdef LinearTrajectoryTracker < TrajectoryGenerators.TrajectoryTracker.TrajectoryTracker
    
    methods (Static)
        function obj = createFromTrial(trial)
            obj = TrajectoryGenerators.TrajectoryTracker.LinearTrajectoryTracker(trial.dataManager, trial.numJoints);
        end
    end
    
    methods
              
        function obj = LinearTrajectoryTracker(dataManager, numJoints)            
            obj = obj@TrajectoryGenerators.TrajectoryTracker.TrajectoryTracker(dataManager, numJoints);  
            
            obj.registerOptionalParameter('PGains', false, numJoints , zeros(1, numJoints ), 100 * ones(1, numJoints), 'parameters');
            obj.registerOptionalParameter('DGains', false, numJoints , zeros(1, numJoints ), 100 * ones(1, numJoints), 'parameters');
            obj.registerOptionalParameter('PDControllerFFGain', false, numJoints , zeros(1, numJoints ), 100 * ones(1, numJoints), 'parameters');
            
            
            obj.setIfNotEmpty('PGains', 100 * ones(1,obj.numJoints) )
            obj.setIfNotEmpty('DGains', 20 * ones(1,obj.numJoints) )
            obj.setIfNotEmpty('PDControllerFFGain', 1 * ones(1,obj.numJoints) )
            
                        
            obj.registerTrackingFunction();
        end     
        
        function [action] = getTrackingControl(obj, jointPositions, jointVelocities, referenceTrajectory, referenceTrajectoryD, referenceTrajectoryDD, varargin)
            obj.inputParameterDeMux(varargin);
            
            action = bsxfun(@times, (referenceTrajectory - jointPositions), obj.PGains) + bsxfun(@times, (referenceTrajectoryD - jointVelocities), obj.DGains);
            action = action + bsxfun(@times, referenceTrajectoryDD, obj.PDControllerFFGain);
        end
        
        
    end        
                  
end