classdef ReflexRollingRewards < RewardFunctions.RewardFunction
    
    properties
           dimStates
           dimActions
    end
    
    methods
        function obj = ReflexRollingRewards(dataManager)
           obj = obj@RewardFunctions.RewardFunction(dataManager);
           obj.setRewardInputs({'states'},{'actions'});
           

           
        end
              
        function [rewards] = rewardFunction(obj, states, actions, varargin)  
            % action punishment
            rewards1 = -sum(actions.*actions,2); % -0.005 -> 0
            
            des_pressure =0.7;%sufficient pressure to calc location reward
            
            % satisfying pressure reward
            rewards2 = -(states(:,1) - des_pressure).^2; 
            rewards2 = rewards2 - (states(:,2) - des_pressure).^2; % 0 -> -0.5
            
            % pressure location reward
%             statesreg = max(1e-6,states(:,1:4));
%             normalizer = sum(statesreg,2);
%             normleft = bsxfun(@rdivide, statesreg, normalizer);
%             rewards3l = normleft * [0;1;2;3]; 
%             rewards3l(normalizer < suf_pressure) = 0;
%             
%             statesreg = max(1e-6,states(:,5:8));
%             normalizer = sum(statesreg,2);
%             normright = bsxfun(@rdivide, statesreg, normalizer);
%             rewards3r = normright * [3;2;1;0]; 
%             rewards3r(normalizer < suf_pressure) = 0;
%             rewards3 = rewards3l + rewards3r;
            
            % joint location reward
            %joint_desired1 = 1.8;
            %joint_desired2 = 0.8;
            %joint_desired1 = 0.8;
            %joint_desired2 = 1.8;
            %joint_desired1 = 2.3;
            %joint_desired2 = 1.3;
            

            joint_desired1 = 1.8;
            joint_desired2 = 1;
            
            %rewards3 = -abs(states(:,3)-joint_desired1).^2; 
            %rewards3 = rewards3 -(states(:,4)-joint_desired2).^2; % 0 -> -2
            % 0-> 8 with new definitionof states 3,4
            
            rewards3 = -abs(states(:,3)-joint_desired1); 
            rewards3 = rewards3 -abs(states(:,4)-joint_desired2); % 0 -> -1
            % 0-> 3
            
            %distal_desired = 0;
            %rewards4 = -abs(states(:,5)-distal_desired);
            %rewards4 = rewards4 - abs(states(:,6) - distal_desired); %0-> -2
            % with new definition: 0-> 4
            
            % joint approx 0 - 2
            
            % desired: actions 0 -> -10, pressure 0->-30, location 0->-50?
            % distal 0->-20
            
            %rewards = rewards3 * 25 + 60* rewards2 + 2000 * rewards1 + rewards4 * 10;

            % desired: actions 0 -> -10, pressure 0->-40, location 0->-32?
            % distal 0->-20
            % rewards = rewards3 * 4 + 80* rewards2 + 2000 * rewards1 + rewards4 * 10;
            
            % desired: actions 0 -> -10, pressure 0->-50, location 0->-24?
            % distal 0->-16
            %rewards = rewards3 * 6 + 100* rewards2 + 2000 * rewards1 + rewards4 * 4;
            
            % desired: actions 0 -> -10, pressure 0->-40, location 0->-75?
            rewards = rewards3 * 30 + 80* rewards2 + 2000 * rewards1;
        end       
              
    end
    
end
