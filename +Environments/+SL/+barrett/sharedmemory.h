#ifndef C_SHARED_MEMORY__H
#define C_SHARED_MEMORY__H


#include <sys/types.h>
#include <sys/time.h>
#include "ias_common.h"


#ifdef __APPLE__
#include <semaphore.h>
#define NAMELENGTH 20
#endif



/** A wrapper class for IPC semaphores
 * 
 * This class is a wrapper around the POSIX semaphores described
 * by the following man pages: sem_overview, semop, semctl
 */


typedef struct semaphore
{
#ifdef __APPLE__
    sem_t * sem;
    char name[NAMELENGTH];
#endif
    
	int semID;
	int semKey;

	int createdSEM;
	struct timespec timeout;
} semaphore;


typedef struct sharedmemory
{
	int shmID;
	int shmKey;
	
	size_t sharedMemorySize;
	
	void *memoryPointer;
	
	int createdMemory;
} sharedmemory;



void initSemaphore(semaphore *sem);
void deleteSemaphore(semaphore *sem);

	/** Decrease the semaphore value by one
	 * 
	 * Decreases the semaphore value by one and puts the calling
	 * process to sleep if the value before the call was 0. The
	 * process will then sleep until another process calls
	 * unLockData().
	 * @return errno on error, otherwise 0
	 */
int lockData(semaphore *sem);

	/** Decrease the semaphore value by one
	 *
	 * Decreases the semaphore value by one iff the value of
	 * the semaphore is >= 1. If the value before the call was 0
	 * return immediately.
	 * @return errno on error, otherwise 0
	 */
int tryLockData(semaphore *sem);

	/** Increase the semaphore value by one
	 * 
	 * Increases the semaphore value by one, possibly waking one
	 * process waiting on the semaphore.
	 * @return errno on error, otherwise 0
	 */
int unLockData(semaphore *sem);


void setTimeOut(semaphore *sem, int millisecs);

	/** Tries to create and attach this object to the a new semaphore
	 *
	 * This method tries to create a new semaphore with the key l_semKey
	 * and attaches this object to it. If a semaphore with the given
	 * key already exists, it tries to remove and recreate it. This
	 * only works if your permissions are sufficient.
	 * @param l_semKey The key of the semaphore to be created
	 * @return The semaphore ID of the new semaphore, or -1 on error
	 */
int createSEM(semaphore *sem, int l_semKey);
	
	/** Attach the object to a semaphore
	 * 
	 * This method associates the object with the semaphore
	 * identified by l_semKey
	 * @param l_semKey The semaphore key to attach to
	 * @return The semaphore ID, or -1 on error
	 */
int attachSEM(semaphore *sem, int l_semKey);
	
/** Returns the current semaphore value
 * 
 * This method returns the current value of the semaphore
 * @return The current semaphore value
 */

int getSemaphoreValue(semaphore *sem);

void setSemaphoreValue(semaphore *sem, int value);
	
/** Returns the number of processes waiting
 * 
 * This method returns the number of processes waiting on this
 * semaphore for the semaphore value to increase.
 * @return The number of processes sleeping on this semaphore
 */
int getSemaphoreWaiting(semaphore *sem);


void initSharedMemory(sharedmemory *shm, size_t sharedMemorySize);
void deleteSharedMemory(sharedmemory *shm);
	
int createSHM(sharedmemory *shm, int l_shmKey, semaphore *sem);
int attachSHM(sharedmemory *shm, int l_shmKey, semaphore *sem);
		
size_t getMemorySize(sharedmemory *shm);
	
void *getMemoryPointer(sharedmemory *shm);

void writeSHMemory(sharedmemory *shm, void *buffer, semaphore *sem);

/** Writes data to shared memory without blocking
 *  if the semaphore is not available.
 *
 *  @return 0 on success and errno on failure.
 */
int writeSHMemoryNonBlk(sharedmemory *shm, void *buffer, semaphore *sem);

int readSHMemory(sharedmemory *shm, void *buffer, semaphore *sem);

/** Reads data to shared memory without blocking
 *  if the semaphore is not available. In case of
 *  failure the buffer remains unmodified.
 *
 *  @return 0 on success and errno on failure.
 */
int readSHMemoryNonBlk(sharedmemory *shm, void *buffer, semaphore *sem);



#endif

