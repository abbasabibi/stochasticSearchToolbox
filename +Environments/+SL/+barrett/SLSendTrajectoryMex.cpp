#ifndef MATLAB
#define MATLAB
#endif
//////////////////
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


#define NUM_USED_STATES 20

#include "robotDOFS.h"

#include "sharedmemory.cpp"
#include "SL_episodic_communication.cpp"
#include "sem_timedwait.cpp"


void mexFunction(int nlhs, mxArray *plhs[],	int nrhs, const mxArray *prhs[]) {
	static int episodeID    = 1;


	if( attachEpisodicSharedMemoryCommunication() != -1 ) {

		int commandIdx = *mxGetPr(prhs[0]);
		int maxCommands = *mxGetPr(prhs[1]);
		double waitTime = *mxGetPr(prhs[2]);
		int numStates = mxGetNumberOfElements(prhs[4]);
		double *stateBuffer = mxGetPr(prhs[4]);
		int timeOut = *mxGetPr(prhs[5]);

		timeOut 		*= 1000;

		setTimeOut(&signalState, timeOut);


		double *(joints[N_DOFS + 1]);

		double * jointsMatrix = mxGetPr(prhs[3]);

		int cols      = mxGetN(prhs[3]);
		int numSteps  = mxGetM(prhs[3]);



		if(cols != N_DOFS)
		{
			printf("Cols: %d, should be: %d\n", cols, N_DOFS);
			mexErrMsgTxt("Input trajectory  does not have correct number of joints\n.");
		}

		if(numSteps > STEPLIMIT)
		{
			printf("Steps: %d Step limit: %d\n", numSteps, STEPLIMIT);
			mexErrMsgTxt("Input trajectory step size exceeds limit (STEPLIMIT) define in ias_common.h \n.");
		}


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


	}

	int numValuesRead   = NUM_USED_STATES;
	plhs[0]             = mxCreateDoubleMatrix(numValuesRead, 1, mxREAL);
	plhs[1]             = mxCreateDoubleMatrix(1, 1, mxREAL);
	double *result      = mxGetPr(plhs[1]),	*state  = mxGetPr(plhs[0]);

	//     printf("stateID %d, episodeID %d\n",episodeState.episodeID , episodeID);
	if (episodeState.episodeID == episodeID) {
		for (int i = 0; i < numValuesRead; ++i) {
			state[i] = episodeState.state[i];
		}
		*result = 1;
	} else {
		*result = -1;
	}

	episodeID = (episodeID + 1) % 2000;
	deleteEpisodicSharedMemoryCommunication();
}

