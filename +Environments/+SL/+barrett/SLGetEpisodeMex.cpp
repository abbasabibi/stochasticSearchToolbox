#include "mex.h"
#include <math.h>

/////////////////
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <errno.h>
#include <sys/shm.h>
#include <sys/stat.h>
#include <sys/sem.h>
#include <sys/types.h>
#include <string.h>

#include <errno.h>

#define DONEMATLAB          99999
#define DONESL              99998
#define SHAREDMEMTIMEOUT    99997
//////////////////////////


#define WAITFORSTATE_SEM 	50000
#define WAITFORHIT_SEM 		50001
#define SIGNALSTATE_SEM 	50002
#define SIGNALREWARD_SEM 	50003

#define STATE_SEM 			50004
#define DMP_SEM 			50005
#define REWARD_SEM 			50006

#define STATES_SHM 			100000
#define DMP_SHM 			100001
#define REWARD_SHM 			100002


#define NUMEPISODICSTATES 	100
#define MAXEPISODERESULT 	100

#include "sharedmemory.cpp"
#include "SL_episodic_communication.cpp"
#include "sem_timedwait.cpp"

#ifndef N_DOFS 
#define N_DOFS 9
#endif

void mexFunction(int nlhs, mxArray *plhs[], 
                 int nrhs, const mxArray *prhs[])
{
	static bool firstTime = true;
	
	
	initSemaphore(&stepSEM);
	attachSEM(&stepSEM, STEP_SEM);
	
	initSharedMemory(&stepSHM, sizeof(episode_steps));
	attachSHM(&stepSHM, STEP_SHM, &stepSEM);
	
	readSHMemory(&stepSHM, &episodeStep, &stepSEM);
	
	int numStates = (int) *mxGetPr(prhs[0]);
	int numSteps = episodeStep.numTransmittedSteps;
	
	fprintf(stderr, "NumSteps: %d\n",numSteps);

	plhs[0]         = mxCreateDoubleMatrix(N_DOFS, numSteps, mxREAL);
	plhs[1]         = mxCreateDoubleMatrix(N_DOFS, numSteps, mxREAL);
	plhs[2]         = mxCreateDoubleMatrix(N_DOFS, numSteps,  mxREAL);
	
	plhs[3]         = mxCreateDoubleMatrix(N_DOFS, numSteps, mxREAL);
	plhs[4]         = mxCreateDoubleMatrix(N_DOFS, numSteps, mxREAL);
	plhs[5]         = mxCreateDoubleMatrix(N_DOFS, numSteps,  mxREAL);
	
	
	plhs[6]         = mxCreateDoubleMatrix(N_DOFS, numSteps,  mxREAL);
	plhs[7]         = mxCreateDoubleMatrix(7, numSteps, mxREAL);
	plhs[8]         = mxCreateDoubleMatrix(numStates, numSteps, mxREAL);
    
	plhs[9]         = mxCreateDoubleMatrix(1, numSteps, mxREAL);
	plhs[10]         = mxCreateDoubleMatrix(1, numSteps, mxREAL);
    plhs[10]        = mxCreateDoubleMatrix(1, numSteps, mxREAL);
	
	double *joints = mxGetPr(plhs[0]);
	double *jointsVel = mxGetPr(plhs[1]);
	double *jointsAcc = mxGetPr(plhs[2]);
	
	double *jointsDes = mxGetPr(plhs[3]);
	double *jointsVelDes = mxGetPr(plhs[4]);
	double *jointsAccDes = mxGetPr(plhs[5]);
	
	
	double *torque = mxGetPr(plhs[6]);
	
	double *cart = mxGetPr(plhs[7]);
	double *state = mxGetPr(plhs[8]);
	
    	double *commandIdx = mxGetPr(plhs[9]);
    	double *stepInTrajectory = mxGetPr(plhs[10]);

    
    double *doMotionIdx = mxGetPr(plhs[10]);
    
    
    
	memcpy(joints, episodeStep.joints, sizeof(double) * numSteps * N_DOFS);
	memcpy(jointsVel, episodeStep.jointsVel, sizeof(double) * numSteps * N_DOFS);
	memcpy(jointsAcc, episodeStep.jointsAcc, sizeof(double) * numSteps * N_DOFS);
	
	memcpy(jointsDes, episodeStep.jointsDes, sizeof(double) * numSteps * N_DOFS);
	memcpy(jointsVelDes, episodeStep.jointsVelDes, sizeof(double) * numSteps * N_DOFS);
	memcpy(jointsAccDes, episodeStep.jointsAccDes, sizeof(double) * numSteps * N_DOFS);
	
	
	memcpy(torque, episodeStep.torque, sizeof(double) * numSteps * N_DOFS);
	memcpy(cart, episodeStep.cart, sizeof(double) * numSteps * 7);
    

//     printf("doMotionIdx :");
//     for (int i = 0; i < numSteps; i ++)
//         printf(" %d",episodeStep.doMotionIdx[i]);
//     printf(" \n");

	for (int i = 0; i < numSteps; i ++)
	{
		for (int j = 0; j < numStates; j ++)
		{
			state[i * numStates + j] = episodeStep.state[i][j];
//			printf("%f ", episodeStep.state[i][j]);
		}
//		printf("\n");
	}
	

	for (int i = 0; i < numSteps; i ++)
    	{
        	commandIdx[i] = episodeStep.commandIdx[i];
            doMotionIdx[i] = episodeStep.doMotionIdx[i];
	}

	for (int i = 0; i < numSteps; i ++)
    	{
        	stepInTrajectory[i] = episodeStep.stepInTrajectory[i];
	}
    
	deleteSemaphore(&stepSEM);
	deleteSharedMemory(&stepSHM);
	
}
