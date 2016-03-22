#ifndef C_SL_EPISODIC_COMMUNICATION
#define C_SL_EPISODIC_COMMUNICATION

#include "sharedmemory.h"


#include "robotDOFS.h"


//extern semaphore waitForStart;
//extern semaphore waitForHit;
//extern semaphore signalState;
//extern semaphore signalReward;
//
//extern semaphore stateSEM;
//extern semaphore dmpSEM;
extern semaphore stepSEM;
//
//extern sharedmemory stateSHM;
//extern sharedmemory dmpSHM;
extern sharedmemory stepSHM;



#define WAITFORSTATE_SEM 	50000
#define WAITFORHIT_SEM 		50001
#define SIGNALSTATE_SEM 	50002
#define SIGNALREWARD_SEM 	50003

#define STATE_SEM 			50004
#define DMP_SEM 			50005
#define STEP_SEM 			50006

#define STATES_SHM 			100000
#define DMP_SHM 			100001
#define STEP_SHM 			100002

#define STEPLIMITEPISODE 	60000

#define NUMEPISODICSTATES 	100
#define MAXEPISODERESULT 	100
#define MAXEPISODESTATES 	100


enum stateNumbers {
	RESTARTEPISODE,
	GOTOSTART,
	WAITFORSTART,
	DOMOTION
};

typedef struct episode_steps
{
	int episodeID;
	int numTransmittedSteps;

	double joints[STEPLIMITEPISODE][N_DOFS_SHM];
	double jointsVel[STEPLIMITEPISODE][N_DOFS_SHM];
	double jointsAcc[STEPLIMITEPISODE][N_DOFS_SHM];

	double jointsDes[STEPLIMITEPISODE][N_DOFS_SHM];
	double jointsVelDes[STEPLIMITEPISODE][N_DOFS_SHM];
	double jointsAccDes[STEPLIMITEPISODE][N_DOFS_SHM];


	double torque[STEPLIMITEPISODE][N_DOFS_SHM];

	double cart[STEPLIMITEPISODE][7];
	double state[STEPLIMITEPISODE][MAXEPISODESTATES];

	int stepInTrajectory[STEPLIMITEPISODE];
	int commandIdx[STEPLIMITEPISODE];
	int doMotionIdx[STEPLIMITEPISODE];

} episode_steps;


typedef struct episode_state
{
	int episodeID;
	int commandIdx;
	double state[NUMEPISODICSTATES];
} episode_state;


typedef struct episode_trajectory
{
	int episodeID;
	int trajectorySize;// little steps
	int commandIdx;
	int maxCommands; // big steps
	double waitingTime;
	double trajectory[STEPLIMIT][N_DOFS_SHM + 1];
	double stateBuffer[NUMEPISODICSTATES];
} episode_trajectory;


extern episode_state episodeState;
extern episode_trajectory episodeTrajectory;
extern episode_steps episodeStep;


int attachEpisodicSharedMemoryCommunication();
void createEpisodicSharedMemoryCommunication();

void deleteEpisodicSharedMemoryCommunication();

int isStartEpisodeStepWait(int episodeStep, int waitForMatlab);

int isStartEpisodeStep(int episodeStep);

void writeStateToSHM();
void getStateFromSHM();
void getTrajectoryFromSHM();
void writeTrajectoryToSHM();


#endif

