% GP_FIX_NOISE Wrapper to optimize Hyperparameters except the Noise 
%
%   Copyright (c) 2013 Roberto Calandra
%   $Revision: 0.01 $


function [nlZ dnlZ] = gp_fix_noise(hyp, inf, mean, cov, lik, x, y)

[nlZ dnlZ] = gp(hyp, inf, mean, cov, lik, x, y);

dnlZ.lik = 0; 

end

