% Rosenbrock function
toms x;
toms y;

rosenbrock = (1-x)^2 + 100*(y-x^2)^2;
const = {};

%ezsolve(rosenbrock,const);

sym2prob(rosenbrock);

tomRun('ucSolve',Prob);

% ERRORS

% >>Optimizer.tomlab.testUcSolve
% Problem type appears to be: con
% Time for symbolic processing: 0.31489 seconds
% Starting numeric solver
% Invalid MEX-file '/home/potato/tomlab/mex/snopt.mexa64': libg2c.so.0: cannot open shared object file: No such file or directory
% 
% Error in snoptTL (line 559)
% [hs, xs, pi, rc, Inform, nS, nInf, sInf, Obj, iwCount, gObj, fCon, gCon] = ...
% 
% Error in tomRun (line 481)
%        Result = snoptTL(Prob);
% 
% Error in ezsolve (line 216)
%     result = tomRun(options.solver,Prob,PriLev);
% 
% 
% Error in Optimizer.tomlab.testUcSolve (line 8)
% ezsolve(rosenbrock,const);
