function [ r ] = BallOnBeam( ballInit, gains )

addpath ~/svn/robolab/robolab/studentBarrett/matlab/

r = zeros(size(gains,1),1);
for i = 1 : size(gains,1)
  r(i) = SLSendController([ballInit(i,:), gains(i,:)]);
end



end

