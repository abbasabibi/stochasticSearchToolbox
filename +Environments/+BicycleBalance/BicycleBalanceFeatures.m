classdef BicycleBalanceFeatures < FeatureGenerators.FeatureGenerator
    %As described in Least-Squares Policy Iteration, Michail G. Lagoudakis, Ronald Parr
    methods 

        function obj =  BicycleBalanceFeatures(dataManager, featureVariables, stateIndices)
            if (~exist('stateIndices', 'var'))
                stateIndices = ':';
            end
            obj = obj@FeatureGenerators.FeatureGenerator(dataManager, featureVariables, 'BicycleBalance', stateIndices, 14);
        end
        
        function [features] = getFeaturesInternal(obj, numElements, inputMatrix)
            omega   = inputMatrix(:,1);
            domega  = inputMatrix(:,2);
            theta   = inputMatrix(:,3);
            dtheta  = inputMatrix(:,4);
            
            fallen = abs(omega(:,1)) >= pi/15;
            features = ones(numElements,1);
            
            features = [features, theta, dtheta, theta.^2, dtheta.^2 theta.*dtheta, omega, domega, omega.^2, domega.^2, omega.*domega, omega.*theta, (omega.^2).*theta, omega.*(theta.^2)];
            %features = [bsxfun(@times, features, ~fallen), fallen];
        end
    end    
end

