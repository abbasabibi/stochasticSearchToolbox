classdef ConstantTrajectoryTracker < TrajectoryGenerators.TrajectoryTracker.AbstractTrajectoryTracker
        
    properties       
       referenceTrajectory
    end
    
    methods
              
        function obj = ConstantTrajectoryTracker (dataManager, numJoints, referenceTrajectory) 
            obj = obj@TrajectoryGenerators.TrajectoryTracker.AbstractTrajectoryTracker(dataManager, numJoints); 
            
            if (~exist('referenceTrajectory', 'var'))
                obj.referenceTrajectory = {'referencePos', 'referenceVel', 'referenceAcc'};
            else
                obj.referenceTrajectory = {[referenceTrajectory, 'Pos'], [referenceTrajectory, 'Vel'], [referenceTrajectory, 'Acc']};
            end
            obj.registerTrackingFunction();
        end     
              
        
        function [] = registerTrackingFunction(obj)
            obj.addDataManipulationFunction('getTrackingControl', {'parameters'}, {'actions'});
            obj.addDataFunctionAlias('sampleAction','getTrackingControl');
        end 
        
        
        function actions = getTrackingControl(obj, parameters)
            actions = parameters;
        end
                                                              
    end        
    
                  
end