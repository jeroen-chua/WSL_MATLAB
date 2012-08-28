function [app] = initPhaseModel(app,phases,reInit,params)
    
    app.meanEst(reInit) = phases(reInit);
    app.m2(reInit) = params.phiCntrl.restartMix(2) * params.phiCntrl.sigmaL^2;

    for (i=1:3)
        temp = app.mix(:,:,i);
        temp(reInit) = params.phiCntrl.restartMix(i);
        app.mix(:,:,i) = temp;
    end
end

