% TEST_GP Compute one-step ahead prediction
%
%
%
%   Copyright (c) 2013 Roberto Calandra
%   $Revision: 0.20b $

% TODO: invert the oreder of GP and TEST_IN in the parameters


function [MEAN,VAR] = test_GP(GP,TEST_IN,PARAMETERS)
%% Input Validation

assert(size(TEST_IN,2)==size(GP.inputs,2),'')


%% Parameters

% Default Parameters

% if ~isfield(GP,'cov') % Legacy, delete in newer versions
%     GP.cov = {'covSum', {'covSEard', 'covNoise'}};
% end
p.toolbox = 'GPML';

% Override default parameters with eventual passed ones
if exist('PARAMETERS','var')
    p = Utils.process_parameters(p,PARAMETERS);
end


%% Regression

switch p.toolbox
    
    case {'GPML-old'}
        for dim = 1:size(GP.targets,2)
            [MEAN(:,dim),VAR(:,dim)] = gpr(GP.hyp(:,dim), GP.cov,...
                GP.inputs, GP.target(:,dim),TEST_IN);
        end
        
    case {'GPML'}
        for dim = 1:size(GP.targets,2)
            [MEAN(:,dim),VAR(:,dim)] = gp(GP.hyp(:,dim), GP.inf,...
                GP.mean, GP.cov, GP.lik, GP.inputs,...
                GP.targets(:,dim), TEST_IN);
        end
        
    otherwise
        error('Unknown toolbox')
        
end


end

