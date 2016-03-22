// #include "SL_user.h"

#include "sharedmemory.h"

#include <sys/shm.h>
#include <sys/stat.h>
#include <string.h>

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>



#include <signal.h>
#include <sys/types.h>
#include <sys/ipc.h>



#ifdef __APPLE__
#include <sys/semaphore.h>
#include <fcntl.h>
#else
#include <sys/sem.h>
#endif


#include <time.h>

#include "sem_timedwait.h"



volatile int alarm_triggered = 0;
//void alarm_handler(int sig) 
//{
//    alarm_triggered = 1;
//}

void initSemaphore(semaphore *sem)
{
#ifdef __APPLE__
    sem->sem        = 0;
    sem->name[0]    = '\0';
#endif
    
	sem->semID = -1;
	sem->semKey = -1;
	sem->createdSEM = 0;

	setTimeOut(sem, 1000);
}

void deleteSemaphore(semaphore *sem)
{

#ifdef __APPLE__
    int ret = 0;
    if (sem->semKey != -1)
	{    
        
        if(sem->createdSEM)
        {
            errno   = 0;
            ret     = sem_unlink(sem->name);
        }
        
        errno   = 0;
        ret     = sem_close(sem->sem);           
    }
#else
    if (sem->semKey != -1 && sem->createdSEM)
	{
        semctl(sem->semID, 0, IPC_RMID, (int) 0);
    }

#endif

	
}
	
int lockData(semaphore *sem)
{
	int ret = 0;
#ifdef __APPLE__
//    signal(SIGALRM,&alarm_handler);
    
//    printf("Before lock Alarm time %d, sem %d, errno %d\n", sem->timeout.tv_sec, sem->sem, errno);

//    errno = 0;
//    ret = alarm(sem->timeout.tv_sec);
//    printf("After set alarm ret: %d, errno %d\n",ret, errno);
//    errno = 0;
//    ret = sem_wait(sem->sem);
    ret = sem_timedwait(sem->sem, &(sem->timeout) );


#else
    struct sembuf operations[1];
	
	operations[0].sem_num   = 0;
	operations[0].sem_op    = -1;
	operations[0].sem_flg   = SEM_UNDO;

	ret = semtimedop(sem->semID, operations, 1, &(sem->timeout)); 
#endif
    
    
    

	if (ret == -1 || alarm_triggered )
	{
        ret = -1;
	}

	return ret;
}

int tryLockData(semaphore *sem)
{
    
#ifdef __APPLE__
    int r = sem_trywait(sem->sem);
#else
    struct sembuf operations[1];
    
	operations[0].sem_num = 0;
	operations[0].sem_op = -1;
	operations[0].sem_flg = IPC_NOWAIT;
	int r = semop(sem->semID, operations, 1);
#endif

	if (r == -1)
	{
		r = errno;
	}

	return r;
}


int unLockData(semaphore *sem)
{
	
	
#ifdef __APPLE__
    int r = sem_post(sem->sem);
#else
    struct sembuf operations[1];
	
	operations[0].sem_num = 0;
	operations[0].sem_op = 1;
    operations[0].sem_flg = SEM_UNDO;
	int r = semop(sem->semID, operations, 1); 
#endif
	
	return r;
}

void setTimeOut(semaphore *sem, int millisecs)
{
	int secs    = millisecs / 1000;
	int msecs   = millisecs % 1000;
    
	sem->timeout.tv_sec     = secs;
	sem->timeout.tv_nsec    = msecs * 1000000;
    
#ifdef __APPLE__
    struct timeval currentTime;                              /* Time now */
    long secsToWait,nsecsToWait;            /* Seconds and nsec to delay */
    gettimeofday (&currentTime,NULL);
    sem->timeout.tv_sec  = sem->timeout.tv_sec + currentTime.tv_sec;
    sem->timeout.tv_nsec = (sem->timeout.tv_nsec + (currentTime.tv_usec * 1000));
#endif

    
}
	
int createSEM(semaphore *sem, int l_semKey)
{
	sem->semKey = l_semKey;

	sem->createdSEM = 1;
	int ret = 0;
    
#ifdef __APPLE__    
    
    sprintf(sem->name,"/tmp/%d",sem->semKey);
    sem->sem = sem_open(sem->name, O_CREAT | O_EXCL , S_IRWXU | S_IRWXG| S_IRWXO, 0);
    
    if( sem->sem == SEM_FAILED || errno == EEXIST)
    {
        ret = sem_unlink(sem->name);
        ret = sem_close(sem->sem);

        sem->sem = sem_open(sem->name, O_CREAT | O_EXCL , S_IRWXU | S_IRWXG| S_IRWXO, 0);		
    }
  
    ret = (long int)(sem->sem);
#else
    
	sem->semID = semget(sem->semKey, 1, IPC_CREAT | IPC_EXCL | S_IRWXU | S_IRWXG| S_IRWXO);
    if (sem->semID == -1)
	{
		sem->semID = semget(sem->semKey, 0, 0);
        semctl(sem->semID, 0, IPC_RMID, (int) 0);
		
		sem->semID = semget(sem->semKey, 1, IPC_CREAT | IPC_EXCL | S_IRWXU | S_IRWXG| S_IRWXO);

    }
    semctl(sem->semID, 0, SETVAL, (int) 0);	
    ret = sem->semID;
    
#endif



	
	return ret;
}

