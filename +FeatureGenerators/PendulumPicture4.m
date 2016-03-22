classdef PendulumPicture4 < FeatureGenerators.FeatureGenerator
    %PENDULUMPICTURE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetObservable,AbortSet)
        bluramount = 0.2;
    end
    
    methods
        function obj = PendulumPicture4(dataManager, featureVariables, stateIndices)
            fname = 'Picture';
            obj@FeatureGenerators.FeatureGenerator(dataManager, featureVariables, fname, stateIndices, 800)
            obj.linkProperty('bluramount');
        end
        
        function features = getPendulumPicture(obj, th)
            width = 100;
            height = 100;
            
            finalwidth = 20;
            finalheight = 20;
            
            nsamples = size(th,3);
            img = zeros(width+1,height+1, nsamples);
            
            
            
            pendulumlength = 50;
            
            stickwidth = 6;
            pendulumneglength = stickwidth;
            
            xcenter =  ((sin(th) ) * pendulumlength);
            ycenter = - ((cos(th) ) * pendulumlength);
            
            
            
            
            [x,y] = meshgrid(-(width/2):(width/2), -(height/2):(height/2));
            
            
            
            %circleradius = 14;
            %img(bsxfun(@minus, x, xcenter).^2 + bsxfun(@minus, y,ycenter).^2 < circleradius^2  ) = 1;
            
            topend = [sin(th) , -cos(th) ];
            orth   = [cos(th), sin(th)];
            c1 = bsxfun(@times, x, topend(:,1,:)) + bsxfun(@times, y, topend(:,2,:)) > -pendulumneglength ;
            c2 = abs(bsxfun(@times, x , orth(:,1,:)) + bsxfun(@times, y, orth(:,2,:))) < stickwidth;
            c3 = bsxfun(@times, x, topend(:,1,:)) + bsxfun(@times, y, topend(:,2,:)) < pendulumlength;
            img(c1 & c2 & c3) = 1;
            
            
            
            
            %maxabsflow = max(max(max(abs(img_flow_x), abs(img_flow_y))));
            
            
            %img = img + randn(size(img))*1;
            %img_flow_x =img_flow_x  + randn(size(img))*0.5;
            %img_flow_y = img_flow_y + randn(size(img))*0.5;
            
            
            
            G = fspecial('gaussian',[width height],mean([width, height])*obj.bluramount);
            img = imfilter(img,G,'same');
            
            
            img = imresize(img, [finalwidth, finalheight] ,'bilinear');
   
            imgasvectors = reshape(img, 1,[],size(img,3)); % one long row for each picture
            
            features = permute(imgasvectors , [3,2,1]);
            
        end
        
        function [features] = getFeaturesInternal(obj, numElements, states)
            th = permute(states(:,1), [3 2 1]) ;
            thd = permute(states(:,2), [3 2 1]);
            
            features_current = obj.getPendulumPicture(th);
            
            timestep = 0.05;
            th_prev = th - timestep * thd;
            features_prev = obj.getPendulumPicture(th_prev);
            
            features = [features_current, features_current - features_prev];
            
        end
    end
    
end

