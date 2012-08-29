function sigmaEst = getPhiSigmaEst2(app,params)
   priorBias = 0.05*(params.phiCntrl.sigmaL)^2;
   
   sigmaEst = sqrt( (app.m2 + priorBias)./(app.mix(:,:,2) + 0.05));
   sigmaEst = max(sigmaEst, params.phiCntrl.sigmaMin).^2;
end