
clear variables;
close all


config.fPrefixIn  = '/share/exchange/Alex/IROS2015/robotData/';
config.fPrefixOut = '/share/exchange/Alex/IROS2015/robotDataProc/';

% config.fNamesIn = {
%     'IROSGrate_FixatedClose_17-Feb-2015 22:24:59.mat',...
%     'IROSGrate_FixatedMid_17-Feb-2015 22:15:38.mat',...    
%     'IROSGrate_FixatedFarEnd_17-Feb-2015 22:08:21.mat'
% };

% config.demos2kill ={ [1, 23, 25], [1, 17 : 20], [4, 13, 15] };

config.fNamesIn = {
    'IROSGrate_SessionThree_20TrialsClose_18-Feb-2015 18:40:02.mat',...
    'IROSGrate_SessionThree_21TrialsFar_18-Feb-2015 19:02:44.mat',...
    'IROSGrate_SessionThree_23TrialsMid_18-Feb-2015 18:46:13.mat',...
    'IROSGrate_SessionThree_21TrialsMid2_18-Feb-2015 18:56:00.mat'
};

config.demos2kill ={ [1,5,18,19], [7,9,18,19,21], [1,6,7,21,23,17], [4,18,21] };



config.fsuffix = 'preProc';

config.saveIndividual = 1;


% config.force2save = (1:6)+1; % zero for not saving it
% config.force2save = [1,3]+1; % zero for not saving it
config.force2save = 3+1; % zero for not saving it
% config.force2save = 0;


config.forceFltAlpha = 0.965;
config.velFltalpha = 0.99;

config.Kp = 0.05;
config.alphaPos = 0.94;

config.outTorque = 1;

% config.joints2save = [1,4,5] +1 ;
% config.joints2save = [4,5] +1 ;
config.joints2save = 5 +1 ;

% config.actions2save = (1:3)+ 1;
% config.actions2save = ([1,3])+ 1;
config.actions2save = 3 + 1;


allData = TrajectoryGenerators.test.ProMPs.iCubGrateExp.preProcData (config);
