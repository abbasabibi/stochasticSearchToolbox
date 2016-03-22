function [ c ] = mergeVectors( a,b,i )
%MergeVectors (a,b,i)
% return a(i) = b
% for use in anonymous functions etc

    a(i)=b;
    c = a;

end

