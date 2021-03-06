function main(dataset,nHalf,nFrames)
    startup;
    params = initParams(dataset,nHalf);
    params.dataset = dataset;
    
    [ct,pose,params] = setDataParams(dataset,params);
    if (exist('nFrames','var'))
        params.nFrames = nFrames;
    else
        params.nFrames = -1;
    end
    
    params.imSize = size(getData(params,1));

    save([params.saveFolder, 'paramsFile', '_nHalf', num2str(params.phiCntrl.nHalf)], 'params', '-v7.3');

    frame = 1;
    while(1)        
        display(sprintf('On frame: %d of %d\n',frame,params.nFrames));
        fName = [params.saveFolder,'nHalf', num2str(params.phiCntrl.nHalf),'_frame',int2str(frame)];

        [data,status] = getData(params,frame);
        if (~status)
            display('Done analyzing sequence');
            break;
        end;
        
        fp = getPyramidResponse(params,data);

        if (frame == 1)
            app = newAppearModel(fp, params);
        else
            ct = boneArrayFitFlow(ctPrev,appPrev, pose, fp, fpPrev, params);
            [pose,ct] = convectPose(pose,ct); % take pose, and update
            [app] = pushAppearModel(appPrev, ct', fp, fpPrev, params,pose); 
        end
        
        fpPrev = fp;
        ctPrev = ct;
        appPrev= app;
        
        if (mod(frame,4) == 1)
            save(fName,'app','ct', 'ctPrev','pose','-v7.3');
        else
            save(fName,'ct', 'ctPrev','pose','-v7.3');
        end
        frame = frame+1;
    end

end

