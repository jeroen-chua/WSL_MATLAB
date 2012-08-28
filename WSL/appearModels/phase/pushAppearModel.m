function [app] = pushAppearModel(app, warp, fp, fpPrev,params,pose)
    backWarpFinestScale = invertImageWarp(warp);
    
    appOrig = app;
    % scale translation accordingly for each scale
    backWarpAll = repmat(backWarpFinestScale,[size(app,1),1]);
        
    masker = cell(size(app,1),1);
    for (i=1:size(app,1))
        backWarpAll(i,1:2) = backWarpAll(i,1:2)/fp{i}.downsample;
        backWarpAll(i,5:6) = backWarpAll(i,5:6)/fp{i}.downsample;
        
        poseUse = pose;
        poseUse(1:4) =  poseUse(1:4)/fp{i}.downsample;
        masker{i} = ellipseMask(poseUse,size(app{i}.meanEst));
    end
    
    % Warp appearance model from previous time step to current frame
    app = convectPhaseModel(app, backWarpAll, fpPrev,params,masker);
    
    tic


    % app2 = updatePhaseModel(app,backWarpAll,fp,fpPrev,params,masker);
    app = updatePhaseModelPar(app,backWarpAll,fp,fpPrev,params,masker);


    toc

    % Debugging to check if parallel model update is same as point-wise
    % update
%     for (i=1:size(app,1))
%         b = abs(app{i}.meanEst - app2{i}.meanEst);
%         assert(max(b(:)) < 0.0001);
%         
%         b = abs(app{i}.m2 - app2{i}.m2);
%         assert(max(b(:)) < 0.0001);
%         
%         for (j=1:3)
%             atemp = app{i}.mix(:,:,j); btemp = app2{i}.mix(:,:,j);
% 
%             b = abs(atemp -btemp);
%             assert(max(b(:)) < 0.0001);
%         end
%     end
end

