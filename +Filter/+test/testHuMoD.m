close all
Common.clearClasses();
clear variables
clc


% load data
A.dataset(1) = orderfields(load('data/HuMoD/A/1.1.mat'));
A.dataset(2) = orderfields(load('data/HuMoD/A/1.2.mat'));
A.dataset(3) = orderfields(load('data/HuMoD/A/1.3.mat'));
A.dataset(4) = orderfields(load('data/HuMoD/A/2.1.mat'));
A.dataset(5) = orderfields(load('data/HuMoD/A/2.2.mat'));
A.dataset(6) = orderfields(load('data/HuMoD/A/2.3.mat'));
A.dataset(7) = orderfields(load('data/HuMoD/A/4.mat'));
A.dataset = rmfield(A.dataset,{'events','muscle','ground'});

numEpisodes = length(A.dataset);

forcenames = fieldnames(A.dataset(1).force);
for i = 1:length(A.dataset)
    A.dataset(i).force = rmfield(A.dataset(i).force,forcenames([1:12 16:end]));
end

% subsample data
subsampleFrameRate = 20;
for i = 1:length(A.dataset)
    
    motionFrameSkip = A.dataset(i).motion.frameRate / subsampleFrameRate;
    forceFrameSkip = A.dataset(i).force.frameRate / subsampleFrameRate;
    motionStartFrame = A.dataset(i).meta.startTime * A.dataset(i).motion.frameRate;
    forceStartFrame = A.dataset(i).meta.startTime * A.dataset(i).force.frameRate;
    motionEndFrame = A.dataset(i).meta.endTime * A.dataset(i).motion.frameRate;
    forceEndFrame = A.dataset(i).meta.endTime * A.dataset(i).force.frameRate;
    
    fnames = fieldnames(A.dataset(i).motion);
    for fname = fnames'
        F = A.dataset(i).motion.(fname{1});
        if ismatrix(F) && size(F,2) == A.dataset(i).motion.frames;
            A.dataset(i).motion.(fname{1}) = F(:,motionStartFrame:motionFrameSkip:motionEndFrame);
        end
    end
    
    A.dataset(i).force.treadmillVelocity = A.dataset(i).force.treadmillVelocity(forceStartFrame:forceFrameSkip:forceEndFrame);
    
    A.dataset(i).motion.frameRate = subsampleFrameRate;
    A.dataset(i).motion.frames = length(motionStartFrame:motionFrameSkip:motionEndFrame);
    A.dataset(i).force.frameRate = subsampleFrameRate;
    A.dataset(i).force.frames = length(forceStartFrame:forceFrameSkip:forceEndFrame);
end

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

interestingMarkerIdices = [4:10 14 15 19:22 25 26 35 36];
stepDataManager.addDataAlias('states',{'markerX','markerY','markerZ','treadmillVelocity'},{interestingMarkerIdices, interestingMarkerIdices, interestingMarkerIdices, 1});
stepDataManager.addDataAlias('observations',{'markerX','markerY','markerZ','treadmillVelocity'},{interestingMarkerIdices, interestingMarkerIdices, interestingMarkerIdices, 1});
for i = 1:15
    stepDataManager.addDataAlias(['joint' num2str(i)],{'jointX','jointY','jointZ'},{i i i});
end
stepDataManager.addDataAlias('targets',{'jointX','jointY','jointZ','subjectVelocity'});

stepDataManager.addDataEntry('obsPoints',1);

stepDataManager.addDataEntry('filteredJointX',15);
stepDataManager.addDataEntry('filteredJointY',15);
stepDataManager.addDataEntry('filteredJointZ',15);
stepDataManager.addDataEntry('filteredSubjectVelocity',1);
stepDataManager.addDataAlias('filteredMu',{'filteredJointX' 'filteredJointY' 'filteredJointZ' 'filteredSubjectVelocity'});
for i = 1:15
    stepDataManager.addDataAlias(['filteredJoint' num2str(i)],{'filteredJointX' 'filteredJointY' 'filteredJointZ'},{i i i});
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
kernel_size = 10000;
red_kernel_size = 1000;
state_bandwidth_factor = 20;
obs_bandwidth_factor = 10;
lambdaO = exp(-12);
lambdaT = exp(-12);
kappa = exp(-8);

state_kernel_type = 'ScaledBandwidthExponentialQuadraticKernel';
obs_kernel_type = 'ScaledBandwidthExponentialQuadraticKernel';

Smoother.test.setup.GkkfLearner;

gkkfLearner.addDataPreprocessor(windowsPrepro);


dataManager.finalizeDataManager();

% create and fill data object
dataA = dataManager.getDataObject([numEpisodes,0]);

