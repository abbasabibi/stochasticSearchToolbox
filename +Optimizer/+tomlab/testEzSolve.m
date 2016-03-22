% Values from example
load('HiREPSPendulumData.mat');
epsilonAction=0.5;
eta = 0.3371;

% x = theta
toms 300x1 x;

objective = features.meanInit * x +  sum(Optimizer.test.maxAdvantage(x, features, reward)+eta.*(epsilonAction ...
                -log(sum(weighting,2))+log(Optimizer.test.advantage(x, features, reward)))) + obj.repsRegularizationTheta * (x' *x) ;
constraints = {eta >= 1e-12,eta <= 1e12, max(x) <= 1e12};

solution = ezsolve(objective,constraints)

