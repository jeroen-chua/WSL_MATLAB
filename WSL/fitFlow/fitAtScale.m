function [ct] = fitAtScale(ct,ctOrig,pose,appPrev,fp,fpPrev,params,initAnnealVar,V1inv,V2inv)
    % ct: [xtrans,ytrans,rot,scale,origX,origY]
    
    poseOrig = pose;
    
    nAppear = size(appPrev,1);
    [ny,nx] = size(fp{1}.phaseMap);

    appMix = zeros([size(appPrev{1}.mix),nAppear]);
    appMeanEst = zeros([size(appPrev{1}.meanEst),nAppear]);
    appM2 = zeros([size(appPrev{1}.m2),nAppear]);
    
    for (i=1:size(appPrev,1))
            appMix(:,:,:,i) = appPrev{i}.mix;
            appMeanEst(:,:,i) = appPrev{i}.meanEst;
            appM2(:,:,i) = appPrev{i}.m2;
    end
    wanderUse = initAnnealVar*ones([size(appPrev{1}.m2),nAppear]);
    appM2Use = initAnnealVar*ones([size(appPrev{1}.m2),nAppear]);
    
    % Guess at new pose
    [pose,~] = convectPose(poseOrig,ct);
    ct(5:6) = poseOrig(1:2); % keep origin
    
    deltaCt = zeros(4,1);
    
    doAnnealing = 1;
    for (emIt=1:params.emIter)
        
        oldPose = pose;
        
        display(sprintf('Iteration: %d',emIt));
        [fpUse] = convectFpWarp(fp,ct,params);
        
        jac = getJacobian(ct,ny,nx);  % 4 x 2 x nPoints, in order given by xp
        
        [own,ownOK,deltaW,deltaWOK,deltaS] ...
            = getOwnerships(appMix, ...
                            appMeanEst, ...
                            appM2Use, ...
                            wanderUse, ...
                            fpUse,fpPrev,params);
                                           
        [Aw,As,Ap,bw,bs,bp,sigSMLE,sigWMLE] = getConstraintEqns(own, ...
                                                                ownOK, ...
                                                                deltaS, ...
                                                                deltaW, ...
                                                                deltaWOK, ...
                                                                fpUse, ...
                                                                jac, ...
                                                                params, ...
                                                                pose, ...
                                                                wanderUse, ...
                                                                appM2Use, ...
                                                                ct, ...
                                                                ctOrig, ...
                                                                deltaCt, ...
                                                                V1inv, V2inv);
                     
        deltaCt = solveDeltaCt(Aw,As,Ap,bw,bs,bp,params);
        ct = updateCt(ct,deltaCt);
        [pose,~] = convectPose(poseOrig,ct);
        ct(5:6) = poseOrig(1:2); % keep origin
        %pose
        ct
        %deltaCt
        if (checkConverged(pose,oldPose,[ny,nx],params)) break; end;
        
        % Once annealing is shut off, it's permanently off
        for (i=1:nAppear)
            doAnnealing = (sigSMLE(i) < params.phiCntrl.annealOff) & ...
                          (sigWMLE(i) < params.phiCntrl.annealOff) & ...
                          doAnnealing;
        end
                  
        if (doAnnealing)
            % anneal down             
            [wanderUse,appM2Use] = getAnnealedVars(wanderUse,appM2Use,appMix,appPrev,sigWMLE,sigSMLE,params);
        else
            display(['Annealing is off']);
            wanderUse = params.VARWANDER*ones(size(wanderUse));
            appM2Use = appM2;
        end
        wanderUse = max(wanderUse,params.phiCntrl.sigmaMin.^2);
        appM2Use = max(appM2Use,params.phiCntrl.sigmaMin.^2);
    end
end

function res = checkConverged(pose,oldPose,imSize, params)
    upScale = 3;
    pose(1:4) = pose(1:4)*upScale;
    oldPose(1:4) = oldPose(1:4)*upScale;
    
    mask = ellipseMask(pose,imSize*upScale);
    maskOld = ellipseMask(oldPose,imSize*upScale);
    
    intersect = mask.*maskOld;
    intersect = sum(intersect(:));
    intersect = 2*intersect/(sum(mask(:)) + sum(maskOld(:)));
    
    res = intersect >= params.overlapPercent;
    display(['Overlap percent: ', num2str(intersect)]);
end

function ct = updateCt(ct,deltaCt)
    ct(1:4) = ct(1:4) + deltaCt(1:4);
end

function deltaCt = solveDeltaCt(Aw,As,Ap,bw,bs,bp,params)
    deltaCt = (As+params.wEps*Aw+Ap)\(bs+params.wEps*bw+bp);
end

function jac = getJacobian(ct,ny,nx)
    % ct: deltaY,deltaX,rot,scl,yOrigin,xOrigin

    xp = expandCoords(ny,nx);
    
    jac = zeros(ny,nx,4,2);
    
    origin = ct(5:6);
    scl = ct(4);
    theta = ct(3)*pi;

    jac(:,:,1,1) = 1;
    jac(:,:,2,2) = 1;
    
    xCentred = bsxfun(@minus,xp,origin');
    
    %rotation params
    %rotA = scl*[-sin(theta), -cos(theta); cos(theta), -sin(theta)];
    rotA = scl*[-sin(theta), cos(theta); -cos(theta) -sin(theta)];
    
    rotA = (rotA*xCentred')';
    rotA = reshape(rotA,[nx,ny,1,2]);

    % need to switch back x,y, since expanderCoords swaps row-column raster scan
    % order
    jac(:,:,3,:) = permute(rotA,[2,1,3,4]);
    
    %scale params
    
    %sclA = ([cos(theta), -sin(theta); sin(theta), cos(theta)]*xCentred')';
    sclA = ([cos(theta), sin(theta); -sin(theta), cos(theta)]*xCentred')';
    sclA = reshape(sclA, [nx,ny,1,2]);
    
    % need to switch back x,y, since expanderCoords swaps row-column raster scan
    % order
    jac(:,:,4,:) = permute(sclA,[2,1,3,4]);
end


function jac = getJacobianRaster(ct,ny,nx)
    % ct: deltaY,deltaX,rot,scl,yOrigin,xOrigin
    
    jac = zeros(ny,nx,4,2);
    
    xOrigin = ct(5:6);
    scl = ct(4);
    theta = ct(3)*pi;

    jac(:,:,1,1) = 1;
    jac(:,:,2,2) = 1;

    % coordiantes are (y,x), not (x,y), so use appropriate rotation matrix,
    % and ordering of partial derivatives in jacobian
    
    rotA = scl*[-sin(theta), cos(theta); -cos(theta) -sin(theta)];
    sclA = [cos(theta), sin(theta); -sin(theta), cos(theta)];
    
    %rotA = scl*[-sin(theta), -cos(theta); cos(theta) -sin(theta)];
    %sclA = [cos(theta), -sin(theta); sin(theta), cos(theta)];
    
    for (i=1:ny)
        for (j=1:nx)
            
            centred = [i-xOrigin(1),j-xOrigin(2)];
             
            %rotation params
            
            rotUse = (rotA*centred')';
            
            jac(i,j,3,:) = rotUse;

            %scale params
            sclUse = (sclA*centred')';

            jac(i,j,4,:) = sclUse;
        end
    end
end