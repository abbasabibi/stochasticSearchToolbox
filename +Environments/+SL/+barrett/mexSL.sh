#g++ sharedmemory.cpp -o sharedmemory.o -O2 -Wall -ggdb -c -fPIC
#mex SLSendTrajectoryMex.cpp
#mex GetEpisodeSLMex.cpp

mex -I../src -I../include -I$LAB_ROOT/barrett/include -I$LAB_ROOT/barrett/math -I/sw/include -I/usr/X11/include -I/usr/local/glut/include SLSendTrajectoryMex.cpp
mex -I../src -I../include -I$LAB_ROOT/barrett/include -I$LAB_ROOT/barrett/math -I/sw/include -I/usr/X11/include -I/usr/local/glut/include GetEpisodeSLMex.cpp
