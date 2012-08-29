function [pose,ct] = convectPose(pose,ct)
    % pose: [centreY,centreX,majorAxis,minorAxis,rotation]
    % ct: [deltaY,deltaX,deltaRot,deltaScale,centreY,centreX]
    
    pose(1:2) = ptSampleImageWarp(pose(1:2)',ct')';
    pose(3:4) = pose(3:4)*ct(4);
    pose(5) = wrapPhase(pose(5) + ct(3));
    
    ct = moveImageWarpOrigin(ct',pose(1:2)')';
end