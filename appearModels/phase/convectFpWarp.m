function [fpUse] = convectFpWarp(fp,ct,params)
    nAppear = size(fp,1);
    fpUse = cell(nAppear,1);
    
    for (j=1:nAppear)
        [ny,nx] = size(fp{j}.phaseMap);
        fpUse{j}.phaseMap = params.THRESH_NEG*ones([ny,nx]);
        fpUse{j}.gradMapX = params.THRESH_NEG*ones([ny,nx]);
        fpUse{j}.gradMapY = params.THRESH_NEG*ones([ny,nx]);
        
        [fpUse{j}.gradMapX] = convectMatrix(fp{j}.gradMapX,fpUse{j}.gradMapX,ct');
        [fpUse{j}.gradMapY] = convectMatrix(fp{j}.gradMapY,fpUse{j}.gradMapY,ct');
        
        gradMap = cat(3,fp{j}.gradMapY,fp{j}.gradMapX);
        gradMapMask = (fp{j}.gradMapX > -10) & (fp{j}.phaseMap > -10);
        
        [fpUse{j}.phaseMap] = convectMatrix(fp{j}.phaseMap,...
                                            fpUse{j}.phaseMap, ...
                                            ct',[],gradMapMask,gradMap,gradMapMask);

        fpUse{j}.phaseMap(fpUse{j}.phaseMap > -10) = wrapPhase(fpUse{j}.phaseMap(fpUse{j}.phaseMap > -10));
    end
end

