% GP_FIXHYP Wrapper to optimize only the Noise 
%
%   Copyright (c) 2013 Roberto Calandra
%   $Revision: 0.01 $


function [nlZ dnlZ] = gp_fixHyp(hyp, inf, mean, cov, lik, x, y)

[nlZ dnlZ] = gp(hyp, inf, mean, cov, lik, x, y);

dnlZ.cov = zeros(size(dnlZ.cov)); 

end

