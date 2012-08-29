function [resample, appPt] = resamplePhase(appPt,phase,params)
    % based on resampleMethod = 0
    resample = 0;
    % IS IT MEANEST? CHECK ORIGINAL CODE
    if(( (appPt.meanEst < -10) || (appPt.mix(2) < params.phiCntrl.restartTrigger)))
        resample = 1;
        [appPt] = initPhaseModelPt(phase,params);
    end
end