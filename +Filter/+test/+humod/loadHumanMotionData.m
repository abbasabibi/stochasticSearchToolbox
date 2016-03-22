function subjects = loadHumanMotionData(subjects, motions, frameRate)

for si = 1:length(subjects)
    for mi = 1:length(motions)
        motion(mi) = orderfields(load(['data/HuMoD/' subjects{si} '/' motions{mi} '.mat']));
    end
    motion = rmfield(motion,{'events','muscle'});
    forcenames = fieldnames(motion(1).force);
    for i = 1:length(motion)
        motion(i).force = rmfield(motion(i).force,forcenames([1:12 16:end]));
    end
    
    subjects{si} = struct('subject_name',subjects{si},'motions',motion);
    clear motion;
end

subjects = [subjects{:}];

% subsample data
subsampleFrameRate = frameRate;
fprintf('subsampling data with a framerate of %d\n',subsampleFrameRate);
for si = 1:length(subjects)
    for mi = 1:length(subjects(si).motions)
        motionFrameSkip = round(subjects(si).motions(mi).motion.frameRate / subsampleFrameRate);
        forceFrameSkip = round(subjects(si).motions(mi).force.frameRate / subsampleFrameRate);
        motionStartFrame = subjects(si).motions(mi).meta.startTime * subjects(si).motions(mi).motion.frameRate;
        forceStartFrame = subjects(si).motions(mi).meta.startTime * subjects(si).motions(mi).force.frameRate;
        motionEndFrame = subjects(si).motions(mi).meta.endTime * subjects(si).motions(mi).motion.frameRate;
        forceEndFrame = subjects(si).motions(mi).meta.endTime * subjects(si).motions(mi).force.frameRate;

        fnames = fieldnames(subjects(si).motions(mi).motion);
        for fname = fnames'
            F = subjects(si).motions(mi).motion.(fname{1});
            if ismatrix(F) && size(F,2) == subjects(si).motions(mi).motion.frames;
                subjects(si).motions(mi).motion.(fname{1}) = F(:,motionStartFrame:motionFrameSkip:motionEndFrame);
            end
        end

        subjects(si).motions(mi).force.treadmillVelocity = subjects(si).motions(mi).force.treadmillVelocity(forceStartFrame:forceFrameSkip:forceEndFrame);

        subjects(si).motions(mi).motion.frameRate = subsampleFrameRate;
        subjects(si).motions(mi).motion.frames = length(motionStartFrame:motionFrameSkip:motionEndFrame);
        subjects(si).motions(mi).force.frameRate = subsampleFrameRate;
        subjects(si).motions(mi).force.frames = length(forceStartFrame:forceFrameSkip:forceEndFrame);
    end
end

end