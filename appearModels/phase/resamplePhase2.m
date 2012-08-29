function [resample, app] = resamplePhase2(app,inds,phases,params)
    % based on resampleMethod = 0
    
    stableComp = app.mix(:,:,2);
    % IS IT MEANEST? CHECK ORIGINAL CODE
    resample = false(size(app.meanEst));
    resample(inds) = (app.meanEst(inds) < -10) | (stableComp(inds) < params.phiCntrl.restartTrigger);
    [app] = initPhaseModel(app,phases,resample,params);
    
end