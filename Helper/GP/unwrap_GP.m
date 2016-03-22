% UNWRAP_GP Unwrap the GP hyperparameters into a row vector
%
%   Copyright (c) 2011 Roberto Calandra
%   $Revision: 0.09 $


function [THETA N_HYP]= unwrap_GP(GP_HYP)

N_HYP(1) = numel(GP_HYP.cov);
N_HYP(2) = numel(GP_HYP.lik);
N_HYP(3) = numel(GP_HYP.mean);

THETA = [GP_HYP.cov(:); GP_HYP.lik(:); GP_HYP.mean(:)]';

end

