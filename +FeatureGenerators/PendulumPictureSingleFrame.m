classdef PendulumPictureSingleFrame < FeatureGenerators.FeatureGenerator
    %PENDULUMPICTURESINGLEFRAME Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetObservable,AbortSet)
        bluramount = 0.1;
        pictureSize = 10;
    end
    
    methods
        function obj = PendulumPictureSingleFrame(dataManager, featureVariables, stateIndices, pictureSize)
            obj = obj@FeatureGenerators.FeatureGenerator(dataManager, featureVariables, 'Picture', stateIndices, pictureSize^2);
            obj.linkProperty('bluramount');
            obj.pictureSize = pictureSize;
        end
        
        function features = getPendulumPicture(obj, th)
            width = 100;
            height = 100;
            
            finalwidth = obj.pictureSize;
            finalheight = obj.pictureSize;
            
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
            
            
            
            G = fspecial('gaussian',10,20);
            img = imfilter(img,G,'same');
            
            
            img = imresize(img, [finalwidth, finalheight] ,'bilinear');
   
            imgasvectors = reshape(img, 1,[],size(img,3)); % one long row for each picture
            
            features = permute(imgasvectors , [3,2,1]);
            
        end
        
        function [features] = getFeaturesInternal(obj, numElements, theta)
            th = permute(theta, [3 2 1]) ;
            
            features = obj.getPendulumPicture(th);
        end
    end
    
end

