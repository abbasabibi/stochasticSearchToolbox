classdef PlanarKinematicsEndEffPositionFeature < FeatureGenerators.FeatureGenerator
    
    properties
        planarKinematics
    end
    
    methods
        function obj = PlanarKinematicsEndEffPositionFeature(dataManager, planarKinematics)
            settings = Common.Settings();
           
            obj = obj@FeatureGenerators.FeatureGenerator(dataManager, settings.getNameWithSuffix('jointPositions'), settings.getNameWithSuffix('~endEffPositions'), ':', 2);
            
            obj.planarKinematics = planarKinematics;
        end
                
        function [endEffPosition] = getFeaturesInternal(obj, numElements, jointPositions)
            endEffPosition = obj.planarKinematics.getForwardKinematics(jointPositions);
        end
    end
end