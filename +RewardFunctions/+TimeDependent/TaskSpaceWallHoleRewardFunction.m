classdef TaskSpaceWallHoleRewardFunction < RewardFunctions.TimeDependent.TaskSpaceViaPointRewardFunction
    %TASKSPACEVIAHOLEREWARDFUNCTION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        wallPos;
        holeDepth;
        collisionPunishment;
        hasWall;
        hasGround;
        
    end
    
    properties(SetObservable, AbortSet)
        
        minHoleRadius = 0.15;
        maxHoleRadius = 0.15 ;
        minViaPoint = -0.5;
        maxViaPoint = 0.5;
        minHoleDepth = 0.0;
        maxHoleDepth = 2;
        holeRadius;               
        
    end
    
    
    methods
        
        function obj = TaskSpaceWallHoleRewardFunction (dataManager, planarKinematics, holeReachingTime,holeRadius,holeReachingStates, viaPointFactors, uFactor)
            
            obj = obj@RewardFunctions.TimeDependent.TaskSpaceViaPointRewardFunction(dataManager, planarKinematics, holeReachingTime, holeReachingStates, viaPointFactors, uFactor);
            obj.wallPos = holeReachingStates{1}(1,1);
            obj.holeDepth = 1;
            obj.collisionPunishment = -100000;
            obj.holeRadius = holeRadius;
            obj.linkProperty('minHoleRadius');
            obj.linkProperty('maxHoleRadius');
            obj.linkProperty('minViaPoint');
            obj.linkProperty('maxViaPoint');
            obj.linkProperty('minHoleDepth');
            obj.linkProperty('maxHoleDepth');
            obj.linkProperty('holeRadius');

            level = dataManager.getDataManagerDepth('steps') - 1;

            obj.registerOptionalParameter('HolePointContext', false, 1, obj.minViaPoint*ones(1,1), obj.maxViaPoint*ones(1,1), 'contexts',level);

            obj.registerOptionalParameter('HoleRadiusContext', false, 1, obj.minHoleRadius*ones(1,1), obj.maxHoleRadius*ones(1,1), 'contexts',level);
            
            obj.registerOptionalParameter('HoleDepthContext', false, 1, obj.minHoleDepth*ones(1,1), obj.maxHoleDepth*ones(1,1), 'contexts',level);
             
            obj.registerTimeDependentRewardFunctions();


            obj.hasWall = false;
            obj.hasGround = true;
            
        end
        
        
        function [] = registerTimeDependentRewardFunctions(obj)
            obj.setRewardInputs({'endEffPositions', 'endEffVelocities','jointPositions'},'actions', 'timeSteps', obj.additionalParameters{:})
            obj.addDataManipulationFunction('sampleFinalReward', {obj.nextStateFeatures, 'timeSteps', obj.additionalParameters{:}}, {'finalRewards'}, false);
        end
        
        %         function [reward, stateReward, actionReward] = rewardFunction(obj,q,theta, u, timeSteps, varargin)
        %             stateReward =  obj.getViaPointReward(q,theta,timeSteps, varargin{:});
        %             actionReward = - sum(bsxfun(@times, u.^2, obj.uFactor),2);
        %             reward = actionReward + stateReward;
        %         end
        
           function [vargout] = sampleFinalRewardInternal(obj, finalStates, timeSteps, varargin)
            jointPositions = finalStates(:, 1:2:end);
            jointVelocities = finalStates(:, 2:2:end);
            
            endEffPosition = obj.planarKinematics.getForwardKinematics(jointPositions);
            endEffVelocity = obj.planarKinematics.getTaskSpaceVelocity(jointPositions, jointVelocities);
            vargout = 0;
            %vargout = obj.getViaPointReward([endEffPosition, endEffVelocity,jointPositions], timeSteps + 1, varargin{:});
        end
        
        function [viapointReward] = getViaPointReward(obj,input, timeSteps, varargin)
            
            q = input(:,1:4);
            theta = input(:,5:end);
            viapointReward = zeros(size(q,1),1);
            collisionFlag  = obj.isCollided2(input,varargin{:});
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
            
            [center radius depth] = obj.getTheHole(q,varargin{:});
            
            if(obj.hasGround)
                
                context = min(max((q(:,1)-center),-radius),radius);
                
            else
                
                context = min(max((q(:,2)-center),-radius),radius);
                
            end
            
            if(length(varargin) < 2)
                
                if(length(varargin) == 1)
                    
                    if(obj.useHoleRadiusContext)
                        
                        input = [depth , zeros(size(q,1),1)+context];
                        
                    else
                        
                        input = [depth , varargin{1}+context];
                        
                    end
                    
                else
                    
                    input = [depth , zeros(size(q,1),1)+context];
                    
                end
            else
                
                input = [depth , varargin{1}+context];
                
            end
            
            if(obj.hasGround)
                input = fliplr([input(:,1).*-1,input(:,2)]);
            end
            
            
        end
        
        
        
        function [center radius depth] = getTheHole(obj,q,varargin)
            
            
            if(obj.hasGround)
                
                center = obj.viaPoints{1}(1,1);
            else
                center = obj.viaPoints{1}(1,2);
            end
            
            if( isempty(varargin) )
                
                center = repmat(center,size(q,1),1);
                radius = repmat(obj.holeRadius,size(q,1),1);
                depth = repmat(obj.holeDepth,size(q,1),1);
                
            elseif( length(varargin) == 1)
                    
                    if(obj.useHoleRadiusContext)
                        
                        center = repmat(center,size(q,1),1);
                        radius = varargin{1};
                        depth = repmat(obj.holeDepth,size(q,1),1);
                        
                    elseif (obj.useHoleDepthContext)
                         
                        center = repmat(center,size(q,1),1);
                        radius = repmat(obj.holeRadius,size(q,1),1);
                        depth = varargin{1};

                    else
                        
                        center = center + varargin{1};
                        radius = repmat(obj.holeRadius,size(q,1),1);
                        depth = repmat(obj.holeDepth,size(q,1),1);
                    end
                    
                elseif ( length(varargin) == 2)
                
                    if(obj.useHoleRadiusContext && obj.useHoleDepthContext )
                        
                        center = repmat(center,size(q,1),1);
                        radius = varargin{1};
                        depth = varargin{2};
                        
                    elseif(obj.useHoleRadiusContext && obj.useHolePointContext )
                        
                        center = center + varargin{1};
                        radius = varargin{2};
                        depth = repmat(obj.holeDepth,size(q,1),1);
                        
                    else
                        
                        center = center + varargin{1};
                        radius = repmat(obj.holeRadius,size(q,1),1);
                        depth = varargin{2};
                    
                    end
                else    
                    center = center + varargin{1};
                    radius = varargin{2};
                    depth = varargin{3};
                    
                end
                     
            
        end
        
        
        function [center radius holeDepth] = oneContext(obj,q,varargin)
            
        end
        
        function [center radius holeDepth] = twoContext(obj,q,varargin)
            
        end
        
        function [center radius holeDepth] = getTheHole2(obj,q,varargin)
            
            
            if(obj.hasGround)
                
                center = obj.viaPoints{1}(1,1);
            else
                center = obj.viaPoints{1}(1,2);
            end
            
     
            if( isempty(varargin) )
                
                center = repmat(center,size(q,1),1);
                radius = repmat(obj.holeRadius,size(q,1),1);
                holeDepth = obj.holeDepth; 
                
            else
                
                if( length(varargin) == 1)
                    
                    if(obj.useHoleRadiusContext)
                        
                        center = repmat(center,size(q,1),1);
                        radius = varargin{1};
                        holeDepth = obj.holeDepth;
                        
                        elseif(obj.useViaPointContext)
                            
                        center = center + varargin{1};
                        radius = repmat(obj.holeRadius,size(q,1),1);
                        holeDepth = obj.holeDepth;
                        
                    else
                        
                        center = repmat(center,size(q,1),1);
                        radius = repmat(obj.holeRadius,size(q,1),1);
                        holeDepth = varargin{1};
                       
                        
                    end
                    
                elseif( length(varargin) == 2)
                    
                    center = center + varargin{1};
                    radius = varargin{2};
                    
                end
                
                
            end
            
            
            
        end
        
        
        
        function [collisionFlag] = isCollided(obj,input,varargin)
            
            %danger!! here we assume the position of the wall is always
            %positive
            
            % here we define the boundries of the hole in the wall
            q = input(:,1:4);
            theta = input(:,5:end);
            
            [center radius ] = obj.getTheHole (q,varargin{:});
            boundry = repmat(center,1,2);
            radius = [-radius,radius];
            boundry = boundry + radius;
            
            
            % here we cheke if the tip has arrived to the wall
            if(obj.hasWall)
                
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
                
            else
                
                flag1 = bsxfun(@le,q(:,2),0);
                
                % here we check if the tip could be in the wall or in the hole
                flag2 = bsxfun(@ge,q(:,1),boundry(:,2));
                flag3 = bsxfun(@le,q(:,1),boundry(:,1));
                flag4 = bsxfun(@or,flag2,flag3);
                
                %
                flag5 = bsxfun(@and,flag4,flag1);
                
                %
                flag6 = bsxfun(@le,q(:,2),-obj.holeDepth);
                
            end
            
            collisionFlag = bsxfun(@or,flag5,flag6);
            
        end
        
        
        function [collisionFlag] = isCollided2(obj,input,varargin)
            
            %danger!! here we assume the position of the wall is always
            %positive
            
            % here we define the boundries of the hole in the wall
            nrSamples = size(input,1);
            collisionFlag = false(nrSamples,1);
            
            q = input(:,1:4);
            theta = input(:,5:end);
            
            
            [center radius depth] = obj.getTheHole (q,varargin{:});
            boundry = repmat(center,1,2);
            radius = [-radius,radius];
            boundry = boundry + radius;
            
            groundConf = obj.getGroundConf ( boundry , depth );
            armConf = obj.getArmConf (theta) ;
            
            for i=1:nrSamples
                collisionFlag(i) = obj.armColides(armConf(i,:),groundConf(i,:));
            end
            
        end
        
        % Geometry Functions
        function zi = PolylineIntersectSegment(obj,seg,pline)
            %  function zi = PolylineIntersectSegment(seg,pline)
            %  Intersections of two dimension line segment with a polyline.
            %  A polyline is a set of connected line segments. The segments
            %  are not necessarily closed i.e the end point is not equal the start
            %  although they can be. The points of the segment and the polyline
            %  are represented as complex numbers with coordinates x + iy.
            %  see the discussion at http://aprendtech.com/wordpress/?p=140
            %
            %  The code fully accomodates vertical lines; it does NOT use y = ax + b
            %  to represent the lines.
            %  inputs:
            %     seg: a length two complex array of the endpoints of the line segment
            %     pline: a 1D complex array of the start and end points of the polyline. The segments
            %        are connected so the end point of one is the start point of the next
            %  outputs:
            %     zi: the intersection points of the segment with the polyline. Empty if no intersect.
            %
            %  example:
            %  zseg = [1, 1+1i];
            %  psquare = [0 1, 1+1i, 1i, 0];
            %  poff = 1.5*(pline - (0.5+0.5*1i)); % offset square
            %  zi = PolylineIntersectSegment(zseg,poff);
            %  plot(poff,'-b')
            %  hold on,plot(zseg,'-r'),hold off
            %  hold on,plot(zi,'ok'),hold off
            %
            %  REA: 2004-Jul-8 -> 2011-Aug-30 10:41
            
            assert(numel(seg)==2);
            assert(numel(pline)>=2);
            % will use column vectors
            seg = seg(:);
            pline = pline(:);
            nlines = numel(pline) - 1;
            
            % see discussion of formulas in my blog post: http://aprendtech.com/wordpress/?p=140
            % convert to notation corresponding to my equations to describe the line segments:
            % single line segment is P1 + s*d1 and each polyline seg is P2 + t*d2
            % for intersect points in the segments 0<=s<=1 and  0<=t<=1
            P1 = seg(1)*ones(nlines,1);
            d1  = (seg(2) - seg(1) )*ones(nlines,1);
            P2 = pline(1:end-1);
            d2 = diff(pline);
            
            % rotate the diff vectors to form perpendicular vectors
            ns_1 = 1i*d1;
            ns_2 = 1i*d2;
            
            % the difference vectors of the initial points
            Ds = P2 - P1;
            
            % the offsets to the intersections
            s = obj.zdot(Ds,ns_2)./obj.zdot(d1,ns_2);
            t = -obj.zdot(Ds,ns_1)./obj.zdot(d2,ns_1);
            
            intersectsOK = (s>=0)&(s<1)&(t>=0)&(t<1);
            
            % find points of intersect, if any
            if any(intersectsOK)
                zi = seg(1) + s(intersectsOK)*d1(1); % all d1s are the same so use the first one
            else
                zi = [];
            end
            
        end
        
        
        % ---- LOCAL FUNCTIONS ------
        
        function d = zdot(obj,z1,z2) % dot product for complex vectors
            d = real( z1(:) .* conj(z2(:)));
        end
        
        function complexNr = getComplex(obj,a)
            
            
            
            complexNr = complex(a(:,1),a(:,2));
            
            
        end
        
        function groundConf = getGroundConf(obj,boundry , holeDepth)
            
            point2 = obj.getComplex([boundry(:,1) -0.01*ones(size(boundry,1),1)]);
            point1 = point2-10;
            point3 = point2-holeDepth.*1i;
            point5 = obj.getComplex([boundry(:,2) -0.01*ones(size(boundry,1),1)]);
            point4 = point5-holeDepth.*1i;
            point6 = point5+10;
            groundConf = [point1 point2 point3 point4 point5 point6];
            
        end
        
           function groundConf = getGroundConf2(obj,boundry)
            
            point2 = obj.getComplex([boundry(:,1) -0.01*ones(size(boundry,1),1)]);
            point1 = point2-10;
            point3 = point2-obj.holeDepth*1i;
            point5 = obj.getComplex([boundry(:,2) -0.01*ones(size(boundry,1),1)]);
            point4 = point5-obj.holeDepth*1i;
            point6 = point5+10;
            groundConf = [point1 point2 point3 point4 point5 point6];
            
        end
        
        function armConf = getArmConf(obj,theta)
            numJoints = obj.planarKinematics.numJoints;
            armConf = zeros(size(theta,1),numJoints+1);
            for i=0:numJoints
                armConf(:,i+1) = obj.getComplex(obj.planarKinematics.getForwardKinematics(theta,i));
            end
            
        end
        
        function flag = armColides(obj,armConf,groundConf)
            
            numLinks = obj.planarKinematics.numJoints;
            flag = false;
            
            for i = 1:numLinks
                
                link = [armConf(i) armConf(i+1)];
                zi = obj.PolylineIntersectSegment(link,groundConf);
                
                if(~isempty(zi))
                    
                    flag = true;
                    break;
                    
                end
                
            end
            
            
        end
        
    end
    
    
end




