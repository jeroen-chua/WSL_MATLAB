function [appPt] = initPhaseModelPt(phase,params)
    appPt.mix = params.phiCntrl.restartMix;
    appPt.meanEst = phase;
    appPt.m2 = params.phiCntrl.restartMix(2) * params.phiCntrl.sigmaL^2;
end

