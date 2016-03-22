disp('loading data.');
subjects = Filter.test.humod.loadHumanMotionData({'A'},{'1.1','1.2','1.3','2.1','2.2','2.3','4'},20);

% create data manager
disp('creating data manager.');
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

% disp('creating data object.');
% data = dataManager.getDataObject([length([subjects.motions]),0]);
% 
% i = 0;
% for si = 1:length(subjects)
%     for mi = 1:length(subjects(si).motions)
%         i = i + 1;
%         data.reserveStorage(subjects(si).motions(mi).motion.frames,i);
%         data.setDataEntry('subject',subjects(si).subject_name,i);
%         data.setDataEntry('frameRate',subjects(si).motions(mi).motion.frameRate,i);
%         data.setDataEntry('frames',subjects(si).motions(mi).motion.frames,i);
%         data.setDataEntry('jointX',subjects(si).motions(mi).motion.jointX',i);
%         data.setDataEntry('jointY',subjects(si).motions(mi).motion.jointY',i);
%         data.setDataEntry('jointZ',subjects(si).motions(mi).motion.jointZ',i);
%         data.setDataEntry('markerX',subjects(si).motions(mi).motion.markerX',i);
%         data.setDataEntry('markerY',subjects(si).motions(mi).motion.markerY',i);
%         data.setDataEntry('markerZ',subjects(si).motions(mi).motion.markerZ',i);
%         data.setDataEntry('markerE',subjects(si).motions(mi).motion.markerE',i);
%         data.setDataEntry('subjectVelocity',subjects(si).motions(mi).motion.subjectVelocity',i);
%         data.setDataEntry('treadmillVelocity',subjects(si).motions(mi).force.treadmillVelocity,i);
%     end
% end
% 
% % saving data
% trainData = data.cloneDataSubSet(1:6);
% testData = data.cloneDataSubSet(7);
% 
% dataTrainingStruct = trainData.dataStructure;
% dataTestStruct = testData.dataStructure;

disp('creating data object.');
lengthEpisodes = 40;
trainData = dataManager.getDataObject([6*30,0]);

[M, R] = meshgrid(1:6,1:30);
randIdx = randperm(6*30);

i = 0;
si = 1;
for ri = randIdx
    i = i + 1;
    mi = M(ri);
    range = ((R(ri)-1)*lengthEpisodes+1):((R(ri))*lengthEpisodes);
    trainData.reserveStorage(lengthEpisodes,i);
    trainData.setDataEntry('subject',subjects(si).subject_name,i);
    trainData.setDataEntry('frameRate',subjects(si).motions(mi).motion.frameRate,i);
    trainData.setDataEntry('frames',subjects(si).motions(mi).motion.frames,i);
    trainData.setDataEntry('jointX',subjects(si).motions(mi).motion.jointX(:,range)',i);
    trainData.setDataEntry('jointY',subjects(si).motions(mi).motion.jointY(:,range)',i);
    trainData.setDataEntry('jointZ',subjects(si).motions(mi).motion.jointZ(:,range)',i);
    trainData.setDataEntry('markerX',subjects(si).motions(mi).motion.markerX(:,range)',i);
    trainData.setDataEntry('markerY',subjects(si).motions(mi).motion.markerY(:,range)',i);
    trainData.setDataEntry('markerZ',subjects(si).motions(mi).motion.markerZ(:,range)',i);
    trainData.setDataEntry('markerE',subjects(si).motions(mi).motion.markerE(:,range)',i);
    trainData.setDataEntry('subjectVelocity',subjects(si).motions(mi).motion.subjectVelocity(:,range)',i);
    trainData.setDataEntry('treadmillVelocity',subjects(si).motions(mi).force.treadmillVelocity(range),i);
end

% saving data
% trainData = data.cloneDataSubSet(1:6);
testData = dataManager.getDataObject([1,0]);

mi = 7;
i = 1;
testData.reserveStorage(subjects(si).motions(mi).motion.frames,i);
testData.setDataEntry('subject',subjects(si).subject_name,i);
testData.setDataEntry('frameRate',subjects(si).motions(mi).motion.frameRate,i);
testData.setDataEntry('frames',subjects(si).motions(mi).motion.frames,i);
testData.setDataEntry('jointX',subjects(si).motions(mi).motion.jointX',i);
testData.setDataEntry('jointY',subjects(si).motions(mi).motion.jointY',i);
testData.setDataEntry('jointZ',subjects(si).motions(mi).motion.jointZ',i);
testData.setDataEntry('markerX',subjects(si).motions(mi).motion.markerX',i);
testData.setDataEntry('markerY',subjects(si).motions(mi).motion.markerY',i);
testData.setDataEntry('markerZ',subjects(si).motions(mi).motion.markerZ',i);
testData.setDataEntry('markerE',subjects(si).motions(mi).motion.markerE',i);
testData.setDataEntry('subjectVelocity',subjects(si).motions(mi).motion.subjectVelocity',i);
testData.setDataEntry('treadmillVelocity',subjects(si).motions(mi).force.treadmillVelocity,i);

dataTrainingStruct = trainData.dataStructure;
dataTestStruct = testData.dataStructure;


save('data/HuMoD/dataHuMoD.mat', 'dataTrainingStruct', 'dataTestStruct', 'dataManager');

data = trainData;
save('data/HuMoD/dataHuMoD_train_batches.mat', 'data');

data = testData;
save('data/HuMoD/dataHuMoD_test.mat', 'data');