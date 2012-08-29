function ct = stabilizeWarp(poseSource, poseDest)
    % Given 2 poses, provides the warp from source to dest
    % pose: [yOrig,xOrig,majorAxis,minorAxis,rotation]
    
    ct(1:2,1) = poseDest(1:2) - poseSource(1:2);
    ct(3) = poseDest(5)-poseSource(5);
    ct(4) = poseDest(3)/poseSource(3);
   
    
end

