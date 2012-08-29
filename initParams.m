function params = initParams(dataset,nHalf)
    
    % Folder to save results to
    params.saveFolder = ['dataset_',int2str(dataset), '/'];
    if (~exist(params.saveFolder, 'dir'))
        mkdir(params.saveFolder);
    end
    
    % Max. number of iterations of EM to run when estimating motion
    params.emIter = 30;
    
    % Variance of the Wandering component
    params.VARWANDER = 0.35;
    
    % Motion model parameters. These correspond to V1 and V2 in the CVPR paper.
    % Motion parameters organized as:
    % [y-translation, x-translation, rotation, scaling]
    params.V1 = ([2,2,0.01,0.01]).^2; % slow motion prior
    params.V2 = ([2,2,0.01,0.01]).^2; % accel prior
    
    % Downweighting of W constraints used in the motion estimate update, deltaC.
    % This is epsilon in (12) of the CVPR paper.
    params.wEps = 0.1; 
    
    % Setup WSL appearance model parameters
    params.phiCntrl = getPhiCntrl(nHalf);

    % Setup Freeman pyramid parameters
    params.filterCntrl = getFilterParams();
    
    % Get number of filter orientations, scales, and compute total number of
    % filters in the Freeman pyramid
    params.nOrients = numel(params.filterCntrl.thetaDeg);
    params.nScales =  numel(params.filterCntrl.lambda);
    params.nFilters = params.nOrients*params.nScales;
    
    % Used to check convergence of warp estimation. 
    % Let A_i and A_{i-1} indicate the area of the ellipses inferred at warp
    % estimate iteration i and i-1, and let B_i indicate the area of their
    % intersection. The warp convergence check is:
    % 2*B_i/(A_i + A_{i-1}) > overlapPercent
    params.overlapPercent = 1.00;
    
    
    %%% DO NOT TOUCH THESE UNLESS YOU KNOW WHAT YOU ARE DOING!!!
    % Identity warp; used for convenience
    params.identWarp = [0,0,0,1]';
    
    % Multiplicative weight on prior, representing an equivallent number of
    % owned constraints.
    params.minOwn = 1.0;
    
    % Value used to check if phase coefficients are singular;
    % phase < params.THRESH_NEG indicates singular phase.
    params.THRESH_NEG = -1.0e+15;
    
end

% Based on appearModel.c/newPhaseModelCntrl()

function [cntrl] = getPhiCntrl(nHalf)

    % NOTE: ALL PHASES ARE IN UNITS OF RADIANS, SO NO PIs APPEAR!

    cntrl.sigmaMin = 0.1; % Minimum value of phase std. dev.
    cntrl.sigmaW = 0.35; % Wandering component std. dev.
    cntrl.sigmaL = cntrl.sigmaW/1.5; % Lost component std. dev.
    cntrl.singProbW = 0.08; % Prob of seeing a singularity in W state
    cntrl.singProbS = 0.08; % Prob of seeing a singularity in S state
    cntrl.singProbL = 0.73; %Prob of seeing singularity in L state
    
    % Parameters, and derived parameters, relating to half-life
    cntrl.nHalf = nHalf;
    cntrl.TAUCONST = cntrl.nHalf/log(2);
    cntrl.DECAY = exp(-(1/cntrl.TAUCONST));
    
    % Initial mixing proportions for the 3 appearance components
    cntrl.restartMix = [0.40,0.15,0.45]';
    
    % Restart trigger threshold; if mixing proportion for the stable component
    % falls below this value, the WSL process at that pixel is re-initialized
    cntrl.restartTrigger = 0.10;
    
    % Minimum mixing proportion of any of the W,S,L components, before
    % re-normalization
    cntrl.minMix = 0.05; % Min prob of mixing proportion

    % Probability density to use for the wandering appearance component, if the
    % current phase observation is singular
    cntrl.probUnstableWander = 0.05; 
    
    % Probability density to use for the lost appearance component, assuming
    % that for the outlier process, phase is uniformly distributed in the range
    % [-1, 1) radians.
    cntrl.outPhi = 1/2;
    
    % Used to check if annealing in the warp estimate stage should be turned
    % off. If the weighted-std. dev. of the Stable component in the tracked
    % region falls below this value, the annealing is turned off
    cntrl.annealOff = (cntrl.sigmaMin + cntrl.sigmaW)/2;
end

function cntrl = getFilterParams()
    % Pyramid orientations to use
    cntrl.thetaDeg = [0 45 90 135];
    
    % Pyramid scales to use
    cntrl.lambda = [8,16,32];
    
    % Used during the annealing stage of the warp estimation. These are the
    % initial S variances used for annealing.
    cntrl.initVars = [2,1,0.5].^2;
    
    % Tells the Freeman pyramid code what derived features to return to us. See
    % Freeman code for more information.
    cntrl.storeMap = [1 1 0 0 0 0];  % bits mean: [Grad,Phase,Amp,Filter,Basis,Pyr]

    % Value used to check if the phase estimate at a particular given pixel
    % location is "trustworthy". This assumes that pixel data is scaled to be in
    % range [0,1].
    cntrl.rockBottom = 0.1/256; 
    
    % Never cache
    % optional 0's mean don't cache
    %       order of bits means: [Grad, Phase, Amp, Filter, Basis, Pyr]
%     cachecntrl.cacheFiles = [0 0 0 0 0 0];      
%     cachecntrl.pathNameCache = ['Cache/'];   % choose your own cache dir
%     cachecntrl.rootNameCache = 'thisshouldnotexist';
end