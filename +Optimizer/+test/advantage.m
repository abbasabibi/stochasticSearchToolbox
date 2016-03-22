%% Compute Advantage
function [advantage, maxAdvantage] = advantage(theta, features, reward, responsibilities, weighting)
% constans taken form exaple

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
% trying mean()
maxAdvantage = max(advantage,[],2);

% negativ convex maxAdvantage makes advantage concav
advantage = advantage - sum(advantage)/300;

% tomlabs reshape does not automatically calculate the columns
% But its not needed in our example
% bndLim = reshape((advantage/eta)',1,[]);
bndLim = (advantage/eta);

xiEta = xi./eta;

xiEtaMat            = repmat(xiEta', numSamplesPerStep, 1);
xiEtaMat            = xiEtaMat(:);

weightedResp        = bsxfun(@power, responsibilities, (1+xiEtaMat) );
%respPow   = weightedResp;

weighting           = bsxfun(@times, weightedResp', weighting);
%wgtExpBndLimPerOption = weighting'*exp(bndLim);

weighting           = sum(weighting);

wgtExpBndLim      = weighting.*exp(bndLim);
sumWgtExpBndLim   = sum(wgtExpBndLim);

advantage = sumWgtExpBndLim;


end

