function ct = boneArrayFitFlow(ct, appPrev, pose, fp, fpPrev, params)
    
    poseOrig = pose;
    ct_prevOrig = ct;
    
    % Need to move warp origin??
    
    nScales = params.nScales;
    coarse2fineLambda = sort(params.filterCntrl.lambda,'descend');
    
    fpLambdas = zeros(size(fp,1),1);
    scalings = zeros(size(fp,1),1);
    for (i=1:size(fp,1))
        fpLambdas(i) = fp{i}.lambdas;
        sc = size(fp{i}.phaseMap) ./ params.imSize;
        assert(sc(1) == sc(2));
        scalings(i) = sc(1);
    end
    
    ct_prevAtScale = ct_prevOrig;
    poseAtScale = pose;
    % Coarse to fine warping
    
    scUse = 1;
    coarsestLambda = max(fpLambdas);
    for (iScale=1:nScales)
            
        prevSc = scUse;
        lambda = coarse2fineLambda(iScale);
        
        %if( opt.constFlag & SIC_FLAG ) stuff needed here?
        
        fpIndAtScale = find(fpLambdas==lambda);
        appPrevAtScale = cell(numel(fpIndAtScale),1);
        fpPrevAtScale = cell(numel(fpIndAtScale),1);
        fpAtScale = cell(numel(fpIndAtScale),1);
        
        scUse = scalings(fpIndAtScale(1));
        for (i=1:size(fpIndAtScale,1))
           appPrevAtScale{i} = appPrev{fpIndAtScale(i)};
           fpPrevAtScale{i} = fpPrev{fpIndAtScale(i)};
           fpAtScale{i} = fp{fpIndAtScale(i)};
           assert(scUse == scalings(fpIndAtScale(i)));
        end
        
        poseAtScale(1:4) = (scUse/prevSc)*poseAtScale(1:4);
        ct_prevAtScale(1:2) = (scUse/prevSc)*ct_prevAtScale(1:2);
        ct_prevAtScale(5:6) = (scUse/prevSc)*ct_prevAtScale(5:6);
        
        ct(1:2) = (scUse/prevSc)*ct(1:2);
        ct(5:6) = (scUse/prevSc)*ct(5:6);
        
        % Normalize slow motion and acceleration priors for scale
        V1inv = params.V1;
        V1inv(1:2) = V1inv(1:2)*(scUse^2);
        V1inv = inv(diag(V1inv));
        
        V2inv = params.V2;
        V2inv(1:2) = V2inv(1:2)*(scUse^2);
        V2inv = inv(diag(V2inv));
        
        %initAnnealVar = (coarsestLambda/lambda)*sqrt(varUse);
        initAnnealVar = params.filterCntrl.initVars(params.filterCntrl.lambda == lambda);
        [ct] = fitAtScale(ct,ct_prevAtScale,poseAtScale,appPrevAtScale,fpAtScale,fpPrevAtScale,params,initAnnealVar,V1inv,V2inv);
        
        % Do this to only fit residuals
        
%         ctHist(:,iScale) = ct;
%         
%         [poseAtScale,ct] = convectBoneArrayState(poseAtScale,ct);
%         ct_prevAtScale(1:3) = ct_prevAtScale(1:3) - ct(1:3);
%         ct_prevAtScale(4) = ct_prevAtScale(4) - (1-ct(4));
%         ct_prevAtScale(5:6) = poseAtScale(1:2);
%         ct(1:4) = [0,0,0,1]';
%         ct(5:6) = poseAtScale(1:2);
        
        
    end

    prevSc = scUse;
    scUse = 1;
    % expand to full resolution
    ct(1:2) = (scUse/prevSc)*ct(1:2);
    ct(5:6) = (scUse/prevSc)*ct(5:6);
    ct
    
end