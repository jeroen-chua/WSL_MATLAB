% Update the phasePt appearance model at this pixel
function [resample, app] = updatePhaseModelPt(app,pt,phasePt,prevPhasePt,params)
    
    appPt.mix = reshape(app.mix(pt(1),pt(2),:),[3,1]);
    appPt.m2 = app.m2(pt(1),pt(2));
    appPt.meanEst = app.meanEst(pt(1),pt(2));
    
    [resample,appPt] =  doUpdatePhaseModelPt(appPt,phasePt,prevPhasePt,params);
    app.mix(pt(1),pt(2),:) = appPt.mix;
    app.meanEst(pt(1),pt(2)) = appPt.meanEst;
    app.m2(pt(1),pt(2)) = appPt.m2;
end
   
function [resample,appPt] = doUpdatePhaseModelPt(appPt,phasePt,prevPhasePt,params)
    resample = 0;
    redone = 0;
    if (~(appPt.mix(2) > params.THRESH_NEG))
        [appPt] = initPhaseModelPt(phasePt,params);
        redone = 1;
        return;
    else
        if (phasePt < -10) % singular phasePt, phase supposed to be [-1,1]*2*pi
            dataLike = [params.phiCntrl.singProbW, ...
                        params.phiCntrl.singProbS, ...
                        params.phiCntrl.singProbL]';

            dataOwn = dataLike.*appPt.mix;
            dataOwn = dataOwn/sum(dataOwn);

            % Update zeroth moments
            appPt.mix = filterMoments(appPt.mix, dataOwn, params.phiCntrl.DECAY);

            % Update the second moment for the stable model, assuming
            % a large variance such as sigmaWin^2 */
            appPt.m2 = params.phiCntrl.DECAY*appPt.m2 + ...
                       (1-params.phiCntrl.DECAY) * dataOwn(2)*(params.phiCntrl.sigmaW)^2;

            appPt.meanEst = phasePt;

        else % Nonsingular phasePt measurement
            [resample,appPt] = resamplePhase(appPt,phasePt,params);
            if (~resample)

                dataLike = zeros(3,1);

                % Wandering component
                if (prevPhasePt > -10)
                    % phasePt measurements at times t-1 and t are both valid.
                    devW = wrapPhaseDiff(phasePt-prevPhasePt);

                    temp = devW/params.phiCntrl.sigmaW;
                    dataLike(1) = exp(-temp^2/2)/(sqrt(2*pi)*params.phiCntrl.sigmaW);
                else % previous phasePt is singular
                    dataLike(1) = params.phiCntrl.singProbW;
                end

                % Stable component
                if (appPt.meanEst > -10)
                    devS = wrapPhaseDiff(phasePt-appPt.meanEst);
                    sigmaEst = getPhiSigmaEst(appPt,params);
                    temp = devS/sigmaEst;
                    dataLike(2) = exp(-temp^2/2)/(sqrt(2*pi)*sigmaEst);
                else
                    dataLike(2) = params.phiCntrl.singProbS;
                end

                % Compute the likelihood of the outlier model
                dataLike(3) = params.phiCntrl.outPhi;

                dataOwn = dataLike .* appPt.mix;
                dataOwn = dataOwn/sum(dataOwn);

                appPt.mix = filterMoments(appPt.mix, dataOwn, params.phiCntrl.DECAY);

                % Update the moments and mean for S model
                if (~(appPt.meanEst > -10))
                    % If mean is singular, only update 2nd moment
                    appPt.m2 = params.phiCntrl.DECAY*appPt.m2 + ...
                               (1-params.phiCntrl.DECAY)*dataOwn(2)*(params.phiCntrl.sigmaW^2);
                else                        
                    appPt.m2 = params.phiCntrl.DECAY*appPt.m2 +...
                               (1-params.phiCntrl.DECAY)*dataOwn(2)*(devS^2);

                    m1 = (1-params.phiCntrl.DECAY)*dataOwn(2)*devS;
                    shift = m1/appPt.mix(2);
                    shift = clip(shift,-params.phiCntrl.sigmaW,params.phiCntrl.sigmaW);
                    appPt.m2 = appPt.m2 - appPt.mix(2)*shift^2;
                    appPt.meanEst = wrapPhase(appPt.meanEst + shift);
                end
            end
        end

    end
    appPt.m2 = max(appPt.m2,params.phiCntrl.sigmaMin^2);
    appPt.mix = mollifyMixCoeffs(appPt.mix, params.phiCntrl.minMix);
        
    % CHECKS
%     assert(appPt.meanEst < -10 | abs(appPt.meanEst - appRes.meanEst(pt(1),pt(2))) < 0.0001);
%     assert(abs(appPt.m2 - appRes.m2(pt(1),pt(2))) < 0.0001);
%     
%     a = appPt.mix - squeeze(appRes.mix(pt(1),pt(2),:));
%     assert(max(a(:)) < 0.0001);
end

function mix = filterMoments(mix,dataOwn,decay)    
   mix = decay*mix + (1-decay)*dataOwn;
end