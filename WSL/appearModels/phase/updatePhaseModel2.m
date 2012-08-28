% Based off of appearModel.c/convectPhaseModel()
%
% Update the appearance model in the coordinates of the
% current frame, using the data at the current frame.
% Given:
%   - app: the old appearance model convected to the current frame
%   - backWarp: the warp form the current frame to the delayed frame
%   - fp: the freeman pyramid at the current frame
%   - fpPrev: the freeman pyramid at the previous frame

function [app] = updatePhaseModel2(app,backWarpAll,fp,fpPrev,params,masker)
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

%         [~,app2{i},dataOwn] = doUpdatePhaseModel(app{i},phases,prevPhases,params);
%         
%         backWarp = backWarpAll(i,:);
%         
%         [nX,nY] =  size(fpPrev{i}.phaseMap);
%         
%         xCurrAll = floor(expandCoords(nX, nY));
%         xPrevAll = ptSampleImageWarp(xCurrAll,backWarp);
%         ixPrevAll = round(xPrevAll);
%         delta = ixPrevAll - xPrevAll;
%         
%         % Round point to subsampled grid
%         %ixPrev = round(xPrev/subSample);
%         for (j = 1:size(xCurrAll,1))
%             xCurr = xCurrAll(j,:);
%             ixPrev = ixPrevAll(j,:);
%             
%             if(masker{i}(xCurr(1),xCurr(2)) == 0) continue; end;
%             
%             phasePt = params.THRESH_NEG;
% 
%             if (fp{i}.phaseMap(xCurr(1), xCurr(2))>-10)
%                 phasePt = fp{i}.phaseMap(xCurr(1), xCurr(2));
%             end
%       
%             prevPhasePt = params.THRESH_NEG;
%             
%             % If in the image...
%             if (ixPrev(1) >= 1 && ixPrev(1) <= nX && ...
%                 ixPrev(2) >= 1 && ixPrev(2) <= nY)
% 
%                 if (fpPrev{i}.gradMapX(ixPrev(1),ixPrev(2)) > -10 && ...
%                     fpPrev{i}.gradMapY(ixPrev(1),ixPrev(2)) > -10 && ...
%                     fpPrev{i}.phaseMap(ixPrev(1), ixPrev(2)) > -10)
%                     
%                     prevPhasePt = fpPrev{i}.phaseMap(ixPrev(1), ixPrev(2)) + ...
%                                 fpPrev{i}.gradMapY(ixPrev(1),ixPrev(2))*delta(j,1) + ...
%                                 fpPrev{i}.gradMapX(ixPrev(1),ixPrev(2))*delta(j,2);
% 
%                     prevPhasePt = wrapPhase(prevPhasePt);
%                 end
%             end
% 
%             % Got the current and previous phases now
%             [~,app{i}] = updatePhaseModelPt(app{i},[xCurr(1),xCurr(2)],phasePt,prevPhasePt,params, dataOwn, app2{i});
%             
% %             assert(prevPhasePt < -10 | abs(prevPhases(xCurr(1),xCurr(2))-prevPhasePt) < 0.0001);
% %             assert(phasePt < -10 | abs(phases(xCurr(1),xCurr(2))-phasePt) < 0.0001);
%         end
    end
end