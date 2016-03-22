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
% [nexts, reward, endsim] = bicycle(state, action, maxnoise);
%
% C implementation of the bicycle equations / simulator
% 
% Input :  state - a state
%          action - an explicit action (torque, displacement)
%          maxnoise - the max noise in the displacement
% 
% Output:  nexts  - the next state 
%          reward - the reward in this step
%          endsim - a flag for the end of the episode
% 
% With no arguments it initializes the simulator to the initial
% (zero) state. With the "state" argument only initializes the
% simulator to that particular state. With all three arguments it
% does the one step simulation. 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
