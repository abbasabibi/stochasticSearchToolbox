function [f, df] = tansig(N)
    % This is mathematically equivalent to tanh(N).
    % It differs in that it runs faster than the MATLAB implementation of tanh,
    % but the results can have very small numerical differences.
    % This function is a good trade off for neural networks,
    % where speed is important and the exact shape of the transfer
    % function is not.
    f = 2 ./ (1 + exp(-2*N)) - 1;
    if nargout > 1
        df = 4*exp(2*N)./(exp(2*N)+1).^2;
    end
end

