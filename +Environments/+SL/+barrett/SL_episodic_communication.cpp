//#include "SL_user.h"

#include "SL_episodic_communication.h"

//#include <stdio.h>
//#include <stdlib.h>
#include <errno.h>
#include <string.h>
//
//#include "SL.h"
//#include "utility.h"
//#include "SL_tasks.h"
//#include "SL_task_servo.h"
//
//#include "ias_utilities.h"
//#include "ias_motor_utilities.h"



episode_state episodeState;
episode_trajectory episodeTrajectory;
episode_steps episodeStep;


semaphore waitForStart;
semaphore waitForHit;
semaphore signalState;

semaphore stateSEM;
semaphore dmpSEM;
semaphore stepSEM;

sharedmemory stateSHM;
sharedmemory dmpSHM;
sharedmemory stepSHM;




int attachEpisodicSharedMemoryCommunication()
{
    int ret = 1, tmp = 0;


	initSemaphore(&waitForStart);
	tmp = attachSEM(&waitForStart, WAITFORSTATE_SEM);

	initSemaphore(&signalState);
	ret = attachSEM(&signalState, SIGNALSTATE_SEM);

	initSemaphore(&stateSEM);

	attachSEM(&stateSEM, STATE_SEM);

	initSemaphore(&dmpSEM);
	attachSEM(&dmpSEM, DMP_SEM);

	initSharedMemory(&stateSHM, sizeof(episode_state));
	ret = attachSHM(&stateSHM, STATES_SHM, &stateSEM);


	initSharedMemory(&dmpSHM, sizeof(episode_trajectory));
	attachSHM(&dmpSHM, DMP_SHM, &dmpSEM);

	memset(&episodeState, 0, sizeof(episode_state));
	memset(&episodeTrajectory, 0, sizeof(episode_trajectory));

    return ret;
}


void createEpisodicSharedMemoryCommunication()
{
	//int ndof = N_DOFS;
	//printf("NDoFS for SHM: %d\n", ndof);


	initSemaphore(&waitForStart);
	createSEM(&waitForStart, WAITFORSTATE_SEM);


	initSemaphore(&signalState);
	createSEM(&signalState, SIGNALSTATE_SEM);

	initSemaphore(&stateSEM);
	createSEM(&stateSEM, STATE_SEM);


	initSemaphore(&dmpSEM);
	createSEM(&dmpSEM, DMP_SEM);


	initSemaphore(&stepSEM);
	createSEM(&stepSEM, STEP_SEM);

	initSharedMemory(&stateSHM, sizeof(episode_state));
	createSHM(&stateSHM, STATES_SHM, &stateSEM);


	initSharedMemory(&dmpSHM, sizeof(episode_trajectory));
	createSHM(&dmpSHM, DMP_SHM, &dmpSEM);

	initSharedMemory(&stepSHM, sizeof(episode_steps));
	createSHM(&stepSHM, STEP_SHM, &stepSEM);

	memset(&episodeState, 0, sizeof(episode_state));
	memset(&episodeTrajectory, 0, sizeof(episode_trajectory));
	memset(&episodeStep, 0, sizeof(episode_steps));

}



void deleteEpisodicSharedMemoryCommunication()
{
	deleteSemaphore(&waitForStart);
	deleteSemaphore(&signalState);
	deleteSemaphore(&stateSEM);
	deleteSemaphore(&dmpSEM);

	deleteSharedMemory(&stateSHM);
	deleteSharedMemory(&dmpSHM);

}

int setSemaphoreZero(semaphore *sem)
{
    int ret = 0;
#ifdef __APPLE__
    errno = 0;
    ret = sem_trywait(sem->sem);
    if(ret == -1) //Sem is already zero, we can't lock
    {
        return ret;
    }

    while( ret == 0 ) //We could lock at least one time.
    {
        ret = sem_trywait(sem->sem);
    }
    return 1;

#else
    ret = getSemaphoreValue(sem);
    if(ret > 0 )
    {
        setSemaphoreValue(sem, 0);
        return 1;
    }
    return -1;

#endif
}

int isStartEpisodeStepWait(int commandIdx, int waitForMatlab)
{
	int k = -1;

	if(waitForMatlab)
	{
		while(k != 0)
		{
			k = lockData(&waitForStart);
		}
		unLockData(&waitForStart);
	}

	int val = setSemaphoreZero(&waitForStart);
	if (val > 0) //setSemaphoreZero (first tryLock was successfull)
	{
		getTrajectoryFromSHM();

		if (episodeTrajectory.commandIdx == -1) {
			return -666;
		} else if (episodeTrajectory.commandIdx != commandIdx) {
			return -100;
		} else {
			return 1;
		}
	}
	else
	{
		return 0;
	}
}


int isStartEpisodeStep(int numCommand)
{
	return isStartEpisodeStepWait(numCommand, 0);
}


void writeStateToSHM()
{
	writeSHMemory(&stateSHM, &episodeState, &stateSEM);
	unLockData(&signalState);
}


void getStateFromSHM()
{
 	int r = lockData(&signalState);
// 	printf("r %d\n",r);

	readSHMemory(&stateSHM, &episodeState, &stateSEM);
}


void getTrajectoryFromSHM()
{
	readSHMemory(&dmpSHM, &episodeTrajectory, &dmpSEM);
}


void writeTrajectoryToSHM()
{
    int r = 0;

	writeSHMemory(&dmpSHM, &episodeTrajectory, &dmpSEM);

	r = unLockData(&waitForStart);

}
