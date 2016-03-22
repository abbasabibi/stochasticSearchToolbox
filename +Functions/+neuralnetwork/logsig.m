function [f, df] = logsig(N)
    f = 1 ./ (1 + exp(-N));
    if nargout > 1
        df = exp(N) ./ (exp(N)+1).^2;
    end
end

