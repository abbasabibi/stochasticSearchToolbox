classdef PlanarKinematicsEndEffVelocityFeature < FeatureGenerators.FeatureGenerator
    
    properties
        planarKinematics
    end
    
    methods
        function obj = PlanarKinematicsEndEffVelocityFeature(dataManager, planarKinematics)
            settings = Common.Settings();
            obj = obj@FeatureGenerators.FeatureGenerator(dataManager, settings.getNameWithSuffix({'jointPositions', 'jointVelocities'}), settings.getNameWithSuffix('~endEffVelocities'), ':', 2);
            
            obj.planarKinematics = planarKinematics;
        end
                
        function [endEffVelocities] = getFeaturesInternal(obj, numElements, jointPositions, jointVelocities)
            endEffVelocities = obj.planarKinematics.getTaskSpaceVelocity(jointPositions, jointVelocities);
        end
    end
end