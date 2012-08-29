function [res,deltaY,deltaX] = convectMatrix(source,dest,backWarp, maskDest, maskSource, gradSource, gradSourceMask, gradPhiDefault)
% sourceToDestWarp: similarity transform: deltaY,deltaX,rot,scl,origX,origY
% gradSource should be [nySource,nxSource,2], where channel 1 is
% Y-gradient, channel 2 is X-gradient
% deltaX, deltaY: grid mis-alignment

    [nySource,nxSource] = size(source);
    [nyDest,nxDest] = size(dest);
    if(nargin < 4 || isempty(maskDest)) maskDest = ones(nyDest,nxDest); end;
    if(nargin < 5 || isempty(maskSource)) maskSource = ones(nySource,nxSource); end;
    
    res = dest;
    
    [x,y] = meshgrid(1:nySource',1:nxSource');
    xDest = [x(:),y(:)];
    
    xSourceNoRound = ptSampleImageWarp(xDest,backWarp); %nPoints x 2
    xSource = round(xSourceNoRound);
    delta = xSource - xSourceNoRound;
    
    deltaY = reshape(delta(:,1),[nxSource,nySource])';
    deltaX = reshape(delta(:,2),[nxSource,nySource])';
    
    inSource = (xSource(:,1) >= 1) & (xSource(:,1) <= nySource) & ...
               (xSource(:,2) >= 1) & (xSource(:,2) <= nxSource);
           
    maskDest = maskDest(sub2indNoCheck([nyDest,nxDest],xDest(:,1),xDest(:,2)));
    
    maskSourceAll = zeros(nySource*nxSource,1);
    maskSourceAll(inSource) = maskSource(sub2indNoCheck([nySource,nxSource],xSource(inSource,1),xSource(inSource,2)));
    
    resMask = maskDest & maskSourceAll & inSource;
%     resInds = sub2indNoCheck([nyDest,nxDest],xDest(resMask,1),xDest(resMask,2));
    resInds = xDest(resMask,1) + nyDest*(xDest(resMask,2) - 1);
    gradInds = sub2indNoCheck([nySource,nxSource],xSource(resMask,1),xSource(resMask,2));
    
    % if gradients were provided, use these to fix up interpolations
    if (nargin < 6)
        res(resInds) = source(gradInds);
        return;
    end
    
    if (nargin < 7 || isempty(gradSourceMask))
        gradSourceMask = ones(nySource,nxSource);
    end
    if (nargin < 8 || isempty(gradPhiDefault))
        gradPhiDefault = zeros([1,1,2]);
    end
    gradSource = bsxfun(@times,gradSource,gradSourceMask) + ...
                 bsxfun(@times,gradPhiDefault,1-gradSourceMask);
    
    grads = zeros(nySource,nxSource);
    for (i=1:2)
       grads(gradInds) = grads(gradInds) + ...
           gradSource(gradInds + (i-1)*nySource*nxSource).*delta(resMask,i);
    end
    
    res(resInds) = source(gradInds) + grads(gradInds);
end

