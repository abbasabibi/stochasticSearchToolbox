close all
Common.clearClasses();
clear variables
clc


% load data
disp('loading data.');
subjects = Filter.test.humod.loadHumanMotionData({'A'},{'1.1','1.2','1.3','2.1','2.2','2.3','4'},20);

% create data manager
dataManager = Data.DataManager('episodes');
dataManager.addDataEntry('subject',1);
dataManager.addDataEntry('frameRate',1);
dataManager.addDataEntry('frames',1);

stepDataManager = Data.DataManager('steps');

stepDataManager.addDataEntry('jointX',15);
stepDataManager.addDataEntry('jointY',15);
stepDataManager.addDataEntry('jointZ',15);
stepDataManager.addDataEntry('markerX',36);
stepDataManager.addDataEntry('markerY',36);
stepDataManager.addDataEntry('markerZ',36);
stepDataManager.addDataEntry('markerE',36);
stepDataManager.addDataEntry('subjectVelocity',1);
stepDataManager.addDataEntry('treadmillVelocity',1);

% interestingMarkerIdices = [1:7 10 14 15 19:22 25 26 35 36];
interestingMarkerIdices = 1:36;
% interestingMarkerIdices = 1:18;
stepDataManager.addDataAlias('states',{'markerX','markerY','markerZ'},{interestingMarkerIdices, interestingMarkerIdices, interestingMarkerIdices});
stepDataManager.addDataAlias('observations',{'markerX','markerY','markerZ'},{interestingMarkerIdices, interestingMarkerIdices, interestingMarkerIdices});
for i = 1:15
    stepDataManager.addDataAlias(['joint' num2str(i)],{'jointX','jointY','jointZ'},{i i i});
end
stepDataManager.addDataAlias('targets',{'jointX','jointY','jointZ','markerX','markerY','markerZ','subjectVelocity'});

stepDataManager.addDataEntry('obsPoints',1);

stepDataManager.addDataEntry('filteredJointX',15);
stepDataManager.addDataEntry('filteredJointY',15);
stepDataManager.addDataEntry('filteredJointZ',15);
stepDataManager.addDataEntry('filteredMarkerX',36);
stepDataManager.addDataEntry('filteredMarkerY',36);
stepDataManager.addDataEntry('filteredMarkerZ',36);
stepDataManager.addDataEntry('filteredSubjectVelocity',1);
stepDataManager.addDataAlias('filteredMu',{'filteredJointX' 'filteredJointY' 'filteredJointZ' 'filteredMarkerX' 'filteredMarkerY' 'filteredMarkerZ' 'filteredSubjectVelocity'});
for i = 1:15
    stepDataManager.addDataAlias(['filteredJoint' num2str(i)],{'filteredJointX' 'filteredJointY' 'filteredJointZ'},{i i i});
end

stepDataManager.addDataEntry('smoothedJointX',15);
stepDataManager.addDataEntry('smoothedJointY',15);
stepDataManager.addDataEntry('smoothedJointZ',15);
stepDataManager.addDataEntry('smoothedMarkerX',36);
stepDataManager.addDataEntry('smoothedMarkerY',36);
stepDataManager.addDataEntry('smoothedMarkerZ',36);
stepDataManager.addDataEntry('smoothedSubjectVelocity',1);
stepDataManager.addDataAlias('smoothedMu',{'smoothedJointX' 'smoothedJointY' 'smoothedJointZ' 'smoothedMarkerX' 'smoothedMarkerY' 'smoothedMarkerZ' 'smoothedSubjectVelocity'});
for i = 1:15
    stepDataManager.addDataAlias(['smoothedJoint' num2str(i)],{'smoothedJointX' 'smoothedJointY' 'smoothedJointZ'},{i i i});
end

dataManager.setSubDataManager(stepDataManager);

dataManager.finalizeDataManager();

current_data_pipe = {'states'};

window_size = 4;
obs_ind = 1;
Filter.test.setup.WindowPreprocessor;
num_features = window_size * stepDataManager.getNumDimensions('states');
obs_feature_name = 'observations';
num_obs_features = stepDataManager.getNumDimensions('observations');
output_data_name = {'targets'};
cond_operator_type = 'reg';
refset_learner_type = 'random';
kernel_size = 15000;
red_kernel_size = 2000;
state_bandwidth_factor = 5;
obs_bandwidth_factor = 10;
lambdaO = exp(-12);
lambdaT = exp(-12);
kappa = exp(-10);

