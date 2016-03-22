/*
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Copyright 2000-2002 
%
% Michail G. Lagoudakis (mgl@cs.duke.edu)
% Ronald Parr (parr@cs.duke.edu)
%
% Department of Computer Science
% Box 90129
% Duke University
% Durham, NC 27708
% 
%
% A C implementation of the polynomial basis functions 
% for the bicycle
%
% The constant bike_actions should match the correct value
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
*/



#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <sys/types.h>
#include <limits.h>
#include <signal.h>
#include <sys/times.h>
#include <sys/time.h>
#include <errno.h>


#define HOWMANY 14
#define bike_actions 5
#define numbasis ( HOWMANY * bike_actions )
#define mypi (acos(-1))


double sign(double x)
{
  if (x==0.0)
    return 0.0;
  else if (x>0.0)
    return +1.0;
  else 
    return -1.0;
}


void bike_phi_pol(double *phi, double *state, double *action, int what)
{
  int base;
  int i;
  double newfeature; 


  if (what==0) {
    *phi = (double) numbasis; 
    return;
  }

  for (i=0; i<numbasis; i++)
    phi[i]=0.0;

  if (fabs(state[2]) > (mypi/15.0))
      return;

  base = (numbasis / bike_actions) * ( ((int) *action) - 1 ); 

  phi[base++] = 1.0;

  phi[base++] = state[2];
  phi[base++] = state[3];
  phi[base++] = state[2]*state[2];
  phi[base++] = state[3]*state[3];
  phi[base++] = state[2]*state[3];

  phi[base++] = state[0];
  phi[base++] = state[1];
  phi[base++] = state[1] * state[1];
  phi[base++] = state[0] * state[0];  
  phi[base++] = state[0] * state[1];  

  phi[base++] = state[2] * state[0];  
  phi[base++] = state[2] * state[0] * state[0];
  phi[base++] = state[2] * state[2] * state[0];
 
  return;
}




#include "mex.h"


void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray *prhs[] )
{ 
  
  double *phi;
  double *state;
  double *action;

  
  /* Check for proper number of arguments. */
  if ( (nrhs>2) || (nrhs==1) ) {
    mexErrMsgTxt("Incorrect number of inputs!.");
  } 
  else if (nlhs>1) {
    mexErrMsgTxt("Too many output arguments!");
  }
  
  /* Create a matrix for the return argument */ 
  if (nrhs>0)
    plhs[0] = mxCreateDoubleMatrix(numbasis, 1, mxREAL);
  else 
    plhs[0] = mxCreateDoubleMatrix(1, 1, mxREAL); 


  /* Assign pointers to the various parameters */ 
  phi  = mxGetPr(plhs[0]);
  
  if (nrhs>0) {
    state  = mxGetPr(prhs[0]);
    action = mxGetPr(prhs[1]);
  }
  
  
  /* Do the actual computations in a subroutine */
  bike_phi_pol(phi, state, action, nrhs);    

  return;
    
}



