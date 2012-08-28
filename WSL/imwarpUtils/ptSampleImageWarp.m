% warp: [dy, dx, dtheta, dscl, originY, originX]
% x is coordinates; N x 2
function [xNew] = ptSampleImageWarp(x, warp)
    assert(size(x,2) == 2);
    assert(size(warp,1) == 1);
    
    dtrans = warp(1:2);
    dangle = warp(3)*pi;
    dscl = warp(4);
    
    ctheta = cos(dangle);
    stheta = sin(dangle);
    warp_origin = warp(5:6);
    
    dx = bsxfun(@minus, x, warp_origin); % Subtract warp origin for centering
    
    
    xNew = zeros(size(x,1),2);
    % coordinates are (y,x), not (x,y), so set rotation matrix accordingly
    xNew(:,1) = warp_origin(1) + dtrans(1) + ...
               dscl*(ctheta*dx(:,1) + stheta*dx(:,2));
    xNew(:,2) = warp_origin(2) + dtrans(2) + ...
               dscl*(-stheta*dx(:,1) + ctheta*dx(:,2));
    
    
%     xNew(:,1) = warp_origin(1) + dtrans(1) + ...
%                dscl*(ctheta*dx(:,1) - stheta*dx(:,2));
%     xNew(:,2) = warp_origin(2) + dtrans(2) + ...
%                dscl*(stheta*dx(:,1) + ctheta*dx(:,2));
end

