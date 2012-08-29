% Based off of appearModel.c/convectPhaseModel()
%
% Update the appearance model in the coordinates of the
% current frame, using the data at the current frame.
% Given:
%   - app: the old appearance model convected to the current frame
%   - backWarp: the warp form the current frame to the delayed frame
%   - fp: the freeman pyramid at the current frame
%   - fpPrev: the freeman pyramid at the previous frame

function [app] = updatePhaseModelPar(app,backWarpAll,fp,fpPrev,params,masker)
    for (i=1:params.nFilters)
        backWarp = backWarpAll(i,:);
        
        phases = fp{i}.phaseMap;
        
        % Debugging
        phases(phases<-10) = params.THRESH_NEG;
        
        prevPhases = params.THRESH_NEG* ones(size(phases));
        prevPhases = convectMatrix(fpPrev{i}.phaseMap,prevPhases,backWarp);
        
        gradMapX = params.THRESH_NEG*ones(size(fpPrev{i}.gradMapX));
        gradMapX = convectMatrix(fpPrev{i}.gradMapX,gradMapX,backWarp);
        
        gradMapY =  params.THRESH_NEG*ones(size(fpPrev{i}.gradMapX));
        [gradMapY, deltaY,deltaX] = convectMatrix(fpPrev{i}.gradMapY,gradMapY,backWarp);
        
        % Mask out phases where undefined
        validMask = (gradMapX > -10) & ...
                    (gradMapY > -10) & ...
                    (prevPhases > -10) & ...
                    (masker{i});
        
        prevPhases = prevPhases + gradMapX.*deltaX + gradMapY.*deltaY;
        prevPhases = wrapPhase(prevPhases);
        prevPhases = prevPhases.*validMask + params.THRESH_NEG.*(1-validMask);

        [~,app{i}] = doUpdatePhaseModel(app{i},phases,prevPhases,masker{i},params);

    end
end