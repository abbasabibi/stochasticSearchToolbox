function [f, df] = id(N)
    f = N;
    if nargout > 1
        df = ones(size(N, 1),1);
    end
end

