% based on appearModel.c/newPhaseModelChannel()
function [app] = initAppearModel(params, filtSize)
    nComps = size(params.restartMix,1);
    
    app.mix = bsxfun(@times, ones([filtSize, nComps]), ...
                 reshape(params.restartMix, [1,1,nComps]));
	app.meanEst = zeros(filtSize);
    app.m2 = (app.mix(2) * params.sigmaL^2) * ones(filtSize);
end

