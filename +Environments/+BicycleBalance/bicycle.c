/*
 * %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 * %
 * % Copyright 2000-2002
 * %
 * % Michail G. Lagoudakis (mgl@cs.duke.edu)
 * % Ronald Parr (parr@cs.duke.edu)
 * %
 * % Department of Computer Science
 * % Box 90129
 * % Duke University
 * % Durham, NC 27708
 * %
 * %
 * %
 * % C implementation of the equation of the bicycle
 * %
 * %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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


double calc_dist_to_goal(double xf, double xb, double yf, double yb);
double calc_angle_to_goal(double xf, double xb, double yf, double yb);
double orig_calc_angle_to_goal(double xf, double xb, double yf, double yb);


#define sqr(x)       ((x)*(x))

#define dt           0.01
#define v            (10.0/3.6)  /* 10 km/h in m/s */
#define g            9.82
#define dCM          0.3
#define c            0.66
#define h            0.94
#define Mc           15.0
#define Md           1.7
#define Mp           60.0
#define M            (Mc + Mp)
#define R            0.34          /* tyre radius */
#define sigma_dot    ( ((double) v) /R)
#define I_bike       ((13.0/3)*Mc*h*h + Mp*(h+dCM)*(h+dCM))
#define I_dc         (Md*R*R)
#define I_dv         ((3.0/2)*Md*R*R)
#define I_dl         ((1.0/2)*Md*R*R)
#define l            1.11     /* distance between the point where
the front and back tyre touch the ground */

#define mypi         (acos(-1))

/* position of goal */
const double x_goal=1000.0, y_goal=0.0, radius_goal=10.0;



double sign(double x)
{
    if (x==0.0)
        return 0.0;
    else if (x>0.0)
        return +1.0;
    else
        return -1.0;
}


void bicycle(double *nextstate, double *reward, double *endsim,
        double *istate,  double *action, int to_do, double *maxnoise)
{
    static double omega, omega_dot, omega_d_dot,
            theta, theta_dot, theta_d_dot,
            xf, yf, xb, yb;                   /* tyre position */
    double T, d;
    static double rCM, rf, rb;
    static double phi,
            psi,            /* bike's angle to the y-axis */
            psi_goal;       /* Angle to the goal */
    double temp;
    static double lastdtg, dtg;
    double noise;
    double old_omega;
    double real_psi;
    double tempcos;
    double default_angle = mypi/2.0;
    
    theta       = istate[0];
    theta_dot   = istate[1];
    theta_d_dot = 0.0;
    omega       = istate[2];
    omega_dot   = istate[3];
    
    nextstate[0] = theta;
    nextstate[1] = theta_dot;
    nextstate[2] = omega;
    nextstate[3] = omega_dot;
    
    *reward = 0.0;
    *endsim = 0.0;
    
    
    
    T = action[0];
    d = action[1];
    
    /* Noise in steering
     * noise = ( (double) (random() % ((long) pow(2,30)) ) ) / pow(2,30);
     * T = T + 1.0 * (noise * 2 - 1);*/
    
    /* Noise in displacement */
    /*noise = ( (double) (rand() % ((long) pow(2,30)) ) ) / pow(2,30);
    %noise = noise*2 - 1;*/
    noise = -1.0f + (float)(rand() /(float)(RAND_MAX/2));
    d = d + *maxnoise * noise; /* Max noise is 2 cm */
    
    
    old_omega = omega;
    
    if (theta == 0) {
        rCM = rf = rb = 9999999; /* just a large number */
    } else {
        rCM = sqrt(pow(l-c,2) + l*l/(pow(tan(theta),2)));
        rf = l / fabs(sin(theta));
        rb = l / fabs(tan(theta));
    } /* rCM, rf and rb are always positiv */
    
    /* Main physics eq. in the bicycle model coming here: */
    phi = omega + atan(d/h);
    omega_d_dot = ( h*M*g*sin(phi)
    - cos(phi)*(I_dc*sigma_dot*theta_dot
            + sign(theta)*v*v*(Md*R*(1.0/rf + 1.0/rb)
            +  M*h/rCM) )
            ) / I_bike;
    theta_d_dot =  (T - I_dv*omega_dot*sigma_dot) /  I_dl;
    
    /*--- Eulers method ---*/
    omega_dot += omega_d_dot * dt;
    omega     += omega_dot   * dt;
    theta_dot += theta_d_dot * dt;
    theta     += theta_dot   * dt;
    
    if (fabs(theta) > 1.3963) { /* handlebars cannot turn more than
     * 80 degrees */
        theta = sign(theta) * 1.3963;
    }
    
    nextstate[0] = theta;
    nextstate[1] = theta_dot;
    nextstate[2] = omega;
    nextstate[3] = omega_dot;
    
    
    /*-- Calculation of the reward  signal --*/
    
    *reward = sqr(old_omega*15/mypi) - sqr(omega*15/mypi);
    
    
    if (fabs(omega) > (mypi/15)) { /* the bike has fallen over */
        *endsim =  1.0;
        /* a good place to print some info to a file or the screen */
    } else {
        *endsim = 0.0;
    }
    
    return;
    
}