state_kernel_type = 'ScaledBandwidthExponentialQuadraticKernel';
obs_kernel_type = 'ScaledBandwidthExponentialQuadraticKernel';

Smoother.test.setup.GkkfLearner;

gkkfLearner.addDataPreprocessor(windowsPrepro);
% gkkfLearner.filter.outputTransformationFunction = 'mapOutputTransformation';

dataManager.finalizeDataManager();

% create and fill data object
disp('creating data object.');
data = dataManager.getDataObject([length([subjects.motions]),0]);

i = 0;
for si = 1:length(subjects)
    for mi = 1:length(subjects(si).motions)
        i = i + 1;
        data.reserveStorage(subjects(si).motions(mi).motion.frames,i);
        data.setDataEntry('subject',subjects(si).subject_name,i);
        data.setDataEntry('frameRate',subjects(si).motions(mi).motion.frameRate,i);
        data.setDataEntry('frames',subjects(si).motions(mi).motion.frames,i);
        data.setDataEntry('jointX',subjects(si).motions(mi).motion.jointX',i);
        data.setDataEntry('jointY',subjects(si).motions(mi).motion.jointY',i);
        data.setDataEntry('jointZ',subjects(si).motions(mi).motion.jointZ',i);
        data.setDataEntry('markerX',subjects(si).motions(mi).motion.markerX',i);
        data.setDataEntry('markerY',subjects(si).motions(mi).motion.markerY',i);
        data.setDataEntry('markerZ',subjects(si).motions(mi).motion.markerZ',i);
        data.setDataEntry('markerE',subjects(si).motions(mi).motion.markerE',i);
        data.setDataEntry('subjectVelocity',subjects(si).motions(mi).motion.subjectVelocity',i);
        data.setDataEntry('treadmillVelocity',subjects(si).motions(mi).force.treadmillVelocity,i);
    end
end
obsPoints = data.getDataEntry('obsPoints');
obsPoints(:) = 1;
data.setDataEntry('obsPoints',obsPoints);

disp('preprocessing data.')
windowsPrepro.preprocessData(data);

%%
disp('learning model.');
trainData = data.cloneDataSubSet([1:6]);
% trainData = data.cloneDataSubSet([1:6 8:13]);
gkkfLearner.updateModel(trainData);

% change initial distribution
valid = logical(trainData.getDataEntry('statesWindowsValid',1));
validIdx = 1:trainData.getNumElementsForIndex(2,1);
validIdx = validIdx(valid);
gkkfLearner.transitionModelLearner.callDataFunction('learnInitialValues',trainData,:,validIdx);

%%

range = 1:2241;
% range = 1000:1050;

% data.setDataEntry('obsPoints',1,[7],range((end/2+1):end));

disp('filtering data.');
gkkfLearner.filter.callDataFunction('filterData',data,[7],range);
% disp('smoothing data.');
% gkkfLearner.filter.callDataFunction('smoothData',data,[7],range);

%%
s_i = 1;
m_i = 7;

markerX = data.getDataEntry('markerX',s_i * m_i,range)';
markerY = data.getDataEntry('markerY',s_i * m_i,range)';
markerZ = data.getDataEntry('markerZ',s_i * m_i,range)';
jointX = data.getDataEntry('jointX',s_i * m_i,range)';
jointY = data.getDataEntry('jointY',s_i * m_i,range)';
jointZ = data.getDataEntry('jointZ',s_i * m_i,range)';

fltrdJointX = data.getDataEntry('filteredJointX',s_i * m_i,range)';
fltrdJointY = data.getDataEntry('filteredJointY',s_i * m_i,range)';
fltrdJointZ = data.getDataEntry('filteredJointZ',s_i * m_i,range)';
fltrdMarkerX = data.getDataEntry('filteredMarkerX',s_i * m_i,range)';
fltrdMarkerY = data.getDataEntry('filteredMarkerY',s_i * m_i,range)';
fltrdMarkerZ = data.getDataEntry('filteredMarkerZ',s_i * m_i,range)';

% smthdJointX = data.getDataEntry('smoothedJointX',s_i * m_i,range)';
% smthdJointY = data.getDataEntry('smoothedJointY',s_i * m_i,range)';
% smthdJointZ = data.getDataEntry('smoothedJointZ',s_i * m_i,range)';

% Setup figure
visualization = figure('Name', 'Motion', 'NumberTitle', 'off', 'Color', 'white', 'Position', [0, 0, 600, 450]);
axis equal;
axis off;
hold on;
view(-240, 20);

% Setup video
videoWriter = VideoWriter('filteredTransitionMotion2.avi');
videoWriter.FrameRate = 20;
videoWriter.Quality = 100;
open(videoWriter);

groundXLimits = [-1000, 1000];
groundZLimits = [-1000, 1000];

% Plot ground plane
[groundX, groundZ] = meshgrid(groundXLimits, groundZLimits);
groundY = zeros(2);
Filter.test.humod.patch3d(groundX([1, 2, 4, 3]), groundY([1, 2, 4, 3]), groundZ([1, 2, 4, 3]), 'k');
alpha(0.1);

% Plot dummy data and set axis limit mode to manual
markers = Filter.test.humod.plot3d(markerX(:, 1), markerY(:, 1), markerZ(:, 1), 'r.');
axis tight;
axis manual;
delete(markers);

for currentFrame = range-range(1)+1
    currentFrame2 = range(currentFrame);
% currentFrame2=1;
% for m_i = 1:6

    % Plot information text
%     information = text(0, 0, 0, sprintf('Time %.2f s', (currentFrame / motion.frameRate)), 'Units', 'normalized');

    gtH = Filter.test.humod.visualizeHuman(...
        subjects(s_i).motions(m_i).motion.jointX(:,currentFrame2), ...
        subjects(s_i).motions(m_i).motion.jointY(:,currentFrame2), ...
        subjects(s_i).motions(m_i).motion.jointZ(:,currentFrame2), ...
        subjects(s_i).motions(m_i).motion.markerX(interestingMarkerIdices,currentFrame2), ...
        subjects(s_i).motions(m_i).motion.markerY(interestingMarkerIdices,currentFrame2), ...
        subjects(s_i).motions(m_i).motion.markerZ(interestingMarkerIdices,currentFrame2), ...
        'b+', 'k*', 'k');
    
    
    ftH = Filter.test.humod.visualizeHuman(...
        fltrdJointX(:,currentFrame), ...
        fltrdJointY(:,currentFrame), ...
        fltrdJointZ(:,currentFrame), ...
        fltrdMarkerX(:,currentFrame), ...
        fltrdMarkerY(:,currentFrame), ...
        fltrdMarkerZ(:,currentFrame), ...
        'r+', 'r*', 'r');
    
%     smH = Filter.test.humod.visualizeHuman(...
%         smthdJointX(:,currentFrame), ...
%         smthdJointY(:,currentFrame), ...
%         smthdJointZ(:,currentFrame), ...
%         subjects(s_i).motions(m_i).motion.markerX(:,currentFrame2), ...
%         subjects(s_i).motions(m_i).motion.markerY(:,currentFrame2), ...
%         subjects(s_i).motions(m_i).motion.markerZ(:,currentFrame2), ...
%         [], 'm*', 'm');

%     % Plot markers and joints
%     markers = Filter.test.humod.plot3d(markerX(:, currentFrame), markerY(:, currentFrame), markerZ(:, currentFrame), 'r.');
% %     surface = Filter.test.humod.plot3d(motion.surfaceX(:, currentFrame), motion.surfaceY(:, currentFrame), motion.surfaceZ(:, currentFrame), 'g.');
%     joints = Filter.test.humod.plot3d(jointX(:, currentFrame), jointY(:, currentFrame), jointZ(:, currentFrame), 'b*');
%     fltrdJoints = Filter.test.humod.plot3d(fltrdJointX(:, currentFrame), fltrdJointY(:, currentFrame), fltrdJointZ(:, currentFrame), 'g*');
% 
%     % Plot connection lines
%     head = Filter.test.humod.plot3d([subjects(s_i).motions(m_i).motion.jointX(1, currentFrame2), subjects(s_i).motions(m_i).motion.surfaceX(1, currentFrame2), subjects(s_i).motions(m_i).motion.surfaceX(2, currentFrame2), subjects(s_i).motions(m_i).motion.jointX(1, currentFrame2)], [subjects(s_i).motions(m_i).motion.jointY(1, currentFrame2), subjects(s_i).motions(m_i).motion.surfaceY(1, currentFrame2), subjects(s_i).motions(m_i).motion.surfaceY(2, currentFrame2), subjects(s_i).motions(m_i).motion.jointY(1, currentFrame2)], [subjects(s_i).motions(m_i).motion.jointZ(1, currentFrame2), subjects(s_i).motions(m_i).motion.surfaceZ(1, currentFrame2), subjects(s_i).motions(m_i).motion.surfaceZ(2, currentFrame2), subjects(s_i).motions(m_i).motion.jointZ(1, currentFrame2)], 'k');
%     leftArm = Filter.test.humod.plot3d([subjects(s_i).motions(m_i).motion.jointX(1, currentFrame2), subjects(s_i).motions(m_i).motion.jointX(2, currentFrame2), subjects(s_i).motions(m_i).motion.jointX(4, currentFrame2), subjects(s_i).motions(m_i).motion.markerX(8, currentFrame2)], [subjects(s_i).motions(m_i).motion.jointY(1, currentFrame2), subjects(s_i).motions(m_i).motion.jointY(2, currentFrame2), subjects(s_i).motions(m_i).motion.jointY(4, currentFrame2), subjects(s_i).motions(m_i).motion.markerY(8, currentFrame2)], [subjects(s_i).motions(m_i).motion.jointZ(1, currentFrame2), subjects(s_i).motions(m_i).motion.jointZ(2, currentFrame2), subjects(s_i).motions(m_i).motion.jointZ(4, currentFrame2), subjects(s_i).motions(m_i).motion.markerZ(8, currentFrame2)], 'k');
%     rightArm = Filter.test.humod.plot3d([subjects(s_i).motions(m_i).motion.jointX(1, currentFrame2), subjects(s_i).motions(m_i).motion.jointX(3, currentFrame2), subjects(s_i).motions(m_i).motion.jointX(5, currentFrame2), subjects(s_i).motions(m_i).motion.markerX(9, currentFrame2)], [subjects(s_i).motions(m_i).motion.jointY(1, currentFrame2), subjects(s_i).motions(m_i).motion.jointY(3, currentFrame2), subjects(s_i).motions(m_i).motion.jointY(5, currentFrame2), subjects(s_i).motions(m_i).motion.markerY(9, currentFrame2)], [subjects(s_i).motions(m_i).motion.jointZ(1, currentFrame2), subjects(s_i).motions(m_i).motion.jointZ(3, currentFrame2), subjects(s_i).motions(m_i).motion.jointZ(5, currentFrame2), subjects(s_i).motions(m_i).motion.markerZ(9, currentFrame2)], 'k');
%     spinal = Filter.test.humod.plot3d([subjects(s_i).motions(m_i).motion.jointX(m_i, currentFrame2), subjects(s_i).motions(m_i).motion.jointX(6, currentFrame2), subjects(s_i).motions(m_i).motion.jointX(1, currentFrame2)], [subjects(s_i).motions(m_i).motion.jointY(m_i, currentFrame2), subjects(s_i).motions(m_i).motion.jointY(6, currentFrame2), subjects(s_i).motions(m_i).motion.jointY(1, currentFrame2)], [subjects(s_i).motions(m_i).motion.jointZ(m_i, currentFrame2), subjects(s_i).motions(m_i).motion.jointZ(6, currentFrame2), subjects(s_i).motions(m_i).motion.jointZ(1, currentFrame2)], 'k');
%     pelvis = Filter.test.humod.plot3d([subjects(s_i).motions(m_i).motion.jointX(m_i, currentFrame2), subjects(s_i).motions(m_i).motion.jointX(8, currentFrame2), subjects(s_i).motions(m_i).motion.jointX(9, currentFrame2), subjects(s_i).motions(m_i).motion.jointX(m_i, currentFrame2)], [subjects(s_i).motions(m_i).motion.jointY(m_i, currentFrame2), subjects(s_i).motions(m_i).motion.jointY(8, currentFrame2), subjects(s_i).motions(m_i).motion.jointY(9, currentFrame2), subjects(s_i).motions(m_i).motion.jointY(m_i, currentFrame2)], [subjects(s_i).motions(m_i).motion.jointZ(m_i, currentFrame2), subjects(s_i).motions(m_i).motion.jointZ(8, currentFrame2), subjects(s_i).motions(m_i).motion.jointZ(9, currentFrame2), subjects(s_i).motions(m_i).motion.jointZ(m_i, currentFrame2)], 'k');
%     leftLeg = Filter.test.humod.plot3d([subjects(s_i).motions(m_i).motion.jointX(14, currentFrame2), subjects(s_i).motions(m_i).motion.jointX(12, currentFrame2), subjects(s_i).motions(m_i).motion.jointX(10, currentFrame2), subjects(s_i).motions(m_i).motion.jointX(8, currentFrame2)], [subjects(s_i).motions(m_i).motion.jointY(14, currentFrame2), subjects(s_i).motions(m_i).motion.jointY(12, currentFrame2), subjects(s_i).motions(m_i).motion.jointY(10, currentFrame2), subjects(s_i).motions(m_i).motion.jointY(8, currentFrame2)], [subjects(s_i).motions(m_i).motion.jointZ(14, currentFrame2), subjects(s_i).motions(m_i).motion.jointZ(12, currentFrame2), subjects(s_i).motions(m_i).motion.jointZ(10, currentFrame2), subjects(s_i).motions(m_i).motion.jointZ(8, currentFrame2)], 'k');
%     rightLeg = Filter.test.humod.plot3d([subjects(s_i).motions(m_i).motion.jointX(15, currentFrame2), subjects(s_i).motions(m_i).motion.jointX(13, currentFrame2), subjects(s_i).motions(m_i).motion.jointX(11, currentFrame2), subjects(s_i).motions(m_i).motion.jointX(9, currentFrame2)], [subjects(s_i).motions(m_i).motion.jointY(15, currentFrame2), subjects(s_i).motions(m_i).motion.jointY(13, currentFrame2), subjects(s_i).motions(m_i).motion.jointY(11, currentFrame2), subjects(s_i).motions(m_i).motion.jointY(9, currentFrame2)], [subjects(s_i).motions(m_i).motion.jointZ(15, currentFrame2), subjects(s_i).motions(m_i).motion.jointZ(13, currentFrame2), subjects(s_i).motions(m_i).motion.jointZ(11, currentFrame2), subjects(s_i).motions(m_i).motion.jointZ(9, currentFrame2)], 'k');
% 
%     fltrdHead = Filter.test.humod.plot3d([fltrdJointX(1, currentFrame), subjects(s_i).motions(m_i).motion.surfaceX(1, currentFrame2), subjects(s_i).motions(m_i).motion.surfaceX(2, currentFrame2), fltrdJointX(1, currentFrame)], [fltrdJointY(1, currentFrame), subjects(s_i).motions(m_i).motion.surfaceY(1, currentFrame2), subjects(s_i).motions(m_i).motion.surfaceY(2, currentFrame2), fltrdJointY(1, currentFrame)], [fltrdJointZ(1, currentFrame), subjects(s_i).motions(m_i).motion.surfaceZ(1, currentFrame2), subjects(s_i).motions(m_i).motion.surfaceZ(2, currentFrame2), fltrdJointZ(1, currentFrame)], 'g');
%     fltrdLeftArm = Filter.test.humod.plot3d([fltrdJointX(1, currentFrame), fltrdJointX(2, currentFrame), fltrdJointX(4, currentFrame), subjects(s_i).motions(m_i).motion.markerX(8, currentFrame2)], [fltrdJointY(1, currentFrame), fltrdJointY(2, currentFrame), fltrdJointY(4, currentFrame), subjects(s_i).motions(m_i).motion.markerY(8, currentFrame2)], [fltrdJointZ(1, currentFrame), fltrdJointZ(2, currentFrame), fltrdJointZ(4, currentFrame), subjects(s_i).motions(m_i).motion.markerZ(8, currentFrame2)], 'g');
%     fltrdRightArm = Filter.test.humod.plot3d([fltrdJointX(1, currentFrame), fltrdJointX(3, currentFrame), fltrdJointX(5, currentFrame), subjects(s_i).motions(m_i).motion.markerX(9, currentFrame2)], [fltrdJointY(1, currentFrame), fltrdJointY(3, currentFrame), fltrdJointY(5, currentFrame), subjects(s_i).motions(m_i).motion.markerY(9, currentFrame2)], [fltrdJointZ(1, currentFrame), fltrdJointZ(3, currentFrame), fltrdJointZ(5, currentFrame), subjects(s_i).motions(m_i).motion.markerZ(9, currentFrame2)], 'g');
%     fltrdSpinal = Filter.test.humod.plot3d([fltrdJointX(m_i, currentFrame), fltrdJointX(6, currentFrame), fltrdJointX(1, currentFrame)], [fltrdJointY(m_i, currentFrame), fltrdJointY(6, currentFrame), fltrdJointY(1, currentFrame)], [fltrdJointZ(m_i, currentFrame), fltrdJointZ(6, currentFrame), fltrdJointZ(1, currentFrame)], 'g');
%     fltrdPelvis = Filter.test.humod.plot3d([fltrdJointX(m_i, currentFrame), fltrdJointX(8, currentFrame), fltrdJointX(9, currentFrame), fltrdJointX(m_i, currentFrame)], [fltrdJointY(m_i, currentFrame), fltrdJointY(8, currentFrame), fltrdJointY(9, currentFrame), fltrdJointY(m_i, currentFrame)], [fltrdJointZ(m_i, currentFrame), fltrdJointZ(8, currentFrame), fltrdJointZ(9, currentFrame), fltrdJointZ(m_i, currentFrame)], 'g');
%     fltrdLeftLeg = Filter.test.humod.plot3d([fltrdJointX(14, currentFrame), fltrdJointX(12, currentFrame), fltrdJointX(10, currentFrame), fltrdJointX(8, currentFrame)], [fltrdJointY(14, currentFrame), fltrdJointY(12, currentFrame), fltrdJointY(10, currentFrame), fltrdJointY(8, currentFrame)], [fltrdJointZ(14, currentFrame), fltrdJointZ(12, currentFrame), fltrdJointZ(10, currentFrame), fltrdJointZ(8, currentFrame)], 'g');
%     fltrdRightLeg = Filter.test.humod.plot3d([fltrdJointX(15, currentFrame), fltrdJointX(13, currentFrame), fltrdJointX(11, currentFrame), fltrdJointX(9, currentFrame)], [fltrdJointY(15, currentFrame), fltrdJointY(13, currentFrame), fltrdJointY(11, currentFrame), fltrdJointY(9, currentFrame)], [fltrdJointZ(15, currentFrame), fltrdJointZ(13, currentFrame), fltrdJointZ(11, currentFrame), fltrdJointZ(9, currentFrame)], 'g');


    % Update figure
    drawnow;
    
    % Save frame
    writeVideo(videoWriter, getframe(visualization));
    
%     pause(.05);
%     pause
%     keyboard

    % Delete visualization
    if currentFrame < range(end)-range(1)+1
% %         delete(information);
% 
%         delete(markers);
% %         delete(surface);
%         delete(joints);
%         
%         delete(head);
%         delete(leftArm);
%         delete(rightArm);
%         delete(spinal);
%         delete(pelvis);
%         delete(leftLeg);
%         delete(rightLeg);
%         
%         delete(fltrdJoints);
%         
%         delete(fltrdHead);
%         delete(fltrdLeftArm);
%         delete(fltrdRightArm);
%         delete(fltrdSpinal);
%         delete(fltrdPelvis);
%         delete(fltrdLeftLeg);
%         delete(fltrdRightLeg);

        delete(gtH);
        delete(ftH);
%         delete(smH);
    end
end


close(videoWriter);
