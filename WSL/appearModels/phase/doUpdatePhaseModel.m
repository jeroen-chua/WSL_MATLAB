% Update the phase appearance
function [resample,app,dataOwn] = doUpdatePhaseModel(app,phases,prevPhases,masker,params)
    
    reInit = masker & app.mix(:,:,2) < -10;
    app = initPhaseModel(app,phases,reInit,params);
    
    dataLikeAll = zeros([size(phases),3]);
    
    singularPhases = phases < -10;
    dataLikeSing = [params.phiCntrl.singProbW, ...
                    params.phiCntrl.singProbS, ...
                    params.phiCntrl.singProbL]';
    for (i=1:3)
        temp = dataLikeAll(:,:,i);
        temp(singularPhases & ~reInit) = dataLikeSing(i);
        dataLikeAll(:,:,i) = temp;
    end
    
    % NO SINGULAR PHASES, OR RE-INIT POINTS PAST THIS POINT
    [resample,app] = resamplePhasePar(app,masker & ~singularPhases & ~reInit,phases,params);
    
    % Wandering component
    devW = wrapPhaseDiff(phases - prevPhases);
    temp = devW/params.phiCntrl.sigmaW;
    dataLikeW = exp(-temp.^2/2)/(sqrt(2*pi)*params.phiCntrl.sigmaW);
    
    prevPhasesSing = (prevPhases < -10);        
    temp = dataLikeAll(:,:,1);
    temp(~prevPhasesSing & ~singularPhases & ~resample & ~reInit) = dataLikeW(~prevPhasesSing & ~singularPhases & ~resample & ~reInit);
    temp(prevPhasesSing & ~singularPhases & ~resample & ~reInit) =  params.phiCntrl.singProbW;
    dataLikeAll(:,:,1) = temp;
    % Wandering component
    
    % Stable component
    devS = wrapPhaseDiff(phases - app.meanEst);
    sigmaEst = getPhiSigmaEstPar(app,params);
    temp = devS./sigmaEst;
    dataLikeS = exp(-temp.^2/2)./(sqrt(2*pi)*sigmaEst);
    
    meanEstSing = (app.meanEst < -10);  
    temp = dataLikeAll(:,:,2);
    temp(~meanEstSing & ~singularPhases & ~resample & ~reInit) = dataLikeS(~meanEstSing & ~singularPhases & ~resample & ~reInit);
    temp(meanEstSing & ~singularPhases & ~resample & ~reInit) =  params.phiCntrl.singProbS;
    dataLikeAll(:,:,2) = temp;
    % Stable component
    
    % Outlier component
    temp = dataLikeAll(:,:,3);
    temp(~singularPhases & ~resample & ~reInit) = params.phiCntrl.outPhi;
    dataLikeAll(:,:,3) = temp;
    % Outlier component
   
    dataOwn = dataLikeAll.*app.mix;
    dataOwn = bsxfun(@rdivide, dataOwn, sum(dataOwn,3));
    
    tempMoments = filterMoments(app.mix, dataOwn, params.phiCntrl.DECAY);
    for (i=1:3)
        temp = app.mix(:,:,i);
        tempMoments2 = tempMoments(:,:,i);
        temp(masker & ~reInit & ~resample) = tempMoments2(masker & ~reInit & ~resample);
        app.mix(:,:,i) = temp;
    end
    
    % For singular phases: Update the second moment for the stable model,
    % assuming a large variance, such as sigmaWin^2, for the stable
    % component. No need to mask resample.
    % 
    dataOwnS = dataOwn(:,:,2);
    app.m2(masker & singularPhases & ~reInit) = ...
        params.phiCntrl.DECAY*app.m2(masker & singularPhases & ~reInit) + ...
        (1-params.phiCntrl.DECAY)*dataOwnS(masker & singularPhases & ~reInit)*(params.phiCntrl.sigmaW)^2;
    
    app.meanEst(masker & singularPhases & ~reInit) = phases(masker & singularPhases & ~reInit);
    
    % Update the moments and mean for S model
    
    % Mean singular? Only update 2nd moments then
    app.m2(masker & meanEstSing & ~singularPhases & ~resample & ~reInit) = ...
        params.phiCntrl.DECAY*app.m2(masker & meanEstSing & ~singularPhases & ~resample & ~reInit) + ...
        (1-params.phiCntrl.DECAY)*dataOwnS(masker & meanEstSing & ~singularPhases & ~resample & ~reInit)*(params.phiCntrl.sigmaW)^2;

    % Mean not singular? Then update 2nd moment and mean estimate
    app.m2(masker & ~meanEstSing & ~singularPhases & ~resample & ~reInit) = ...
        params.phiCntrl.DECAY*app.m2(masker & ~meanEstSing & ~singularPhases & ~resample & ~reInit) +...
        (1-params.phiCntrl.DECAY)*dataOwnS(masker & ~meanEstSing & ~singularPhases & ~resample & ~reInit).*(devS(masker & ~meanEstSing & ~singularPhases & ~resample & ~reInit).^2);
    
    shift = ((1-params.phiCntrl.DECAY)*dataOwnS.*devS)./app.mix(:,:,2);
    shift = clip(shift,-params.phiCntrl.sigmaW,params.phiCntrl.sigmaW);

    stableMix = app.mix(:,:,2);
    app.m2(masker & ~meanEstSing & ~singularPhases & ~resample & ~reInit) = ...
        app.m2(masker & ~meanEstSing & ~singularPhases & ~resample & ~reInit) - ...
        stableMix(masker & ~meanEstSing & ~singularPhases & ~resample & ~reInit).*shift(masker & ~meanEstSing & ~singularPhases & ~resample & ~reInit).^2;
    
    app.meanEst(masker & ~meanEstSing & ~singularPhases & ~resample & ~reInit) = ...
        wrapPhase(app.meanEst(masker & ~meanEstSing & ~singularPhases & ~resample & ~reInit) + shift(masker & ~meanEstSing & ~singularPhases & ~resample & ~reInit));

    b = app.mix(:,:,1);
    b = isnan(b);
    for (i=1:3)        
        temp = app.mix(:,:,i);
        temp(b) = params.phiCntrl.restartMix(i);
        app.mix(:,:,i) = temp;
    end
        
    tempMixMollify = mollifyMixCoeffsPar(app.mix, params.phiCntrl.minMix);
    for (i=1:3)
        temp = app.mix(:,:,i);
        tempMixMollify2 = tempMixMollify(:,:,i);
        temp(masker & ~reInit & ~resample) = tempMixMollify2(masker & ~reInit & ~resample);
        app.mix(:,:,i) = temp;
    end
    %app.mix = mollifyMixCoeffs2(app.mix, params.phiCntrl.minMix);
    temp = max(app.m2,params.phiCntrl.sigmaMin^2);
    app.m2(~reInit & masker) = temp(~reInit & masker);
end

function mix = filterMoments(mix,dataOwn,decay)    
   mix = decay*mix + (1-decay)*dataOwn;
end