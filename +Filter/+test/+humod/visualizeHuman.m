function [ handles ] = visualizeHuman( jointX, jointY, jointZ, markerX, markerY, markerZ, markerLS, jointLS, bodyLS)
%VISUALIZEHUMAN Summary of this function goes here
%   Detailed explanation goes here

    handles = [];
    if not(isempty(markerLS))
        markers = Filter.test.humod.plot3d(markerX(:), markerY(:), markerZ(:), markerLS);
        handles(end+1) = markers;
    end
    joints = Filter.test.humod.plot3d(jointX(:), jointY(:), jointZ(:), jointLS);
    handles(end+1) = joints;

    head = Filter.test.humod.plot3d([jointX(1), markerX(1), markerX(2), jointX(1)], [jointY(1), markerY(1), markerY(2), jointY(1)], [jointZ(1), markerZ(1), markerZ(2), jointZ(1)], bodyLS);
    leftArm = Filter.test.humod.plot3d([jointX(1), jointX(2), jointX(4), markerX(8)], [jointY(1), jointY(2), jointY(4), markerY(8)], [jointZ(1), jointZ(2), jointZ(4), markerZ(8)], bodyLS);
    rightArm = Filter.test.humod.plot3d([jointX(1), jointX(3), jointX(5), markerX(9)], [jointY(1), jointY(3), jointY(5), markerY(9)], [jointZ(1), jointZ(3), jointZ(5), markerZ(9)], bodyLS);
    spinal = Filter.test.humod.plot3d([jointX(7), jointX(6), jointX(1)], [jointY(7), jointY(6), jointY(1)], [jointZ(7), jointZ(6), jointZ(1)], bodyLS);
    pelvis = Filter.test.humod.plot3d([jointX(7), jointX(8), jointX(9), jointX(7)], [jointY(7), jointY(8), jointY(9), jointY(7)], [jointZ(7), jointZ(8), jointZ(9), jointZ(7)], bodyLS);
    leftLeg = Filter.test.humod.plot3d([jointX(14), jointX(12), jointX(10), jointX(8)], [jointY(14), jointY(12), jointY(10), jointY(8)], [jointZ(14), jointZ(12), jointZ(10), jointZ(8)], bodyLS);
    rightLeg = Filter.test.humod.plot3d([jointX(15), jointX(13), jointX(11), jointX(9)], [jointY(15), jointY(13), jointY(11), jointY(9)], [jointZ(15), jointZ(13), jointZ(11), jointZ(9)], bodyLS);

    handles = [handles head leftArm rightArm spinal pelvis leftLeg rightLeg];
end

