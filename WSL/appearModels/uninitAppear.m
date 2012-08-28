function [app] = uninitAppear(params,sizeUse)
    app.mix = params.THRESH_NEG*ones([sizeUse,3]);
    app.meanEst = params.THRESH_NEG*ones(sizeUse);
    app.m2 = params.THRESH_NEG*ones(sizeUse);
end

