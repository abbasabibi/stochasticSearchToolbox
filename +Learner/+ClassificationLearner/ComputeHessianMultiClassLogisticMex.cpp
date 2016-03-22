//////////////////
#include "mex.h"
#include <math.h>

#define featureMatrix(i,j) featureMatrix[(i) + (j)*numSamples]
#define itemProbMatrix(i,j) itemProbMatrix[(i) + (j)*numSamples]
#define hessian(i,j) hessian[(i) + (j)*numClasses * numFeatures]


void mexFunction(int nlhs, mxArray *plhs[],	int nrhs, const mxArray *prhs[]) {
    static int episodeID    = 1;
    
    int numSamples = mxGetM(prhs[0]);
    int numFeatures   = mxGetN(prhs[0]);
    int numClasses   = mxGetN(prhs[1]);
         
              
    double * featureMatrix = mxGetPr(prhs[0]);
    double * itemProbMatrix = mxGetPr(prhs[1]);
    double * weighting = mxGetPr(prhs[2]);
           
    double errorVector[numSamples];
    plhs[0] = mxCreateDoubleMatrix(numClasses * numFeatures, numClasses * numFeatures, mxREAL);
    double *hessian = mxGetPr(plhs[0]);         
    
    for (int o = 0; o < numClasses; o ++)
    {
        int idxO = o * numFeatures ;
        for (int k = 0; k < numClasses; k ++)
        {
            int idxK = k * numFeatures;
            if (o > k)
            {
                // copy result
                for (int i = 0; i < numFeatures; i ++)
                {
                    for (int j = 0; j < numFeatures; j ++)
                    {
                        hessian(idxO + i, idxK + j) = hessian(idxK + j, idxO + i);
 
                    }
                }
            }
            else
            {
                // first bsxfun for error vector
                for (int i = 0; i < numSamples; i++)
                {
                    double itemProbLocal = - itemProbMatrix(i, k);
                    if (o == k)
                    {
                        itemProbLocal = 1 + itemProbLocal;
                    }
                    errorVector[i] = itemProbMatrix(i,o) * itemProbLocal * weighting[i];
                }
                // now do the matrix product
                for (int i = 0; i < numFeatures; i ++)
                {
                    for (int j = 0; j < numFeatures; j ++)
                    {
                        double matrixProdElement = 0;
                        for (int l = 0; l < numSamples; l++)
                        {
                             matrixProdElement += featureMatrix(l, i) * featureMatrix(l, j) * errorVector[l];
                        }
                        hessian(idxO + i, idxK + j) = matrixProdElement;
                    }
                }                
            }
        }
    }
        
/*
  
    
    for (int j = 0; j<N_DOFS; ++j) {
        joints[j] = &(jointsMatrix[numSteps * j]);
    }
    
    
    
    setSemaphoreZero(&signalState) ;
    
    episodeTrajectory.episodeID         = episodeID;
    episodeTrajectory.trajectorySize          = numSteps;
    episodeTrajectory.commandIdx        = commandIdx;
    episodeTrajectory.waitingTime       = waitTime;
    episodeTrajectory.maxCommands          = maxCommands;
    
    
    //fprintf(stderr,"TrajIdx: %d, TrajSize %d\n",commandIdx, numSteps);
    
    
    if (numStates > 0) {
        for(int j = 0; j < numStates; j++) {
            episodeTrajectory.stateBuffer[j] = stateBuffer[j];
        }
    }
    
    for(int j = 0; j < N_DOFS; ++j) {
        for (int i = 0; i<numSteps; ++i) {
            episodeTrajectory.trajectory[i + 1][j + 1] = joints[j][i];
        }
    }
    
    writeTrajectoryToSHM();
    
    getStateFromSHM();
    
    
plhs[0]             = mxCreateDoubleMatrix(numValuesRead, 1, mxREAL);
plhs[1]             = mxCreateDoubleMatrix(1, 1, mxREAL);
double *result      = mxGetPr(plhs[1]),	*state  = mxGetPr(plhs[0]);*/

}

