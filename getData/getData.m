function [data,status] = getData(params,frame)

    status = 1;
    fName = [params.dataFolder,sprintf('frame_%0.4d.jpg',frame)];
    % Exit out if image file doesn't exist (done sequence), or IF user has
    % specified an end frame number and we have exceeded it)
    if (~exist(fName,'file') || ...
       ((params.nFrames ~= -1) && frame > params.nFrames))
        status = 0;
        data = 0;
        return;
    end
    
    data =  imread(fName);
    data = double(data)/256;
    if (size(data,3) > 1)
        data = rgb2gray(data);
    end
end