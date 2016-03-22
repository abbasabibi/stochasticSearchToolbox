classdef HiREPSEStepContinuous
  %ESTEP Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
  end
  
  methods
  end
  
end




function [ EMData] = EStep( settings, EMData, traj )


[EMData] = getForwardMessages(settings, EMData, traj); %alpha_t = p(s_1:t,a_1:t,o_t)    dim alpha = numSamples x dimOptions x numSteps
%pSAsa =  %p(s_t,a_t|s_1:t,a_1:t)
EMData = getBackwardMessages(settings, EMData);

EMData.llh = sum(sum(log(EMData.pSAsa)))/settings.numSamples;


for b = 1 : 2
  tmp = squeeze(EMData.alpha(:,:,b,:) );
  if(settings.numSamples == 1)
    EMData.gamma(1,:,b,:) = tmp .* squeeze(EMData.beta(1,:,:));
  else
    EMData.gamma(:,:,b,:) = tmp .* EMData.beta(:,:,:);
  end
end


EMData.xi  = zeros(settings.numSamples, settings.numOptions, settings.numOptions, 2,  settings.numSteps-1); %p(o,o|s_1:T,a_1:T)
for t = 1 : settings.numSteps  -1
  for o = 1 : settings.numOptions    %o_t=o
    for k = 1 : settings.numOptions  %o_t+1=k
      for b = 1 : 2         %b_t = b We directly marginalize out b_t since we don't need it
        for p = 1 : 2       %b_t+1 = p
          EMData.xi(:,o,k,p,t) = EMData.xi(:,o,k,p,t) + 1./EMData.pSAsa(:,t+1) .* EMData.alpha(:,o,b,t) .* EMData.pSAOBo(:,o,k,p,t+1)  .* EMData.beta(:,k,t+1);  % = alpha * pSAo * pOso * beta
        end
      end
    end
  end
end




end



%%
%% FORWARD MESSAGE
function [EMData] = getForwardMessages(settings, EMData, traj)
% global numOptions numSteps numSamples


%n=s
% alpha         = [n,o,b,t]     zeros(settings.numSamples, settings.numOptions, 2, settings.numSteps);
% pSAsa         = [n,t]         ones(settings.numSamples, settings.numSteps);
% pSOBo         = [n,o,o',b]    zeros(settings.numSamples, settings.numOptions, settings.numOptions, 2);
% pAso          = [n,o]         zeros(settings.numSamples, settings.numOptions);
% pSAOBo        = [n,o,o',b,t]  zeros(settings.numSamples, settings.numOptions, settings.numOptions, 2, settings.numSteps);
% pSAOOB        = [n,o,o',b,t]  zeros(settings.numSamples, settings.numOptions, settings.numOptions, 2,  settings.numSteps);
% pSAOB         = [n,o,b]       zeros(settings.numSamples, settings.numOptions, 2);
% pSOB          = [n,o,b]       zeros(settings.numSamples, settings.numOptions, 2);
pBs          = zeros(settings.numSamples, settings.numOptions, settings.numSteps);


for t = 1 : settings.numSteps
  
  %Termination Probability
  for s = 1 : settings.numSamples
      if(t==1)
        pBs(s,:,t) = 1;
      else
        pBs(s,:,t) = sigmoid(EMData.optionTerm * [1, traj.states(s,:,t)]'); %p(b=1|s_t,o_t-1) %TODO
      end
  end
  
  
  %pOs =      [s,o]  
  EMData.pOs = multReg(settings, EMData, traj.states(:,:,t) );  %TODO
  
  %pSOBo =    [s,o_t-1,o_t,b]
  pSOBo(:,:,:,1) = bsxfun(@times, permute(EMData.pOs, [1 3 2]), pBs(:,:,t) );
  for s = 1 : settings.numSamples
  pSOBo(s,:,:,2) = diag(1 - pBs(s,:,t));
  end
  
  for k = 1 : settings.numOptions
    pAso(:,k)   = mvnpdf(traj.actions(:,:,t), ...
      bsxfun(@plus, EMData.actionMean(k,:), (EMData.actionLinear(:,:,k) * traj.states(:,:,t)')'), ...
      EMData.actionVar(:,:,k) );  %TODO
  end
 
  %pSAOBo =   [s,o_t-1,o_t,b,t]
  tmp = bsxfun(@times, permute(pSOBo, [1, 3, 2, 4]), pAso);
  EMData.pSAOBo(:,:,:,:,t) = permute(tmp, [1, 3, 2, 4]);

  if(t==1)
    pSAOOB(:,:,:,:,t) = EMData.pSAOBo(:,:,:,:,t);
  else
    pSOBoBar = sum(EMData.alpha(:,:,:,t-1),3); %sum_b_t-1
    pSAOOB(:,:,:,:,t) = bsxfun(@times, EMData.pSAOBo(:,:,:,:,t), pSOBoBar);
  end
  
  %faster than squeeze
  tmp1 = sum(pSAOOB(:,:,:,:,t),2); %sum o_t-1
  tmp2 = permute(tmp1, [1, 3, 4, 2, 5]);
  %pSAOB =    [s,o,b]
  pSAOB = tmp2(:,:,:,1,1);

  
  EMData.pSAsa(:,t)      = sum(sum(pSAOB,2),3); %c_t
  EMData.alpha(:,:,:,t)  = bsxfun(@rdivide, pSAOB, EMData.pSAsa(:,t) ); %alphaHat
  
end

end %getForwardMessages




%%
%% BACKWARD MESSAGE
function EMData = getBackwardMessages(settings, EMData)
% global numOptions numSteps numSamples

EMData.beta = zeros(settings.numSamples, settings.numOptions, settings.numSteps);

EMData.beta(:,:,settings.numSteps) = 1;
pSAOo = sum(EMData.pSAOBo,4); %sum_b
pSAOo = permute(pSAOo, [1 2 3 5 4]);
pSAOo = pSAOo(:,:,:,:,1); %[s o k t]

for t = settings.numSteps  : -1 : 2
  tmp = bsxfun(@times, pSAOo(:,:,:,t), permute(EMData.beta(:,:,t), [1 3 2]) );
  EMData.beta(:,:,t-1) = sum(tmp,3); %sum_k=o_t

  EMData.beta(:,:,t-1) = bsxfun(@rdivide, EMData.beta(:,:,t-1), EMData.pSAsa(:,t) ); %betaHat
end


end %getBackwardMessages
