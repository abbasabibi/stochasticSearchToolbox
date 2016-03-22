function [ theta ] = extractTheta( images, plotting )
%EXTRACTTHETA Summary of this function goes here
%   Detailed explanation goes here
    [m1,m2,T,N] = size(images);
    
    offset1 = -m1/2 -.5;
    offset2 = -m2/2 -.5;
    
    if not(exist('plotting','var'))% || T > 1
        plotting = false;
    end
    
    theta = zeros(1,T);
    
    coordinates = reshape(cat(3,repmat((1:m1)',1,m2)+offset1,repmat(1:m2,m1,1)+offset2),[],2);
    
    if not(plotting)
        w_images = permute(images.^2,[2,1,3,4]);
        weights = reshape(w_images,[],1,T*N);

        weighted_coordinates = bsxfun(@rdivide,bsxfun(@times,coordinates,weights),sum(weights,1));
        mean = sum(weighted_coordinates,1);
        
        
        theta = atan2(mean(1,1,:),-mean(1,2,:));
        theta = unwrap(reshape(theta,T,N));
    else
        for t = 1:T    
            w_image = (images(:,:,t).^2)';

            weighted_coordinates = bsxfun(@times,coordinates,w_image(:)) ./ sum(w_image(:));

            mean = sum(weighted_coordinates,1);
            centered_coordinates = bsxfun(@minus,coordinates,mean);
            weighted_centered_coordinates = bsxfun(@times,centered_coordinates,w_image(:)) ./ sum(w_image(:));
            covariance = weighted_centered_coordinates' * centered_coordinates;
    %         [eig_vec, eig_val] = eig(covariance);
    %         [~, main_i] = max(diag(eig_val));
    %         main_dir = eig_vec(:,main_i);
    %         if dot(main_dir,mean) < 0
    %             main_dir = -main_dir;
    %         end
            main_dir = mean;

            if plotting
                colormap gray
                imagesc(w_image');
                Plotter.Gaussianplot.plotgauss2d((mean-[offset1 offset2])',covariance,'b');
                line([0 2*main_dir(1)]-offset1,[0 2*main_dir(2)]-offset2);
                pause(.5);
            end

            theta(t) = atan2(main_dir(1),-main_dir(2));
            if t > 1 && abs(theta(t) - theta(t-1)) > pi
                theta(t) = theta(t) + 2*pi;
            end
        end
    end
    
    
%     theta = unwrap(theta);
end

