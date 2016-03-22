%% hypCurb.m
% *Summary:* Wrapper for GP training (via gpr.m), penalizing large SNR and 
% extreme length-scales to avoid numerical instabilities
%
%     function [f df] = hypCurb(lh, covfunc, x, y, curb)
%
% *Input arguments:*
%
%   lh       log-hyper-parameters                                   [D+2 x  E ]
%   covfunc  covariance function, e.g., 
%                               covfunc = {'covSum', {'covSEard', 'covNoise'}};
%   x        training inputs                                        [ n  x  D ]
%   y        training targets                                      [ n  x  E ]
%   curb     (optional) parameters to penalize extreme hyper-parameters
%     .ls    length-scales
%     .snr   signal-to-noise ratio (try to keep it below 500)
%     .std   additional parameter required for length-scale penalty 
%
% *Output arguments:*
%
%   f        penalized negative log-marginal likelihood
%   df       derivative of penalized negative log-marginal likelihood wrt
%            GP log-hyper-parameters
%
%
% Copyright (C) 2008-2013 by
% Marc Deisenroth, Andrew McHutchon, Joe Hall, and Carl Edward Rasmussen.
%
% Last modified: 2011-12-19
%
%% High-Level Steps
% # Compute the negative log-marginal likelihood (plus derivatives)
% # Add penalties and change derivatives accordingly


%
%
%   Copyright (c) 2013 Roberto Calandra
%   $Revision: 0.01 $


function [f df] = R_hypCurb_fix_noise(HYP, inf, mean, cov, lik, x, y)


%% Code
curb.snr = 1000;
curb.ls = 100; 
curb.std = 1;

p = 30;                                                     % penalty power
D = size(x,2);

lh = [HYP.cov; HYP.lik];

%eval(cov{1}) finding number of hyperparameters

% if size(lh,1) == 3*D+2; sfi = 2*D+1:3*D+1; % 1D and DD terms
% elseif size(lh,1) == 2*D+1; sfi = D+1:2*D;   % Just 1D terms
% elseif size(lh,1) == D+2; sfi = D+1;         % Just DD terms
% else error('Incorrect number of hyperparameters'); 
% end


sfi = length(HYP.cov);

% ll = lh(li); 
lsf = lh(sfi); 
lsn = lh(end);

% 1) compute the negative log-marginal likelihood (plus derivatives)
% [f df] = gpr(lh, covfunc, x, y);                              % first, call gpr
[f df] = gp(HYP, inf, mean, cov, lik, x, y);
% [GP.hyp, STATS.nlml{i}] = minimize_20130212c(HYP,@gp,OPT,GP);

% 2) add penalties and change derivatives accordingly
% f = f + sum(((ll - log(curb.std'))./log(curb.ls)).^p);   % length-scales
% df.cov(li) = df.cov(li) + p*(ll - log(curb.std')).^(p-1)/log(curb.ls)^p;

f = f + sum(((lsf - lsn)/log(curb.snr)).^p); % signal to noise ratio
df.cov(sfi) = df.cov(sfi) + p*(lsf - lsn).^(p-1)/log(curb.snr)^p;

%df.lik = df.lik - p*sum((lsf - lsn).^(p-1)/log(curb.snr)^p);


df.lik = 0; 
