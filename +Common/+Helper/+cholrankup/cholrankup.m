function x=cholrankup(R,U,V,B)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Solve the system Ax=B, where is given in terms of its Cholesky
% factors plus a nonsymmetric rank r matrix
%
% A=R'*R+U*V'
%
% The matrix R is upper triangular n by n. The matrices, U and V, are 
% n by r.
%
% U=[u1,u2,...,ur];
% V=[v1,v2,...,vr];
%
% The vector b is the n by m right hand side.
%
% Written by: Greg von Winckel - 08/13/05
% Contact: gregvw(at)chtm(at)unm(at)edu
%
% Adapted by: Herke van Hoof - 03/18/15
% works now for n by m b matrices
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[n,r]=size(V); I=eye(r);
temp=(R\(R'\[U B]));
W=temp(:,1:r); 
c=temp(:,(r+1):(r+size(B,2)));
M=V'*temp; 
a=(M(1:r,1:r)+I)\M(:,(r+1):(r+size(B,2)));
x=c-W*a;