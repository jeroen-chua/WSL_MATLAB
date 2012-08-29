function [res] = expandCoords(nx,ny)
    [x,y] = meshgrid(1:nx,1:ny);
    res = [x(:),y(:)];
end

