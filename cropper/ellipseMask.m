function [res] = ellipseMask(ellipseLoc,imSize)
    % ellipseLoc: [centreX, centreY, minor, major, angle]
    
    centre = [ellipseLoc(2), ellipseLoc(1)]';
    A2 = ellipseLoc(4)^2;
    B2 = ellipseLoc(3)^2;
    rot = ellipseLoc(5)*pi;
    
    [X, Y] = meshgrid(1:imSize(2), 1:imSize(1));

    xC = X-centre(1);
    yC = Y-centre(2);
    res = B2*(xC*cos(rot) +  yC*sin(rot)).^2 + ...
          A2*(xC*sin(rot) -  yC*cos(rot)).^2 <= A2*B2;
end

