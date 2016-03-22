% Values from example
load('HiREPSPendulumData.mat');

% See Tomlab_snopt 3.6.2 for more information

g = @(x) Optimizer.tomlab.getGradient(x,f);

h = @(x) Optimizer.tomlab.getHessian(x,f);

Prob = conAssign(f, g, h, [], [], ones(300,1)*1e12, 'findTheta', zeros(300,1));

Prob.PriLevOpt = 5;
% Feasibility tolerance
Prob.SOL.optPar(10)= 0.000001;

%[curTheta, thetaVal, thetaNumIterations] = obj.thetaOptimizer.optimize(f, params0 );

%[paramsOpt, etaVal, etaNumIterations] = obj.etaXiOptimizer.optimize(f, params0 );
tic;
Result = tomRun('snopt',Prob);
toc;
% warm start running
%for t=2:10
%   Prob = WarmDefSOL('snopt', Prob, Result(t-1));
%   Result(t) = tomRun('snopt',Prob);
%end
% x = -2.190043723969816281 after 10k iterations


% Tomlab output without log (1 run)
%  SNOPTB EXIT  30 -- resource limit error                                                                                                                                                             
%     SNOPTB INFO  32 -- major iteration limit reached                                                                                                                                                    
%     Problem name                 findThet                                                                                                                                                               
%     No. of iterations                1300   Objective value     -2.1900437240E+00                                                                                                                       
%     No. of major iterations          1000   Linear objective     0.0000000000E+00                                                                                                                       
%     Penalty parameter           0.000E+00   Nonlinear objective -2.1900437240E+00                                                                                                                       
%     No. of calls to funobj           1110   No. of calls to funcon              0                                                                                                                       
%     No. of superbasics                300   No. of basic nonlinears             0                                                                                                                       
%     No. of degenerate steps             0   Percentage                       0.00                                                                                                                       
%     Max x                     249 5.8E+00   Max pi                      1 0.0E+00                                                                                                                       
%     Max Primal infeas           0 0.0E+00   Max Dual infeas           125 5.0E-04                                                                                                                       
%                                                                                                                                                                                                         
%     Time for MPS input                             0.00 seconds                                                                                                                                         
%     Time for solving problem                      22.93 seconds                                                                                                                                         
%     Time for solution output                       0.00 seconds                                                                                                                                         
%     Time for constraint functions                  0.00 seconds                                                                                                                                         
%     Time for objective function                   20.18 seconds                                                                                                                                         
% 
% 
% -->-->-->-->-->-->-->-->-->-->
% SNOPT solving Problem 1:
% -->-->-->-->-->-->-->-->-->-->
% 
% SNOPT: Inform = 32, 
% Major iteration limit reached
% 
% Objective function at solution x                -2.190043723969816281
% 
% Major       iterations   1000. Total minor iterations   1300. 
% fObj and gObj evaluations   1111 1110 0 0
% nInf (# of infeasible constraints)       0. nS (# of superbasics)     300. sInf (Sum of infeasibilities outside bounds)  0.0000000e+00
% Optimal x = 
% x:    -2.262180e-02  -8.659169e-04   5.584268e-02   7.019674e-02  -1.574465e+00  -1.082069e-01
%        4.266447e-01  -1.723528e-01   5.484941e+00   9.530491e-02  -3.191575e-02  -3.422266e-02
%       -8.907677e-01  -9.760734e-02   6.992506e-03   6.223028e-02   2.018844e-01   4.714029e-01
%        1.379088e-01   5.589081e-01
% State vector hs for x and constraints = 
% hs:  2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2
% Dual variables (Lagrangian multipliers) v_k (pi) = 
% pi:   0.000000e+00
% Reduced costs rc: Last 1 elements should be v_k
% rc:    -0.000119846   -0.000290153   -0.000270924   -0.000181080   -0.000287381
%        -0.000222119   -0.000124646   -0.000199228    0.000134003   -0.000205857
%         0.000075826    0.000181198    0.000051181   -0.000025042    0.000085061
%        -0.000165948    0.000297348   -0.000108507   -0.000125691   -0.000063784
%        -0.000037598    0.000311199    0.000288314   -0.000106160   -0.000228752
%        -0.000072654    0.000096647    0.000158616   -0.000118035   -0.000191660
%        -0.000139392    0.000240511    0.000112606   -0.000114371   -0.000216616
%         0.000051109    0.000469009   -0.000279710   -0.000142446   -0.000091600



                                                                                                                  


