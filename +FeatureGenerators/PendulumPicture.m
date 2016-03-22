classdef PendulumPicture < FeatureGenerators.FeatureGenerator
    %PENDULUMPICTURE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = PendulumPicture(dataManager, featureVariables, stateIndices)
            fname = 'Picture';
            obj@FeatureGenerators.FeatureGenerator(dataManager, featureVariables, fname, stateIndices, 1200)
        end
        function [features] = getFeaturesInternal(obj, numElements, states)
            width = 100;
            height = 100;

            finalwidth = 20;
            finalheight = 20;

            nsamples = size(states,1);
            img = zeros(width+1,height+1, nsamples);


            th = permute(states(:,1), [3 2 1]) ;
            thd = permute(states(:,2), [3 2 1]);

            pendulumlength = 40;
            stickwidth = 4;

            xcenter =  ((sin(th) ) * pendulumlength);
            ycenter = - ((cos(th) ) * pendulumlength);




            [x,y] = meshgrid(-(width/2):(width/2), -(height/2):(height/2));



            circleradius = 12;
            img(bsxfun(@minus, x, xcenter).^2 + bsxfun(@minus, y,ycenter).^2 < circleradius^2  ) = 1;

            topend = [sin(th) , -cos(th) ];
            orth   = [cos(th), sin(th)];
            c1 = bsxfun(@times, x, topend(:,1,:)) + bsxfun(@times, y, topend(:,2,:)) > 0 ;
            c2 = abs(bsxfun(@times, x , orth(:,1,:)) + bsxfun(@times, y, orth(:,2,:))) < stickwidth;
            c3 = bsxfun(@times, x, topend(:,1,:)) + bsxfun(@times, y, topend(:,2,:)) < pendulumlength;
            img(c1 & c2 & c3) = 1;

            scaling = 1/500;
            img_flow_x = img.* bsxfun(@times, thd, -y ) * scaling;
            img_flow_y = img.* bsxfun(@times, thd, x ) * scaling;    

            %maxabsflow = max(max(max(abs(img_flow_x), abs(img_flow_y))));


            %img = img + randn(size(img))*1;
            %img_flow_x =img_flow_x  + randn(size(img))*0.5;
            %img_flow_y = img_flow_y + randn(size(img))*0.5;

            img = imresize(img, [finalwidth, finalheight] ,'bilinear');

            img_flow_x  = imresize(img_flow_x , [finalwidth, finalheight] ,'bilinear');
            img_flow_y  = imresize(img_flow_y , [finalwidth, finalheight] ,'bilinear');
            
            imgasvectors = reshape(img, 1,[],size(img,3)); % one long row for each picture
            flowxasvectors = reshape(img_flow_x, 1,[],size(img,3)); 
            flowyasvectors = reshape(img_flow_y, 1,[],size(img,3)); 
            features = permute([imgasvectors, flowxasvectors, flowyasvectors] , [3,2,1]);
        end
    end
    
end

