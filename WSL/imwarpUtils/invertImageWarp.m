function [r] = invertImageWarp(a)
% Given image warp and origin of warp from frame A to B, returns warp and 
% origin of warp from frame B to A warp is: 
%     [ytrans, xtrans, rotation, scaling, yOrigin, xOrigin]

    r(5:6) = ptSampleImageWarp(a(5:6), a);
    r(3) = -a(3);
    r(4) = 1/a(4);
    r(1:2) = a(5:6) - r(5:6);
end

