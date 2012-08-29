function [fp] = getPyramidResponse(params, image)
    % nScale x nOrient
    [gradMap, phaseMap] = freemanPyramid(params.filterCntrl, image);
    
    assert(size(phaseMap,1) == params.nScales);
    assert(size(phaseMap,2) == params.nOrients);
    
    gradMapX = gradMap(:,:,1);
    gradMapY = gradMap(:,:,2);
    phaseMap = phaseMap(:);
    
    thetas = params.filterCntrl.thetaDeg;
    thetas = repmat(thetas,[params.nScales,1]);
    thetas = thetas(:);
    
    lambdas = reshape(params.filterCntrl.lambda,[params.nScales,1]);
    lambdas = repmat(lambdas, [1,params.nOrients]);
    lambdas = lambdas(:);
    
    fp.gradMapX = reshape(gradMapX,[numel(gradMapX),1]);
    fp.gradMapY = reshape(gradMapY,[numel(gradMapX),1]);
    fp.phaseMap = phaseMap;
    fp.thetas = thetas;
    fp.lambdas = lambdas;
    
    for (i=1:size(fp.phaseMap,1))
        pmsize = size(fp.phaseMap{i});
        imsize = size(image);
        
        downsample = imsize ./ pmsize;
        assert(downsample(1) == downsample(2));
        
        fp.downsample{i} = downsample(1);
    end
    fp = convertFp(fp);
    % fp.subsample = 1;
    % subsample=1, implicitly. Code in phaseUtil.V4.0.c:resetFreemanPyramidParams sets
    % this to 1
end

function res = convertFp(fp)
    nChans = size(fp.gradMapX,1);
    res=  cell(nChans,1);
    for (i=1:nChans)

        res{i}.gradMapX = fp.gradMapX{i};
        res{i}.gradMapY = fp.gradMapY{i};
        
        res{i}.phaseMap = fp.phaseMap{i};
        res{i}.thetas = fp.thetas(i);
        res{i}.lambdas = fp.lambdas(i);
        res{i}.downsample = fp.downsample{i};
    end
    
end
