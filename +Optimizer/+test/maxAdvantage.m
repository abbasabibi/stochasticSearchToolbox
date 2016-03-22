function [ maxAdvantage ] = maxAdvantage(theta, features, reward, responsibilities, weighting)
eta = 0.3371;
xi = 0.0528;
numSamplesPerStep = 349;


numSampledTimeSteps = 1; % obj.numDecisionSteps+1;
numSamples = size(reward,2)/numSampledTimeSteps;

numFeatures = 1;

if(numFeatures > 0)
    i = repmat(1:numSampledTimeSteps,features.numPerTimeStep, 1);
    j = 1:features.numPerTimeStep * numSampledTimeSteps;
    
    val = sparse(i(:),j(:), theta)*features.phi;
    nextVal = sparse(i,j,theta)*features.psi;
    
    adv = reward + nextVal - val;
    
    %advantage = NaN(numSampledTimeSteps,numSamples);
    %ij = reshape(1:numSampledTimeSteps*numSamples,numSampledTimeSteps,numSamples)';
    % advantage(ij) = sum(adv,1);
    advantage = sum(adv,1);
else
    advantage = reward;
end

%maxAdvantage = max(advantage,[],2);

maxAdvantage = max(advantage,[],2);

end

