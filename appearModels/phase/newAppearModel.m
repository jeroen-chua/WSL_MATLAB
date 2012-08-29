function [app] = newAppearModel(fp, params)
    nFilters = params.nFilters;
    app = cell(nFilters, 1);
    
    restartMix = reshape(params.phiCntrl.restartMix,[1,1,3]);
    for (i=1:nFilters)
        appearDims = size(fp{i}.phaseMap);
        app{i}.m2 =  (params.phiCntrl.restartMix(2) * params.phiCntrl.sigmaL^2)*ones(appearDims);
        app{i}.meanEst = fp{i}.phaseMap;
        app{i}.mix = bsxfun(@times, ones(appearDims),restartMix);
    end
end

