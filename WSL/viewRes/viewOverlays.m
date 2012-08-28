function viewOverlays(folderUse,nHalf,nFrames)
    
    close all;
    stabilizeImSize = [100,100];
    
    load([folderUse, '/paramsFile_nHalf', num2str(nHalf)], 'params');
    [~,poseOrig,params] = setDataParams(params.dataset,params);
    if (exist('nFrames', 'var'))
        params.nFrames = nFrames;
    end
    
    % Keep original pose's aspect ratio
    sizeAxes = [poseOrig(3),poseOrig(4)];
    sizeAxes = sizeAxes.*(stabilizeImSize/2)/max(sizeAxes);    
    poseOrig = [stabilizeImSize/2,sizeAxes,0]';
    maskOrig = ellipseMask(poseOrig,stabilizeImSize);

    data = getData(params,1);

    imSize = size(data);
    
    figure(1);
    figure(2);
    display('press a key')
    pause;
    
    for (frame=1:params.nFrames)
        data = getData(params,frame);
        
        clear app;
        load([params.saveFolder, '/nHalf', num2str(nHalf), '_frame', int2str(frame)],'pose', 'app');
        mask = ellipseMask(pose,imSize);
        
        ctCon = stabilizeWarp(poseOrig,pose);
        ctCon(5:6) = poseOrig(1:2);
        dataCon = zeros(imSize);
        [dataStabilize] = convectMatrix(data,dataCon,(ctCon'));
        dataStabilize = dataStabilize(1:stabilizeImSize(1),1:stabilizeImSize(2),:);

        figure(1);
        subplot(1,3,1), imshow(data);
        subplot(1,3,2), imshow(data.*mask);
        subplot(1,3,3), imshow(dataStabilize.*maskOrig);      
             
        title(['Frame: ', int2str(frame)]);
        pose
        
        if(exist('app','var'))
            figure(2);
            for (i=1:size(app,1));
                subplot(params.nOrients,params.nScales,i); imshow(app{i}.mix);
            end
            title(['Frame: ', int2str(frame)]);
        end
        %pause(0.02);
        pause;
    end
end

