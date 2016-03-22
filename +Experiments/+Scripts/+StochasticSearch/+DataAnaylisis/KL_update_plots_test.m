clear variables;
close all;

rng(10);

trial.dataManager = Data.DataManager('episodes');
trial.dataManager.addDataEntry('contexts', 0);
trial.dataManager.addDataEntry('parameters', 2, [0 ;-1.5],[1.5;0]);
trial.dataManager.addDataEntry('returns', 1);
trial.dataManager.finalizeDataManager();


 %Functions.SquaredFunction(dataManager, 'returns', 'parameters', 'rewardModel');
trial.learnedRewardFunction = Functions.SquaredFunction(trial.dataManager,  'returns', 'parameters', 'rewardModel');
trial.learnedRewardFunction.initObject();
trial.rewardFunctionLearner = Learner.ModelLearner.ConvexQuadraticModelLearner(trial.dataManager,trial.learnedRewardFunction);
trial.rewardFunctionLearner.initObject();
trial.contextFeatures = FeatureGenerators.SquaredFeatures(trial.dataManager, 'contexts');
trial.contextFeatures.initObject();
trial.parameterPolicy = Distributions.Gaussian.GaussianParameterPolicy(trial.dataManager)
trial.parameterPolicy.initSigma=0.1;
trial.parameterPolicy.initMu = randn(1,2) * 0.05 + [2 -1];
trial.parameterPolicy.initObject();
trial.parameterPolicyLearner = Learner.SupervisedLearner.LinearGaussianMLLearner(trial.dataManager, trial.parameterPolicy)
trial.parameterPolicyLearner.initObject();
trial.learnedContextDistribution = Distributions.Gaussian.GaussianContextDistribution(trial.dataManager);
trial.learnedContextDistribution.initObject();
trial.contextDistributionLearner = Learner.SupervisedLearner.LinearGaussianMLLearner(trial.dataManager,trial.learnedContextDistribution);
trial.contextDistributionLearner.initObject();
trial.learner = Learner.EpisodicRL.CMAES2.CreateFromTrial(trial)
trial.learner.initObject();


[X, Y] = meshgrid(linspace(-2,3, 500), linspace(-3,2, 500));

%McCormick function (slightly changed);
mcCormick = @(x_, y_) (sin(x_ + y_) + (x_ - y_).^2 - 1.5 * x_ + 2.5 * y_ + 5).^0.1;

mu(:,1) = trial.parameterPolicy.bias;
Sigma(:,:,1) = trial.parameterPolicy.getCovariance;


Z = reshape(mcCormick(X(:), Y(:)), size(X));

colorFirst = [255 204 153 ] / 255;
colorSecond = [255 128 0 ] / 255 * 0.8;

N = 5;
%lambda = 3;

epsilon = 1; 
[~, index] = min(Z(:));

newData = trial.dataManager.getDataObject(N);
newData.setDataEntry('contexts', randn(N,0));



for i = 1:120
    
    figure;
    colormap('Winter');
    contour(X, Y, Z, 10, 'LineWidth', 1);
    hold on;
    h = Gaussianplot.plotgauss2d(mu(:,i), Sigma(:,:,i), colorFirst, 2);
    
    samples =mvnrnd(mu(:, i)', Sigma(:,:,i),N);
    %samples = [samples ; mvnrnd(mu(:, i)', Sigma(:,:,i),N-1)];
    plot(samples(1:min(10,N),1), samples(1:min(10,N),2), 'o', 'MarkerFaceColor', colorFirst, 'MarkerSize', 10, 'LineWidth', 2, 'MarkerEdgeColor', [0 0 0])
    plot(X(index), Y(index), 'xb', 'MarkerSize', 15, 'LineWidth', 3);
    reward = -mcCormick(samples(:,1), samples(:,2));
    
    newData.setDataEntry('returns', reward);
    newData.setDataEntry('parameters', samples);
   % featureGenerator.callDataFunction('generateFeatures',newData);
    
    %dualFunction = @(eta_) (eta_ * epsilon + eta_ * log(1 / length(reward) * sum(exp( (reward - max(reward)) / eta_))) + max(reward));
    %etaOpt = logspace(-8,1, 1000);
    %for k = 1:1000 
     %   dualF(k) = dualFunction(etaOpt(k)); 
    %end
    %[~, idx] = min(dualF);    
    %eta = etaOpt(idx);
    
    %weights = exp((reward - max(reward)) / eta);
    %weights = weights / sum(weights);
    trial.learner.updateModel(newData);
    
    mu(:,i+1) = trial.parameterPolicy.bias;
    %muDev = bsxfun(@minus, samples, mu(:,i+1)');
    %muDevWeighted = bsxfun(@times, muDev, weights);
    
    Sigma(:,:,i+1) = trial.parameterPolicy.getCovariance;
    
    %lambda = linspace(0, 1, 100);
    %logLik = zeros(length(lambda),1);
    %for k = 1:length(lambda)
        
       % for j = 1:size(samples,1)
        %    samplesXVal = samples([1:j-1, j+1:end], :);
        %    weightsXVal = weights([1:j-1, j+1:end]);
        %    weightsXVal = weightsXVal / sum(weightsXVal);
        %    muXVal = sum(bsxfun(@times, samplesXVal, weightsXVal), 1);
        %    muDev = bsxfun(@minus, samplesXVal, muXVal);
        %    muDevWeighted = bsxfun(@times, muDev, weightsXVal);
    
        %    SigmaXVal = (1 - lambda(k)) *  muDevWeighted' * muDev + lambda(k) * Sigma(:,:,i);
            
        %    logLik(k) = logLik(k) + weights(j) * (-0.5 * log(det(SigmaXVal)) - 0.5 * (samples(j,:) - muXVal) * (SigmaXVal \ (samples(j,:) - muXVal)'));
            
        %end
    %end
    %[minVal, minIndex] = max(logLik);
    %lambdaVal = lambda(minIndex);
    %fprintf('Lambda %f\n', lambdaVal);
    %Sigma(:,:,i+1) = Sigma(:,:,i+1) * (1 - lambdaVal) + lambdaVal * Sigma(:,:,i);
    
    h=Gaussianplot.plotgauss2d(mu(:,i+1), Sigma(:,:,i+1), colorSecond, 2);
    set(gca, 'FontSize', 18);
    xlabel('\theta_1', 'FontSize', 18);
    ylabel('\theta_2', 'FontSize', 18);
    set(gca, 'XTick', []);
    set(gca, 'YTick', []);
    title(sprintf('Iteration %d', i));
    
    %plot2svg(sprintf('pics/KL_bound%f_iter%d.svg', epsilon, i))
  
        
    pause
   
end