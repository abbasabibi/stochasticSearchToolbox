
#ifndef SEMTIMEDWAIT
#define SEMTIMEDWAIT

#ifdef __APPLE__

#include <semaphore.h>
#include <time.h>
#include <sys/time.h>
#include <pthread.h>
#include <errno.h>
#include <signal.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/fcntl.h>
#include <setjmp.h>


/*  Some useful definitions - TRUE, FALSE, and DEBUG */

#undef TRUE
#define TRUE 1
#undef FALSE
#define FALSE 0
#undef DEBUG
#define DEBUG printf

/*  A structure of type timeoutDetails is passed to the thread used to 
 *  implement the timeout.
 */

typedef struct {
   struct timespec delay;            /* Specifies the delay, relative to now */
   pthread_t callingThread;          /* The thread doing the sem_wait call */
   volatile short *timedOutShort;    /* Address of a flag set to indicate that
                                      * the timeout was triggered. */
} timeoutDetails;

/*  A structure of type cleanupDetails is passed to the thread cleanup 
 *  routine which is called at the end of the routine or if the thread calling
 *  it is cancelled.
 */
 
typedef struct {
   pthread_t *threadIdAddr;          /* Address of the variable that holds 
                                      * the Id of the timeout thread. */
   struct sigaction *sigHandlerAddr; /* Address of the old signal action
                                      * handler. */
   volatile short *timedOutShort;    /* Address of a flag set to indicate that
                                      * the timeout was triggered. */
} cleanupDetails;

/*  Forward declarations of internal routines */

static void* timeoutThreadMain (void* passedPtr);
static int triggerSignal (int Signal, pthread_t Thread);
static void ignoreSignal (int Signal);
static void timeoutThreadCleanup (void* passedPtr);

/* -------------------------------------------------------------------------- */
/*
 *                      s e m _ t i m e d w a i t
 *
 *  This is the main code for the sem_timedwait() implementation.
 */

int sem_timedwait (
   sem_t *sem,
                   const struct timespec *abs_timeout);

   
static void timeoutThreadCleanup (void* passedPtr);

  
static void* timeoutThreadMain (void* passedPtr);   


static int triggerSignal (int Signal, pthread_t Thread);   


static void ignoreSignal (int Signal) ;

#endif


#endif
