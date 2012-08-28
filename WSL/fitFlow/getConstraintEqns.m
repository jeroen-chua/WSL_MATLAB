function [Aw,As,Ap,bw,bs,bp,sigSMLE,sigWMLE] = getConstraintEqns(own,ownOK, deltaS, deltaW, deltaWOK,fpUse,jac,params,pose,vwander,appM2,ct,ctOrig,deltaCt,V1inv,V2inv)
    [ny,nx,~] = size(own);
    nAppear = size(ownOK,3);
    poseMask = ellipseMask(pose,[ny,nx]);
    
    Aw = zeros(4,4);
    As = zeros(4,4);
    bw = zeros(4,1);
    bs = zeros(4,1);
    
    gradMaps = zeros(ny,nx,1,2);
    ownOK = reshape(ownOK,[ny,nx,1,nAppear]);
    
    % set ownMask to contain only those points with a valid ownership
    % model, and has only those points that are in the tracked region
    ownMasked = bsxfun(@times,own,ownOK);
    ownMasked = bsxfun(@times,ownMasked,poseMask); %[ny,nx,3,nAppear]
    
    deltaCt = reshape(deltaCt,[1,1,4]);
    sigSMLE = zeros(nAppear,1);
    sigWMLE = zeros(nAppear,1);
    for (i=1:nAppear)

        gradMaps(:,:,1,1) = fpUse{i}.gradMapY;
        gradMaps(:,:,1,2) = fpUse{i}.gradMapX;
        
        % gradMaps ~ [ny,nx,1,2]
        % jac ~ [ny,nx,4,2]
        jacGradD = sum(bsxfun(@times,jac,gradMaps),4); % [ny,nx,4]
        jacGradDTrans = reshape(jacGradD,[ny,nx,1,4]);
        jacGradDOuter = bsxfun(@times,jacGradD,jacGradDTrans); %[ny,ny,4,4]
        
        
        %update Wandering components
        ownUseW = bsxfun(@times,ownMasked(:,:,1,i),deltaWOK(:,:,i));
        assert(~any(abs(ownUseW(:)) > 10));
        
        ownUseWweighted = ownUseW./vwander(:,:,i);
%         temp = sum(sum(bsxfun(@times,ownUseWweighted,jacGradDOuter),1),2);
        temp = reshape(reshape(ownUseWweighted,[1,nx*ny]) * reshape(jacGradDOuter,[nx*ny,16]),[4,4]);
        Aw = Aw + reshape(temp,[4,4]);
        
        deltaWJacGrad = bsxfun(@times,jacGradD,deltaW(:,:,i));
        temp = sum(sum(bsxfun(@times,ownUseWweighted,deltaWJacGrad),1),2);
        bw = bw - reshape(temp,[4,1]);
        
        %update Stable components
        ownUseS = ownMasked(:,:,2,i);
        assert(~any(abs(ownUseS(:)) > 10));
        
        ownUseWweighted = ownUseS./appM2(:,:,i);
%         temp = sum(sum(bsxfun(@times,ownUseWweighted,jacGradDOuter),1),2);
        temp = reshape(reshape(ownUseWweighted,[1,nx*ny]) * reshape(jacGradDOuter,[nx*ny,16]),[4,4]);
        As = As + reshape(temp,[4,4]);
        
        deltaSJacGrad = bsxfun(@times,jacGradD,deltaS(:,:,i));
%         temp = sum(sum(bsxfun(@times,ownUseWweighted,deltaSJacGrad),1),2);
        temp = reshape(reshape(ownUseWweighted,[1,nx*ny]) * reshape(deltaSJacGrad,[nx*ny,4]),[4,1]);
        bs = bs - reshape(temp,[4,1]);
        
        % Compute MLE estimates
%         jacGradDDeltaCt = sum(bsxfun(@times,jacGradD,deltaCt),3);
        jacGradDDeltaCt = reshape(reshape(jacGradD,[nx*ny,4])*reshape(deltaCt,[4,1]),[ny,nx]);
        
        % These are variances; take sqrt later for std
        sigSMLE(i) = sum(sum(ownUseS.* (deltaS(:,:,i)+jacGradDDeltaCt).^2,1),2) / sum(sum(ownUseS));
        sigWMLE(i) = sum(sum(ownUseW.* (deltaW(:,:,i)+jacGradDDeltaCt).^2,1),2) / sum(sum(ownUseW));
        
        assert(~any(abs(Aw(:)) > 10^9));
        assert(~any(abs(As(:)) > 10^9));
        assert(~any(abs(bw(:)) > 10^9));
        assert(~any(abs(bs(:)) > 10^9));
    end
    sigSMLE = sqrt(sigSMLE);
    sigWMLE = sqrt(sigWMLE);
    
    Ap = V1inv+V2inv;
    bp = -V1inv*(ct(1:4)-params.identWarp) - V2inv*(ct(1:4)-ctOrig(1:4));
    
end