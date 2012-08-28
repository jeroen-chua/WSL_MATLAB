function [wanderUse,appM2Use] = getAnnealedVars(wanderUse,appM2Use,mix,appPrev,sigWMLE,sigSMLE,params)
    nAppear = size(wanderUse,3);
    % anneal down
    for (i=1:nAppear)
        wanderUse(:,:,i) = min(0.95*sqrt(wanderUse(:,:,i)),sigWMLE(i)).^2;
        
        appM2Use(:,:,i) = min(0.95*sqrt(appM2Use(:,:,i)),sigSMLE(i)).^2;
        appM2Use(:,:,i) = max(appM2Use(:,:,i),appPrev{i}.m2);
        
        clear appTemp;
        appTemp.m2 = appM2Use(:,:,i);
        appTemp.mix = mix(:,:,:,i);
        appM2Use(:,:,i) = getPhiSigmaEst(appTemp,params);
    end
    %wanderUse = max(wanderUse,params.VARWANDER);
end

