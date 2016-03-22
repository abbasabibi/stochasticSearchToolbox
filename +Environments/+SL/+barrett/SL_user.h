/*!=============================================================================
  ==============================================================================

  \file    SL_user.h

  \author  Stefan Schaal
  \date    May 2010

  ==============================================================================
  \remarks
  
  robot specific definitions for Barrett WAM 7 DOF arm and hand
  
  ============================================================================*/
  
#ifndef _SL_user_
#define _SL_user_

//! the robot name
#define ROBOT_NAME "barrett"

// dimensions of the robot
#define ZSFE 0.346              //!< z height of SAA axis above ground
#define ZHR  0.505              //!< length of upper arm until 4.5cm before elbow link
#define YEB  0.045              //!< elbow y offset
#define ZEB  0.045              //!< elbow z offset
#define YWR -0.045              //!< elbow y offset (back to forewarm)
#define ZWR  0.045              //!< elbow z offset (back to forearm)
#define ZWFE 0.255              //!< forearm length (minus 4.5cm)

// links of the robot
enum RobotLinks {
  SHOULDER = 1,
  BEFORE_ELBOW,
  ELBOW,
  AFTER_ELBOW,
  WRIST,

  PALM,

  N_ROBOT_LINKS
};

// endeffector information
enum RobotEndeffectors {
  RIGHT_HAND=1,

  N_ROBOT_ENDEFFECTORS
};

// vision variables
enum VisionCameras {
  CAMERA_1=1,
  CAMERA_2,
  CAMERA_3,
  CAMERA_4,
  N_VISION_CAMERAS
};

enum ColorBlobs {
  BLOB1=1,
  BLOB2,
  BLOB3,
  BLOB4,
  BLOB5,
  BLOB6,

  N_COLOR_BLOBS
};

enum CameraPairs {
  PAIR1_LEFT_CAMERA=1,
  PAIR1_RIGHT_CAMERA,
  PAIR2_LEFT_CAMERA,
  PAIR2_RIGHT_CAMERA,
  N_CAMERA_PAIRS
};

// define the DOFs of this robot
enum RobotDOFs {
  R_SFE = 1,
  R_SAA,
  R_HR,
  R_EB,
  R_WR,
  R_WFE,
  R_WAA,

  N_ROBOT_DOFS
};

//! define miscellenous sensors of this robot
enum RobotMiscSensors {

 N_ROBOT_MISC_SENSORS=1
};


//! number of degrees-of-freedom of robot
#define N_DOFS (N_ROBOT_DOFS-1)

//! N_DOFS + fake DOFS, needed for parameter estimation; 
//   fake DOFS come from creating endeffector information
#define N_DOFS_EST (N_DOFS+0)

//! N_DOFS to be excluded from parameter estimation (e.g., eye joints);
//  these DOFS must be the last DOFS in the arrays
#define N_DOFS_EST_SKIP 0

//! number of links of the robot
#define N_LINKS    (N_ROBOT_LINKS-1)

//! number of miscellaneous sensors
#define N_MISC_SENSORS   (N_ROBOT_MISC_SENSORS-1)

//! number of endeffectors
#define N_ENDEFFS  (N_ROBOT_ENDEFFECTORS-1)

//! number of cameras used
#define N_CAMERAS (N_VISION_CAMERAS-1)

//! number of blobs that can be tracked by vision system
#define MAX_BLOBS (N_COLOR_BLOBS-1)

//! vision default post processing
#define VISION_DEFAULT_PP "vision_default.pp"

//! the servo rate used by the I/O with robot: this limits the
//  servo rates of all other servos 
#define  SERVO_BASE_RATE 500

//! divisor to obtain task servo rate (task servo can run slower than
//  base rate, but only in integer fractions */
#define  TASK_SERVO_RATIO   R1TO1

// settings for D/A debugging information -- see SL_oscilloscope.c 
#define   D2A_CM      1
#define   D2A_CT      2
#define   D2A_CV      3
#define   D2A_CR      4

// Allows setting a special endeffector
void set_special_endeffector(double x, double y, double z);

#ifdef __cplusplus
extern "C" {
#endif

  // function prototype

#ifdef __cplusplus
}
#endif


#endif  /* _SL_user_ */



