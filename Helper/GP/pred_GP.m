% PRED_GP Given a GP compute mean/var, theirs gradients and hessians
%   [MU,VAR,G_MU,G_VAR,H_MU,H_VAR] = pred_GP(X,GP) Given a model GP and a
%   set of position X, the function compute the mean MU, the variance VAR,
%   the gradient of the mean G_MU, the gradient of the variance G_VAR, the
%   hessian of the mean H_MU and the hessian of the variance H_VAR.
%
%   To compute the Standard deviation and its gradients/hessian use:
%       Utils.var2std()
%
%
%   Copyright (c) 2013 Roberto Calandra
%   $Revision: 0.17 $

% TODO: ADD MEAN
% TODO: Implement more cov functions
% TODO: hess_mu
% TODO: hess_var


function [MU,VAR,G_MU,G_VAR,H_MU,H_VAR] = pred_GP(X,GP)
%% Input Validation

[N,D]   = size(GP.inputs);                                          % [NxD]
%assert(isrow(X),'Wrong dimension of X')                         % X = [1xD]
assert(size(X,2)==size(GP.inputs,2),'Wrong dimension of X')

order   = floor((nargout-1)/2); % Order
assert(any(order==[0 1 2]),'Invalid Order')

assert(isequal(GP.mean,{@meanZero}),'MEAN support not implemented')
assert(isequal(GP.cov,{'covSEard'}),'only SEARD implemented')


%% Initialize

% Test comparison with GPML
DEBUG = false;                             	% Test mu/var against GPML
precision = 1e-8;                           % Test numerical precision


ktt     = feval(GP.cov{:}, GP.hyp.cov, X, 'diag');                  % [1x1]
kxt    	= feval(GP.cov{:}, GP.hyp.cov, GP.inputs, X);               % [Nx1]
ktx     = kxt';                                                     % [1xN]
%ktx    	= feval(GP.cov{:}, GP.hyp.cov, X, GP.inputs);
ms      = feval(GP.mean{:}, GP.hyp.mean, X);                        % [1x1]
K   	= feval(GP.cov{:}, GP.hyp.cov, GP.inputs);                  % [NxN]
y       = GP.targets;                                             	% [Nx1]
noise   = exp(2*GP.hyp.lik);

K       = K + noise*eye(N);
ktt     = ktt + noise;
%invK    = inv(K+noise*eye(N));
%invKy   = invK*(y);                                             	% [Nx1]
post    = GP.inf(GP.hyp, GP.mean, GP.cov, GP.lik, GP.inputs, GP.targets);

invKy	= post.alpha;
L       = post.L;
sW      = post.sW;


%% Mean/Variance

MU  	= ms + ktx * invKy;                                         % [1x1]
%VAR 	= ktt - ktx / (K+noise*eye(N)) * kxt;                       % [1x1]
%VAR     = VAR + noise;

if all(all(tril(L,-1)==0))
    V  = L'\(repmat(sW,1,1).*kxt);
    fs2 = ktt - sum(V.*V,1)';                       % predictive variances
else                % L is not triangular => use alternative parametrisation
    fs2 = ktt + sum(kxt.*(L*kxt),1)';                 % predictive variances
end

VAR = max(fs2,eps);


if DEBUG
    % Test Mean/Variance
    [f_mu, f_var] = test_GP(GP,X);   % GPML
    assert(Utils.isalmostequal(MU,f_mu,precision),'ERROR Mean')
    assert(Utils.isalmostequal(VAR,f_var,precision),'ERROR Var')
end


%% Gradient

assert(size(GP.cov,2)==1,'Composite Cov')
if order > 0
    switch GP.cov{1}
        
        case {'covSEard'}
            
            invP = inv(Utils.diag2mat(exp(GP.hyp.cov(1:D)).^2)); 	% [DxD]
            
            grad_ktx = -bsxfun(@times,ktx',bsxfun(@minus,X,GP.inputs)*invP'); % [NxD]
            grad_kxt = grad_ktx';                                           % [DxN]
            %grad_kxt = -bsxfun(@times,kxt',invP*bsxfun(@minus,X,GP.inputs)'); % [DxN]
            grad_ktt = zeros([1,D]);                                % [1xD]
            assert(Utils.isalmostequal(grad_ktx,grad_kxt'),'grad_ktx!=grad_kxt')
            
        otherwise
            error('Unknown covariance')
            
    end
    
    % Gradient
    G_MU  	= invKy' * grad_ktx;                      % [1xN]*[NxD] = [1xD]
    %G_VAR	= grad_ktt - 2*(ktx*invK*grad_ktx);
    G_VAR	= grad_ktt - 2*(ktx/K*grad_ktx);
    %G_VAR	= grad_ktt - (ktx*invK*grad_kxt') - (grad_ktx'*invK*kxt)' ;
    % [1xD]-([1xN]*[NxN]*[NxD])-([1xN]*[NxN]*[NxD]) = [1xD]
    
end


%% Hessian

assert(size(GP.cov,2)==1,'Composite Cov')
if order > 1
    switch GP.cov{1}
        
        case {'covSEard'}
            
            hess_ktx = zeros([N,D,D]);                            % [NxDxD]
            hess_kxt = zeros([D,D,N]);                            % [DxDxN]
            hess_ktt = zeros([D,D]);                                % [DxD]
            
        otherwise
            error('Unknown covariance')
            
    end
    
    % Hessian
    v_h_mu  = reshape(permute(hess_ktx,[3,2,1]),D*D,N)*invKy;     % [D*Dx1]
    H_MU    = reshape(v_h_mu,D,D);                              	% [DxD]
    
    warning('hessian is wrong')
    v_h_var_1 = zeros([D,D]);
    v_h_var_2 = zeros([D,D]);
    H_VAR   = hess_ktt - v_h_var_1 - v_h_var_2;                     % [DxD]
    
end


%% Output validation

assert(all(size(MU)==[1 1]),'Wrong')
assert(all(size(VAR)==[1 1]),'Wrong')
assert(isfinite(MU))
assert(isfinite(VAR))
assert(isreal(MU))
assert(isreal(VAR))
assert(VAR>=0,'Var must be positive')
if order > 0
    assert(all(size(G_MU)==[1 D]),'Wrong')
    assert(all(size(G_VAR)==[1 D]),'Wrong')
    assert(all(isfinite(G_MU)))
    assert(all(isfinite(G_VAR)))
    if order >1
        assert(all(size(H_MU)==[D D]),'Wrong')
        assert(all(size(H_VAR)==[D D]),'Wrong')
        assert(all(all(isfinite(H_MU))))
        assert(all(all(isfinite(H_VAR))))
    end
end


end

