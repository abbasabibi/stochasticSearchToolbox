#include "mex.h"
#include <math.h>


void mexFunction(int nlhs, mxArray *plhs[], 
                 int nrhs, const mxArray *prhs[])
{
    // Input
    double
    *startPosition      = mxGetPr(prhs[0]),
    *startVelocity      = mxGetPr(prhs[1]),
    *goalPosition       = mxGetPr(prhs[2]), 
	*goalVelocity       = mxGetPr(prhs[3]),
    alpha_x             = mxGetScalar(prhs[4]),
	beta_x              = mxGetScalar(prhs[5]),
	*forcingFunction    = mxGetPr(prhs[6]),           
	*amplitude          = mxGetPr(prhs[7]),
    tau                 = mxGetScalar(prhs[8]),
	dt                  = mxGetScalar(prhs[9]);
	int numTrajectorySteps  = (int) mxGetScalar(prhs[10]),
    numForcedSteps      = mxGetN(prhs[6]),
	numJoints           = mxGetM(prhs[6]);
    
    
    // Output
    plhs[0] = mxCreateDoubleMatrix(numJoints, numTrajectorySteps, mxREAL);
    plhs[1] = mxCreateDoubleMatrix(numJoints, numTrajectorySteps, mxREAL);
    plhs[2] = mxCreateDoubleMatrix(numJoints, numTrajectorySteps, mxREAL);

    double
    *Y = mxGetPr(plhs[0]),
    *Yd = mxGetPr(plhs[1]),
    *Ydd = mxGetPr(plhs[2]);
    
    // Internal
    mxArray
    *xData = mxCreateDoubleMatrix(numJoints, 1, mxREAL),
    *xdData = mxCreateDoubleMatrix(numJoints, 1, mxREAL),
    *tData = mxCreateDoubleMatrix(numJoints, 1, mxREAL);    

    double
    *x = mxGetPr(xData),
    *xd = mxGetPr(xdData),
    *t_0 = mxGetPr(xdData);
    
    // initialize Y and x
    for (int iJoint = 0; iJoint < numJoints; iJoint++){
        Y[iJoint] = startPosition[iJoint];
        Yd[iJoint] = startVelocity[iJoint];
        x[iJoint] = startVelocity[iJoint]/tau;
        //goalVelocity[iJoint] = goalVelocity[iJoint] * tau;
        //goalPosition[iJoint] = goalPosition[iJoint] - goalVelocity[iJoint] * tau * numTrajectorySteps * dt;
    }
    
    for (int iTrajectoryStep = 1; iTrajectoryStep<numTrajectorySteps; iTrajectoryStep++){
        
        for (int iJoint = 0; iJoint < numJoints; iJoint++){
            
            double goalVel = goalVelocity[iJoint] * tau;
            double goalTemp = goalPosition[iJoint] - goalVel * dt * (numTrajectorySteps - iTrajectoryStep);
            int
            curI = ((iTrajectoryStep)*numJoints)+iJoint,
            oldI = ((iTrajectoryStep-1)*numJoints)+iJoint;
            
            double smoothedForcingFunction = iTrajectoryStep < numForcedSteps ? forcingFunction[oldI] : 0;
            double Ydd = (alpha_x*(beta_x*(goalTemp-Y[oldI])+(goalVel-Yd[oldI])/ tau)  +(amplitude[iJoint]*smoothedForcingFunction))*tau * tau;
               
            // simplectic Euler
            Yd[curI] = Yd[oldI] + dt*Ydd;
            Y[curI] = Y[oldI] + dt*Yd[curI];
            
        }        
    }
//    printf("Done\n");
    mxDestroyArray(xData);
    mxDestroyArray(xdData);
    mxDestroyArray(tData);
    
}