int attachSEM(semaphore *sem, int l_semKey)
{
	sem->semKey = l_semKey;
	int ret = 0;
#ifdef __APPLE__
    errno = 0;
    sprintf(sem->name,"/tmp/%d",sem->semKey);
    sem->sem = sem_open(sem->name, 0);

#else
	sem->semID = semget(sem->semKey, 0, 0);
    ret = sem->semID;
#endif
    

	if (errno > 0)
	{

	}
	
	return ret;
}	


int getSemaphoreValue(semaphore *sem)
{
#ifdef __APPLE__
    int ret = 0;
    printf("getSemaphore has been called but does not exist on mac os\n");
    return ret;
#else
	return 	semctl(sem->semID, 0, GETVAL, (int) 0);
#endif
}


void setSemaphoreValue(semaphore *sem, int value)
{
#ifdef __APPLE__
    printf("setSemaphore has been called but does not exist on mac os\n");
#else
	semctl(sem->semID, 0, SETVAL, value);
#endif
}


int getSemaphoreWaiting(semaphore *sem)
{
#ifdef __APPLE__
    printf("getSemaphoreWaiting has been called but does not exist on mac os\n");
    return -1;
#else
	return semctl(sem->semID, 0, GETNCNT, (int) 0);	
#endif
}

void initSharedMemory(sharedmemory *shm, size_t l_size)
{
	shm->shmKey = shm->shmID = 0;
	
	shm->createdMemory = 0;
	shm->memoryPointer = NULL;

	
	shm->sharedMemorySize = l_size;
}

void deleteSharedMemory(sharedmemory *shm)
{
	shmdt(shm->memoryPointer);
	if (shm->createdMemory == 1)
	{
		shmctl(shm->shmID, IPC_RMID, NULL);
	}	
}

int createSHM(sharedmemory *shm, int l_shmKey, semaphore *sem)
{
    shm->shmKey = l_shmKey;
	
	shm->shmID = shmget(shm->shmKey, shm->sharedMemorySize, IPC_CREAT | IPC_EXCL | S_IRWXU | S_IRWXG | S_IRWXO);
	
	if (shm->shmID == -1)
	{
		shm->shmID = shmget(shm->shmKey, 0, 0);
		shmctl(shm->shmID, IPC_RMID, NULL);
		shm->shmID = shmget(shm->shmKey, shm->sharedMemorySize, IPC_CREAT | IPC_EXCL | S_IRWXU | S_IRWXG| S_IRWXO);
	}
		
	if (shm->shmID == -1)
	{
		printf("Could not allocate shared memory (%d, size %d, error: %d)\n", shm->shmKey, (int) shm->sharedMemorySize, errno);
	}
	
	shm->memoryPointer = shmat(shm->shmID, NULL, 0);
		
	if (shm->memoryPointer == NULL)
	{
		printf("Memory Pointer = NULL, allocation failed\n");
	}
	else
	{
		memset(shm->memoryPointer, 0, shm->sharedMemorySize);
	}
	
	
	shm->createdMemory = 1;
	
	unLockData(sem);
	return errno;
}

int attachSHM(sharedmemory *shm, int l_shmKey, semaphore *sem)
{
    
	lockData(sem);
	shm->shmKey = l_shmKey;
	
	shm->shmID = shmget(shm->shmKey, 0, 0);
	int result = 0;

	if (shm->shmID == -1)
	{
		printf("Could not attach shared memory (%d)\n", shm->shmKey);
		result = -1;
	}
	else
	{
		shm->memoryPointer = shmat(shm->shmID, NULL, 0);
	}
	unLockData(sem);
    
    
	return errno;
}


void *getMemoryPointer(sharedmemory *shm)
{
	return shm->memoryPointer;
}

size_t getMemorySize(sharedmemory *shm)
{
	return shm->sharedMemorySize;
}

void writeSHMemory(sharedmemory *shm, void *buffer, semaphore *sem)
{
 
    lockData(sem);

    
	memcpy(shm->memoryPointer, buffer, shm->sharedMemorySize);

	unLockData(sem);

}

int writeSHMemoryNonBlk(sharedmemory *shm, void *buffer, semaphore *sem)
{
	int r = tryLockData(sem);
	if ( r != 0 )
		return r;
	memcpy(shm->memoryPointer, buffer, shm->sharedMemorySize);
	unLockData(sem);
	return 0;
}

int readSHMemory(sharedmemory *shm, void *buffer, semaphore *sem)
{   
    int r = 0;
	 r = lockData(sem);    
	if ( r )
		return r;
	memcpy(buffer, shm->memoryPointer, shm->sharedMemorySize);	
	unLockData(sem);
	return 0;
}

int readSHMemoryNonBlk(sharedmemory *shm, void *buffer, semaphore *sem)
{
	int r = tryLockData(sem);
	if ( r != 0 )
		return r;
	memcpy(buffer, shm->memoryPointer, shm->sharedMemorySize);
	unLockData(sem);
	return 0;
}
