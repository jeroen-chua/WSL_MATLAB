function [res] = moveImageWarpOrigin(a,newOrig)
% a: dx, dy, dtheta, dscl, warp_originX, warp_originY
    res = a;
    res(5:6) = newOrig;
    dx = ptSampleImageWarp(newOrig,a);
    res(1:2) = dx - res(5:6);
end

