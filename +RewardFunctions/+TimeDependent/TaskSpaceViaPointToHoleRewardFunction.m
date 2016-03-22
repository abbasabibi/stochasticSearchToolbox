classdef TaskSpaceViaPointToHoleRewardFunction < RewardFunctions.TimeDependent.TaskSpaceViaPointRewardFunction
    %TASKSPACEVIAHOLEREWARDFUNCTION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        wallPos;
        holeDepth;
        collisionPunishment;
        holeRadius;
        
        
    end
    
    properties(SetObservable, AbortSet)
        
        minHoleRadius = 0.05;
        maxHoleRadius = 0.5 ;
        minViaPoint = -1;
        maxViaPoint = 1;
        
    end
    
    
    methods
        
        function obj = TaskSpaceViaPointToHoleRewardFunction (dataManager, planarKinematics, holeReachingTime,holeRadius,holeReachingStates, viaPointFactors, uFactor)
            
            obj = obj@RewardFunctions.TimeDependent.TaskSpaceViaPointRewardFunction(dataManager, planarKinematics, holeReachingTime, holeReachingStates, viaPointFactors, uFactor);
            obj.wallPos = holeReachingStates{1}(1,1);
            obj.holeDepth = 0.5;
            obj.collisionPunishment = -1000;
            obj.holeRadius = holeRadius;
            obj.linkProperty('minHoleRadius');
            obj.linkProperty('maxHoleRadius');
            obj.linkProperty('minViaPoint');
            obj.linkProperty('maxViaPoint');
            obj.registerOptionalParameter('holeRadiusContext', false, 1, obj.minHoleRadius*ones(1,1), obj.maxHoleRadius*ones(1,1), 'contexts');
            obj.registerTimeDependentRewardFunctions();
            obj.registerOptionalParameter('ViaPointContext', false, 1, obj.minViaPoint*ones(1,1), obj.maxViaPoint*ones(1,1), 'contexts');
            
            
        end
        
        
        function [viapointReward] = getViaPointReward(obj, q, timeSteps, varargin)
            
            
            viapointReward = zeros(size(q,1),1);
            collisionFlag  = obj.isCollided(q,varargin{:});
            viapointReward = viapointReward + (obj.collisionPunishment .* collisionFlag) ;
            
            
            for i = 1:length(obj.viaPointTimes)
                indices = timeSteps == obj.viaPointTimes(i);
                if (sum(indices) > 0)
                    rewardTmp = -inf(sum(indices),1);
                    input = obj.getRewardFunctionInput(q,varargin{:});
                    for j = 1:size(obj.viaPoints{i},1)
                        
                        rewardTmp = max(rewardTmp, - (q(indices,:) - obj.getViapoint(i, j, size(q,1),input)).^2*obj.viaPointFactors(i,:)');
                        
                    end
                    viapointReward(indices) = viapointReward(indices) + rewardTmp;
                end
                
            end
        end
        
        
        function input = getRewardFunctionInput (obj,q,varargin)
            
            if(length(varargin) < 2)
                
                if(length(varargin) == 1)
                    
                    if(obj.useholeRadiusContext)
                        
                        input = [ones(size(q,1),1).*obj.holeDepth , zeros(size(q,1),1)];
                        
                    else
                        
                        input = [ones(size(q,1),1).*obj.holeDepth , varargin{1}];
                        
                    end
                    
                else
                    
                    input = [ones(size(q,1),1).*obj.holeDepth , zeros(size(q,1),1)];
                    
                end
            else
                
                input = [ones(size(q,1),1).*obj.holeDepth , varargin{1}];
                
            end
            
            
        end
        
        
        function [center radius] = getTheHole(obj,q,varargin)
            
            
            
            if( isempty(varargin) )
                
                center = repmat(obj.viaPoints{1}(1,2),size(q,1),1);
                radius = repmat(obj.holeRadius,size(q,1),1);
                
            else
                
                if( length(varargin) == 1)
                    
                    if(obj.useholeRadiusContext)
                        
                        center = repmat(obj.viaPoints{1}(1,2),size(q,1),1);
                        radius = varargin{1};
                        
                    else
                        
                        center = obj.viaPoints{1}(1,2) + varargin{1};
                        radius = repmat(obj.holeRadius,size(q,1),1);
                        
                    end
                    
                else
                    
                    center = obj.viaPoints{1}(1,2) + varargin{1};
                    radius = varargin{2};
                                 
                end
                
                
            end
            
            
        end
        
        
        function [collisionFlag] = isCollided(obj,q,varargin)
            
            %danger!! here we assume the position of the wall is always
            %positive
            
            % here we define the boundries of the hole in the wall
            
            [center radius] = obj.getTheHole (q,varargin{:});
            boundry = repmat(center,1,2);
            radius = [-radius,radius];
            boundry = boundry + radius;
            
            
            % here we cheke if the tip has arrived to the wall
            flag1 = bsxfun(@ge,q(:,1),obj.wallPos);
            
            % here we check if the tip could be in the wall or in the hole
            flag2 = bsxfun(@ge,q(:,2),boundry(:,2));
            flag3 = bsxfun(@le,q(:,2),boundry(:,1));
            flag4 = bsxfun(@or,flag2,flag3);
            
            %
            flag5 = bsxfun(@and,flag4,flag1);
            
            %
            flag6 = bsxfun(@ge,q(:,1),obj.wallPos+obj.holeDepth);
            
            %
            collisionFlag = bsxfun(@or,flag5,flag6);
            
        end
        
    end
    
    
    
end




