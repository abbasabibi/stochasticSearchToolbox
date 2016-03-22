#ifndef __IAS_COMMON__
#define __IAS_COMMON__ 1

#define STEPLIMIT 			100000 //changed from 50000 (was too small)



//#define DPRINT
#ifdef DPRINT
// debugging macros so we can pin down message origin at a glance
#define DEBUGPRINT(...)       printf(__VA_ARGS__)
#else
#define DEBUGPRINT(...)
#endif //DPRINT

#define JINV_WEIGHTS_FILE  "JinvWeights"



#define FOR(i,k)    for( (i) = 1; i <= (k); ++(i)) 
#define MAX(a,b)    ( ((a)>(b)) ? (a) : (b) )
#define MIN(a,b)    ( ((a)<(b)) ? (a) : (b) )
#define ABS(a)      ( ((a) > 0.f) ? (a) : -(a))
#define SIGN(a)     ( ((a) > 0.f) ? (1) : -(1) )


#ifndef XSTR
#define XSTR(x) STR(x)
#endif

#ifndef STR
#define STR(x) #x
#endif


extern double sampling_time;

#endif // __IAS_COMMON__
