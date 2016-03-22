% linear system
F = [1 .1;.1 1];
Q = [.01 0;0 .01];

H = eye(2);
R = eye(2) * .1;

transitionModel = Distributions.Gaussian.GaussianLinearInFeatures();

observationModel = Distributions.Gaussian.GaussianLinearInFeatures();

transitionModel.setWeightsAndBias(F,0);
transitionModel.setCovariance(Q);

observationModel.setWeightsAndBias(H,0);
observationModel.setCovariance(R);