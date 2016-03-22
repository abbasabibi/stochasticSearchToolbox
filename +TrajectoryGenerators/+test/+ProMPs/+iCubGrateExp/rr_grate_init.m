clear variables;
close all;
Common.clearClasses;

prefix = '/scratch/data/';
fnameRel  = 'IROSGrate_SessionThree_21TrialsMid2_18-Feb-2015 18:56:00.matpreProcAll.mat';
fName = [ prefix, fnameRel ];

prefix = '/share/exchange/Alex/IROS2015/proMPGains/';
fNameOut  = 'ProMPgains-MonTau1D.mat';
fNameOut = [ prefix, fNameOut ];


TrajectoryGenerators.test.ProMPs.iCubGrateExp.rr_grate( fName, fNameOut )