for i = 1:numEpisodes
    dataA.reserveStorage(A.dataset(i).motion.frames,i);
    dataA.setDataEntry('subject','A',i);
    dataA.setDataEntry('frameRate',A.dataset(i).motion.frameRate,i);
    dataA.setDataEntry('frames',A.dataset(i).motion.frames,i);
    dataA.setDataEntry('jointX',A.dataset(i).motion.jointX',i);
    dataA.setDataEntry('jointY',A.dataset(i).motion.jointY',i);
    dataA.setDataEntry('jointZ',A.dataset(i).motion.jointZ',i);
    dataA.setDataEntry('markerX',A.dataset(i).motion.markerX',i);
    dataA.setDataEntry('markerY',A.dataset(i).motion.markerY',i);
    dataA.setDataEntry('markerZ',A.dataset(i).motion.markerZ',i);
    dataA.setDataEntry('markerE',A.dataset(i).motion.markerE',i);
    dataA.setDataEntry('subjectVelocity',A.dataset(i).motion.subjectVelocity',i);
    dataA.setDataEntry('treadmillVelocity',A.dataset(i).force.treadmillVelocity,i);
end
obsPoints = dataA.getDataEntry('obsPoints');
obsPoints(:) = 1;
dataA.setDataEntry('obsPoints',obsPoints);

windowsPrepro.preprocessData(dataA);

gkkfLearner.updateModel(dataA.cloneDataSubSet(1:6));

%%

range = 500:750;

gkkfLearner.filter.callDataFunction('filterData',dataA,7,range);

%%
markerX = dataA.getDataEntry('markerX',7,range)';
markerY = dataA.getDataEntry('markerY',7,range)';
markerZ = dataA.getDataEntry('markerZ',7,range)';
jointX = dataA.getDataEntry('jointX',7,range)';
jointY = dataA.getDataEntry('jointY',7,range)';
jointZ = dataA.getDataEntry('jointZ',7,range)';

fltrdJointX = dataA.getDataEntry('filteredJointX',7,range)';
fltrdJointY = dataA.getDataEntry('filteredJointY',7,range)';
fltrdJointZ = dataA.getDataEntry('filteredJointZ',7,range)';

% Setup figure
visualization = figure('Name', 'Motion', 'NumberTitle', 'off', 'Color', 'white', 'Position', [0, 0, 600, 450]);
axis equal;
axis off;
hold on;
view(-240, 20);

groundXLimits = [-1000, 1000];
groundZLimits = [-1000, 1000];

% Plot ground plane
% [groundX, groundZ] = meshgrid(groundXLimits, groundZLimits);
% groundY = zeros(2);
% patch3d(groundX([1, 2, 4, 3]), groundY([1, 2, 4, 3]), groundZ([1, 2, 4, 3]), 'k');
% alpha(0.1);

% Plot dummy data and set axis limit mode to manual
markers = plot3d(markerX(:, 1), markerY(:, 1), markerZ(:, 1), 'r.');
axis tight;
axis manual;
delete(markers);

for currentFrame = range-range(1)+1
    currentFrame2 = range(currentFrame);

    % Plot information text
%     information = text(0, 0, 0, sprintf('Time %.2f s', (currentFrame / motion.frameRate)), 'Units', 'normalized');

    % Plot markers and joints
    markers = plot3d(markerX(:, currentFrame), markerY(:, currentFrame), markerZ(:, currentFrame), 'r.');
%     surface = plot3d(motion.surfaceX(:, currentFrame), motion.surfaceY(:, currentFrame), motion.surfaceZ(:, currentFrame), 'g.');
    joints = plot3d(jointX(:, currentFrame), jointY(:, currentFrame), jointZ(:, currentFrame), 'b*');
    fltrdJoints = plot3d(fltrdJointX(:, currentFrame), fltrdJointY(:, currentFrame), fltrdJointZ(:, currentFrame), 'b*');

    % Plot connection lines
    head = plot3d([A.dataset(7).motion.jointX(1, currentFrame2), A.dataset(7).motion.surfaceX(1, currentFrame2), A.dataset(7).motion.surfaceX(2, currentFrame2), A.dataset(7).motion.jointX(1, currentFrame2)], [A.dataset(7).motion.jointY(1, currentFrame2), A.dataset(7).motion.surfaceY(1, currentFrame2), A.dataset(7).motion.surfaceY(2, currentFrame2), A.dataset(7).motion.jointY(1, currentFrame2)], [A.dataset(7).motion.jointZ(1, currentFrame2), A.dataset(7).motion.surfaceZ(1, currentFrame2), A.dataset(7).motion.surfaceZ(2, currentFrame2), A.dataset(7).motion.jointZ(1, currentFrame2)], 'k');
    leftArm = plot3d([A.dataset(7).motion.jointX(1, currentFrame2), A.dataset(7).motion.jointX(2, currentFrame2), A.dataset(7).motion.jointX(4, currentFrame2), A.dataset(7).motion.markerX(8, currentFrame2)], [A.dataset(7).motion.jointY(1, currentFrame2), A.dataset(7).motion.jointY(2, currentFrame2), A.dataset(7).motion.jointY(4, currentFrame2), A.dataset(7).motion.markerY(8, currentFrame2)], [A.dataset(7).motion.jointZ(1, currentFrame2), A.dataset(7).motion.jointZ(2, currentFrame2), A.dataset(7).motion.jointZ(4, currentFrame2), A.dataset(7).motion.markerZ(8, currentFrame2)], 'k');
    rightArm = plot3d([A.dataset(7).motion.jointX(1, currentFrame2), A.dataset(7).motion.jointX(3, currentFrame2), A.dataset(7).motion.jointX(5, currentFrame2), A.dataset(7).motion.markerX(9, currentFrame2)], [A.dataset(7).motion.jointY(1, currentFrame2), A.dataset(7).motion.jointY(3, currentFrame2), A.dataset(7).motion.jointY(5, currentFrame2), A.dataset(7).motion.markerY(9, currentFrame2)], [A.dataset(7).motion.jointZ(1, currentFrame2), A.dataset(7).motion.jointZ(3, currentFrame2), A.dataset(7).motion.jointZ(5, currentFrame2), A.dataset(7).motion.markerZ(9, currentFrame2)], 'k');
    spinal = plot3d([A.dataset(7).motion.jointX(7, currentFrame2), A.dataset(7).motion.jointX(6, currentFrame2), A.dataset(7).motion.jointX(1, currentFrame2)], [A.dataset(7).motion.jointY(7, currentFrame2), A.dataset(7).motion.jointY(6, currentFrame2), A.dataset(7).motion.jointY(1, currentFrame2)], [A.dataset(7).motion.jointZ(7, currentFrame2), A.dataset(7).motion.jointZ(6, currentFrame2), A.dataset(7).motion.jointZ(1, currentFrame2)], 'k');
    pelvis = plot3d([A.dataset(7).motion.jointX(7, currentFrame2), A.dataset(7).motion.jointX(8, currentFrame2), A.dataset(7).motion.jointX(9, currentFrame2), A.dataset(7).motion.jointX(7, currentFrame2)], [A.dataset(7).motion.jointY(7, currentFrame2), A.dataset(7).motion.jointY(8, currentFrame2), A.dataset(7).motion.jointY(9, currentFrame2), A.dataset(7).motion.jointY(7, currentFrame2)], [A.dataset(7).motion.jointZ(7, currentFrame2), A.dataset(7).motion.jointZ(8, currentFrame2), A.dataset(7).motion.jointZ(9, currentFrame2), A.dataset(7).motion.jointZ(7, currentFrame2)], 'k');
    leftLeg = plot3d([A.dataset(7).motion.jointX(14, currentFrame2), A.dataset(7).motion.jointX(12, currentFrame2), A.dataset(7).motion.jointX(10, currentFrame2), A.dataset(7).motion.jointX(8, currentFrame2)], [A.dataset(7).motion.jointY(14, currentFrame2), A.dataset(7).motion.jointY(12, currentFrame2), A.dataset(7).motion.jointY(10, currentFrame2), A.dataset(7).motion.jointY(8, currentFrame2)], [A.dataset(7).motion.jointZ(14, currentFrame2), A.dataset(7).motion.jointZ(12, currentFrame2), A.dataset(7).motion.jointZ(10, currentFrame2), A.dataset(7).motion.jointZ(8, currentFrame2)], 'k');
    rightLeg = plot3d([A.dataset(7).motion.jointX(15, currentFrame2), A.dataset(7).motion.jointX(13, currentFrame2), A.dataset(7).motion.jointX(11, currentFrame2), A.dataset(7).motion.jointX(9, currentFrame2)], [A.dataset(7).motion.jointY(15, currentFrame2), A.dataset(7).motion.jointY(13, currentFrame2), A.dataset(7).motion.jointY(11, currentFrame2), A.dataset(7).motion.jointY(9, currentFrame2)], [A.dataset(7).motion.jointZ(15, currentFrame2), A.dataset(7).motion.jointZ(13, currentFrame2), A.dataset(7).motion.jointZ(11, currentFrame2), A.dataset(7).motion.jointZ(9, currentFrame2)], 'k');

    fltrdHead = plot3d([fltrdJointX(1, currentFrame), A.dataset(7).motion.surfaceX(1, currentFrame2), A.dataset(7).motion.surfaceX(2, currentFrame2), fltrdJointX(1, currentFrame)], [fltrdJointY(1, currentFrame), A.dataset(7).motion.surfaceY(1, currentFrame2), A.dataset(7).motion.surfaceY(2, currentFrame2), fltrdJointY(1, currentFrame)], [fltrdJointZ(1, currentFrame), A.dataset(7).motion.surfaceZ(1, currentFrame2), A.dataset(7).motion.surfaceZ(2, currentFrame2), fltrdJointZ(1, currentFrame)], 'g');
    fltrdLeftArm = plot3d([fltrdJointX(1, currentFrame), fltrdJointX(2, currentFrame), fltrdJointX(4, currentFrame), A.dataset(7).motion.markerX(8, currentFrame2)], [fltrdJointY(1, currentFrame), fltrdJointY(2, currentFrame), fltrdJointY(4, currentFrame), A.dataset(7).motion.markerY(8, currentFrame2)], [fltrdJointZ(1, currentFrame), fltrdJointZ(2, currentFrame), fltrdJointZ(4, currentFrame), A.dataset(7).motion.markerZ(8, currentFrame2)], 'g');
    fltrdRightArm = plot3d([fltrdJointX(1, currentFrame), fltrdJointX(3, currentFrame), fltrdJointX(5, currentFrame), A.dataset(7).motion.markerX(9, currentFrame2)], [fltrdJointY(1, currentFrame), fltrdJointY(3, currentFrame), fltrdJointY(5, currentFrame), A.dataset(7).motion.markerY(9, currentFrame2)], [fltrdJointZ(1, currentFrame), fltrdJointZ(3, currentFrame), fltrdJointZ(5, currentFrame), A.dataset(7).motion.markerZ(9, currentFrame2)], 'g');
    fltrdSpinal = plot3d([fltrdJointX(7, currentFrame), fltrdJointX(6, currentFrame), fltrdJointX(1, currentFrame)], [fltrdJointY(7, currentFrame), fltrdJointY(6, currentFrame), fltrdJointY(1, currentFrame)], [fltrdJointZ(7, currentFrame), fltrdJointZ(6, currentFrame), fltrdJointZ(1, currentFrame)], 'g');
    fltrdPelvis = plot3d([fltrdJointX(7, currentFrame), fltrdJointX(8, currentFrame), fltrdJointX(9, currentFrame), fltrdJointX(7, currentFrame)], [fltrdJointY(7, currentFrame), fltrdJointY(8, currentFrame), fltrdJointY(9, currentFrame), fltrdJointY(7, currentFrame)], [fltrdJointZ(7, currentFrame), fltrdJointZ(8, currentFrame), fltrdJointZ(9, currentFrame), fltrdJointZ(7, currentFrame)], 'g');
    fltrdLeftLeg = plot3d([fltrdJointX(14, currentFrame), fltrdJointX(12, currentFrame), fltrdJointX(10, currentFrame), fltrdJointX(8, currentFrame)], [fltrdJointY(14, currentFrame), fltrdJointY(12, currentFrame), fltrdJointY(10, currentFrame), fltrdJointY(8, currentFrame)], [fltrdJointZ(14, currentFrame), fltrdJointZ(12, currentFrame), fltrdJointZ(10, currentFrame), fltrdJointZ(8, currentFrame)], 'g');
    fltrdRightLeg = plot3d([fltrdJointX(15, currentFrame), fltrdJointX(13, currentFrame), fltrdJointX(11, currentFrame), fltrdJointX(9, currentFrame)], [fltrdJointY(15, currentFrame), fltrdJointY(13, currentFrame), fltrdJointY(11, currentFrame), fltrdJointY(9, currentFrame)], [fltrdJointZ(15, currentFrame), fltrdJointZ(13, currentFrame), fltrdJointZ(11, currentFrame), fltrdJointZ(9, currentFrame)], 'g');


    % Update figure
    drawnow;
    
    pause(.05);

    % Delete visualization
    if currentFrame < range(end)-range(1)+1
%         delete(information);

        delete(markers);
%         delete(surface);
        delete(joints);
        
        delete(head);
        delete(leftArm);
        delete(rightArm);
        delete(spinal);
        delete(pelvis);
        delete(leftLeg);
        delete(rightLeg);
        
        delete(fltrdJoints);
        
        delete(fltrdHead);
        delete(fltrdLeftArm);
        delete(fltrdRightArm);
        delete(fltrdSpinal);
        delete(fltrdPelvis);
        delete(fltrdLeftLeg);
        delete(fltrdRightLeg);
    end
end
