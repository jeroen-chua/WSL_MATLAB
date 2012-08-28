function [data] = getData(params,frame)
    data = imread([params.dataFolder,sprintf('frame_%0.4d.jpg',frame)]);
    if (size(data,3) > 1)
        data = rgb2gray(double(data)/256);
    end
end