/*
 * // Weird angle from the back wheel
 * double calc_angle_to_goal(double xf, double xb, double yf, double yb)
 * {
 * double temp, scalar, perpx, perpy, s, cosine, bikelen;
 *
 * temp = (xf-xb)*(x_goal-xb) + (yf - yb)*(y_goal-yf);
 * bikelen = sqrt(sqr(xf - xb) + sqr(yf-yb));
 * scalar =  bikelen * sqrt(sqr(x_goal-xb)+sqr(y_goal-yb));
 *
 * perpx = yb - y_goal;
 * perpy = x_goal - xb;
 *
 * s = sign((xf-xb)*perpx + (yf-yb)*perpy);
 *
 * cosine = temp/scalar;
 *
 * if (cosine > 1.0)
 * cosine = 1.0;
 *
 * if (cosine < -1.0)
 * cosine = -1.0;
 *
 * if (s > 0)
 * return 1.0-cosine;
 * else
 * return -1.0+cosine;
 * }
 */

/*
 * Angle from the front wheel
 * double calc_angle_to_goal(double xf, double xb, double yf, double yb)
 * {
 * double temp, scalar, perpx, perpy, s, cosine, bikelen;
 *
 * temp = (xf-xb)*(x_goal-xf) + (yf-yb)*(y_goal-yf);
 * bikelen = sqrt( sqr(xf-xb) + sqr(yf-yb) );
 * scalar =  bikelen * sqrt( sqr(x_goal-xf) + sqr(y_goal-yf) );
 *
 * perpx = yf - y_goal;
 * perpy = x_goal - xf;
 *
 * s = sign( (xf-xb)*perpx + (yf-yb)*perpy );
 *
 * cosine = temp/scalar;
 *
 * if (cosine > 1.0)
 * cosine = 1.0;
 *
 * if (cosine < -1.0)
 * cosine = -1.0;
 *
 * if (s > 0)
 * return acos(cosine);
 * else
 * return -acos(cosine);
 * }
 */




#include "mex.h"

/* Input Arguments */

#define	S_IN	prhs[0]
#define	A_IN	prhs[1]
#define M_IN    prhs[2]

/* Output Arguments */

#define	NS_OUT	plhs[0]
#define	RE_OUT	plhs[1]
#define	ES_OUT	plhs[2]


void mexFunction( int nlhs, mxArray *plhs[],
        int nrhs, const mxArray *prhs[] )
        
{
    
    double *state;
    double *reward;
    double *endsim;
    double *istate;
    double *action;
    int to_do;
    double *maxnoise;
    
    /* Check for proper number of arguments. */
    if (nrhs>3) {
        mexErrMsgTxt("Too many inputs!.");
    }
    else if (nlhs>3) {
        mexErrMsgTxt("Too many output arguments!");
    }
    
    /* Create a matrix for the return argument */
    NS_OUT = mxCreateDoubleMatrix(1, 11, mxREAL);
    RE_OUT = mxCreateDoubleMatrix(1, 1, mxREAL);
    ES_OUT = mxCreateDoubleMatrix(1, 1, mxREAL);
    
    /* Assign pointers to the various parameters */
    state  = mxGetPr(NS_OUT);
    reward = mxGetPr(RE_OUT);
    endsim = mxGetPr(ES_OUT);
    
    if (nrhs==0)
        to_do = 0;
    else if (nrhs==1) {
        istate = mxGetPr(S_IN);
        to_do = 1;
    }
    else {
        istate = mxGetPr(S_IN);
        action = mxGetPr(A_IN);
        to_do = 2;
        maxnoise = mxGetPr(M_IN);
    }
    
    /* Do the actual computations in a subroutine */
    bicycle(state, reward, endsim, istate, action, to_do, maxnoise);
    
    return;
    
}


