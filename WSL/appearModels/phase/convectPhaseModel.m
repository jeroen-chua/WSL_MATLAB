% Based off of appearModel.c/convectPhaseModel()
%
% Compute the appearance model at the current frame, given
%   - appPrev: the updated appearance model at the previous frame
%   - backWarp: the warp from the current frame to delayed frame
%   - fpPrev: the freeman pyramid at the delayed frame (we use
%     the phase gradients in this pyramid to do interpolation).
%   - params: misc. algorithm parameters
% The resulting appearance model does NOT yet incorporate information
% available from the current frame.  Use updatePhaseModel.
%
function [appPrev] =  convectPhaseModel(appPrev, backWarpAll, fpPrev,params, masker)

    for (i=1:params.nFilters)
        backWarp = backWarpAll(i,:);
       
        omega = 2*pi/fpPrev{i}.lambdas; % Filter tuning
        theta = fpPrev{i}.thetas*pi/180;
        
        %gradPhiMean = (omega/pi)*[sin(theta), cos(theta)]';
        gradPhiMean = (omega/pi)*[cos(theta), sin(theta)]';
        gradPhiMean = reshape(gradPhiMean,[1,1,2]);
        
        sizeUse = size(appPrev{i}.meanEst);
        appNew = uninitAppear(params,sizeUse);
        
        gradMap = cat(3,fpPrev{i}.gradMapY,fpPrev{i}.gradMapX);
        gradMapMask = (fpPrev{i}.gradMapX > -10) & (fpPrev{i}.gradMapY > -10) & (appPrev{i}.meanEst > -10);
        
        for (j=1:3)
            [appNew.mix(:,:,j)] = convectMatrix(appPrev{i}.mix(:,:,j),appNew.mix(:,:,j),backWarp,masker{i});
        end
        [appNew.m2] = convectMatrix(appPrev{i}.m2,appNew.m2,backWarp,masker{i});
        [appNew.meanEst] = convectMatrix(appPrev{i}.meanEst,appNew.meanEst,backWarp,masker{i},[],gradMap,gradMapMask,gradPhiMean);
         
        appNew.meanEst(appNew.meanEst > -10) = wrapPhase(appNew.meanEst(appNew.meanEst > -10));
        
        appPrev{i} = appNew;
    end
end

