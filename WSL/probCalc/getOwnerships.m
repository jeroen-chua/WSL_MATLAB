function [own,ownOK,deltaW,deltaWOK,deltaS] = getOwnerships(appMix, appMeanEst, appM2, VARWANDER, fpUse,fpPrev,params)
    % own: ownership maps
    % ownDefined: mask of where ownerships are valid (include in constraint
    %             equations)

    nAppear = size(appMix,4);
    imSize = size(appMix); imSize = imSize(1:2);
    
    allProbs = params.THRESH_NEG*ones([imSize,3,nAppear]); %W,S,L in channels
    allProbs(:,:,3,:) = params.phiCntrl.outPhi;    

    ownOK = zeros([imSize,nAppear]);
    deltaW = zeros([imSize,nAppear]);
    deltaWOK = zeros([imSize,nAppear]);
    deltaS = zeros([imSize,nAppear]);
    for (i=1:nAppear)
        % get wandering prob
        allProbs(:,:,1,i) = getProb(fpUse{i}.phaseMap,fpPrev{i}.phaseMap,VARWANDER,params.phiCntrl.probUnstableWander);
        
        % get stable prob
        allProbs(:,:,2,i) = getProb(fpUse{i}.phaseMap,appMeanEst(:,:,i),appM2(:,:,i),params.THRESH_NEG);        
        ownOK(:,:,i) = (fpUse{i}.phaseMap > -10) & (appMeanEst(:,:,i) > -10);
        
        deltaS(:,:,i) = fpUse{i}.phaseMap-appMeanEst(:,:,i);
        deltaS(:,:,i) = wrapPhaseDiff(deltaS(:,:,i));
        
        deltaWOK(:,:,i) = fpUse{i}.phaseMap > -10;
        
        temp = fpUse{i}.phaseMap-fpPrev{i}.phaseMap;
        temp(~deltaWOK(:,:,i)) = params.THRESH_NEG;
        deltaW(:,:,i) = wrapPhaseDiff(temp);
    end
    
    own = allProbs.*appMix;
    own = bsxfun(@rdivide,own,sum(own,3));
end

function res = getProb(data,means,vars,meanBadProb)
    sz = size(data);
    res = zeros([numel(data),1]);
        
    data = data(:); means = means(:); vars = vars(:);

    okData = data > -10;
    okMeans = means > -10;
    
    okInds = okData & okMeans;   
    
    if (numel(vars) == 1)
        res(okInds) = normpdf(data(okInds),means(okInds),sqrt(vars));
    else
        res(okInds) = normpdf(data(okInds),means(okInds),sqrt(vars(okInds)));
    end
    
    res(~okMeans) = meanBadProb;
    
    res = reshape(res,sz);
    
end
