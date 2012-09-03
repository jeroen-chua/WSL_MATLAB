function convertData(folder)
    frame = 1;
    while(1)
        display(['Frame: ', int2str(frame)]);
        fName = [folder,'/',sprintf('frame_%0.4d.jpg',frame)];
        if(~exist(fName,'file'))
            break;
        end
        x = imread(fName);
        fName = [folder,'/',sprintf('frame_%0.4d.pgm',frame)];
        imwrite(x,fName,'pgm');
        frame = frame+1;
    end    
end