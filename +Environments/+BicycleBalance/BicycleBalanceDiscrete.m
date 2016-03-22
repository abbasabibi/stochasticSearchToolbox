classdef BicycleBalanceDiscrete < FeatureGenerators.FeatureGenerator
    
    properties
        statelist
    end
    
    methods
        
        function obj =  BicycleBalanceDiscrete(dataManager, featureVariables, stateIndices)
            if (~exist('stateIndices', 'var'))
                stateIndices = ':';
            end
            obj = obj@FeatureGenerators.FeatureGenerator(dataManager, featureVariables, 'BicycleBalance', stateIndices, 1715);
            obj.statelist = obj.buildStateList();
        end
        
        function [features] = getFeaturesInternal(obj, numElements, inputMatrix)
            features = zeros(numElements,1715);
            for i=1:numElements
                x = inputMatrix(i,:);
                x = repmat(x, size(obj.statelist,1), 1);
                [~, s] = min(sqrt(sum((obj.statelist-x).^2,2)));    %the closest state with the
                %current state
                %v = value
                %s = index
                features(i,s) = 1;     %retain percieved state
            end
        end
        
        function [ statelist ] = buildStateList(obj)
            
            w = [-1/15*pi  -.15 -0.06 0 0.06 0.15 1/15*pi];
            w_dot = [-2 -0.5 -.25 0 0.25 0.5 2 ];
            theta = [-pi/2 -1 -0.2 0 0.2 1 pi/2];
            theta_dot = [-4 -2 0 2 4];
            
            I = size(w,2);
            J = size(w_dot,2);
            L = size(theta,2);
            M = size(theta_dot,2);
            
            statelist = [];
            index=1;
            
            %this could be done in a simpler, easier and time efficient way. Since it
            %is not being called many times, the follwoing way is better for
            %understanding
            
            for i=1:I
                for j=1:J
                    for l=1:L
                        for m=1:M
                            statelist(index,1) = w(i);
                            statelist(index,2) = w_dot(j);
                            statelist(index,3) = theta(l);
                            statelist(index,4) = theta_dot(m);
                            index = index + 1;
                        end
                    end
                end
            end
        end
    end
end

