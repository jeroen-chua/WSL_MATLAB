% The input arguments are CNTRL, which is a matlab structure that 
% is analgous to the FreemanPyramidCntrlStruct in C, and IMAGE,
% which is the image to be filtered.  Depending on the CNTRL
% structure (i.e., on the value of the storeMap field), the
% function returns between 0 and 6 cell arrays containing the
% results of the filtering.
%
% To use the function, you first build a CNTRL structure, and
% then pass the structure and the IMAGE to the freemanPyramid
% function.  All of the fields in the CNTRL structure are
% optional.  If a field is omitted, then the value of that field will
% be taken from the default FreemanPyramidCntrlStruct created
% by the C code (i.e., the fields in CNTRL, if specified,
% override those in the default control structure in the C code).
%
%

% cd('c:/Users/fleet/matlab');
cd('/u/fleet/matlab');
startup

%%%%%
BIGNEG = -99999996802856924650656260769173209088.000000;

% datadir = '/w/30/fleet/Data/images/';
% filtdir = '/h/54/fleet/matlab/filtering/';

datadir = '/u/fleet/Data/images/';
filtdir = '/u/fleet/matlab/filtering/';

image = pgmRead([datadir, 'einstein.pgm']);
displayImage(image);



% 1) Lets look at filter responses to different orientations and scales
cntrl.thetaDeg = [0 45 90 135];
cntrl.lambda = [4 8 16 32];
cntrl.storeMap = [0 0 0 1 0 0];  % bits mean: [Grad,Phase,Amp,Filter,Basis,Pyr]

% optional 0's mean don't cache
%       order of bits means: [Grad, Phase, Amp, Filter, Basis, Pyr]
cachecntrl.cacheFiles = [0 0 0 0 1 0];      
cachecntrl.pathNameCache = [filtdir, 'Cache/'];   % choose your own cache dir
cachecntrl.rootNameCache = 'ein';

[filterOutputs] = freemanPyramid( cntrl, image, cachecntrl );

for s = 1:length(cntrl.lambda)  % for all scales
  for w = 1:length(cntrl.thetaDeg)  % for all orientations
    disp(['scale ', num2str(cntrl.lambda(s)), ...
          '   orientation ', num2str(cntrl.thetaDeg(w))]);
    G2 = filterOutputs{s, w, 1};
    H2 = filterOutputs{s, w, 2};
    figure(1);
    displayImage(G2 + i*H2);    
    disp('hit return to continue.');
    pause;
  end
end



% 2) Lets look at phase and amplitude responses at different scales and
% orientations
cntrl.thetaDeg = [0 45 90 135];
cntrl.lambda = [4 8 16 32];
cntrl.storeMap = [1 1 1 0 0 0];  % bits mean: [Grad,Phase,Amp,Filter,Basis,Pyr]

% optional 0's mean don't cache
%       order of bits means: [Grad, Phase, Amp, Filter, Basis, Pyr]
cachecntrl.cacheFiles = [0 0 0 0 1 0];      
cachecntrl.pathNameCache = [filtdir, 'Cache/'];   % choose your own cache dir
cachecntrl.rootNameCache = 'ein';

[gradMap, phaseMap, ampMap] = freemanPyramid( cntrl, image, cachecntrl );

for s = 1:length(cntrl.lambda)  % for all scales
  for w = 1:length(cntrl.thetaDeg)  % for all orientations
    disp(['scale ', num2str(cntrl.lambda(s)), ...
          '   orientation ', num2str(cntrl.thetaDeg(w))]);
    imR = gradMap{s, w, 1};
    imI = gradMap{s, w, 2};
    bad = (imR > BIGNEG);
    figure(1);
    displayImage(bad .* imR  + i * bad .* imI);
    
    im = phaseMap{s, w};
    figure(2);
    imshow(bad .* im);
    
    im = ampMap{s, w};
    figure(3);
    displayImage(bad .* im);
    disp('hit return to continue.');
    pause;
  end
end


% 3) Lets look at the basis function responses at 4 different scales
cntrl.thetaDeg = [0 45 90 135];
cntrl.lambda = [4 8 16 32];
cntrl.storeMap = [0 0 0 0 1 0];  % bits mean: [Grad,Phase,Amp,Filter,Basis,Pyr]

% optional 0's mean don't cache
%       order of bits means: [Grad, Phase, Amp, Filter, Basis, Pyr]
cachecntrl.cacheFiles = [0 0 0 0 1 0];      
cachecntrl.pathNameCache = [filtdir, 'Cache/'];   % choose your own cache dir
cachecntrl.rootNameCache = 'ein';

[basisOutputs] = freemanPyramid( cntrl, image, cachecntrl );

for s = 1:length(cntrl.lambda)  % for all scales
  for b = 1:size(basisOutputs,2)  % for all 7 basis functions
    disp(['scale ', num2str(cntrl.lambda(s)), '  basis function ', num2str(b)]);
    % order of the basis functions is the first 3 images are the 
    % basis function responses for G2, and the last four at each scale
    % are for H2
    bResp = basisOutputs{s, b};

    figure(1);
    displayImage(bResp);    
    disp('hit return to continue.');
    pause;
  end
end


% 4) Let's see how well the harmonic formula for power as a function 
%    of orientation actually predicts the steered response amplitude (squared) 
cntrl.thetaDeg = [0];
cntrl.lambda = [8];
cntrl.storeMap = [0 0 0 0 1 0];  % bits mean: [Grad,Phase,Amp,Filter,Basis,Pyr]

% optional 0's mean don't cache
%       order of bits means: [Grad, Phase, Amp, Filter, Basis, Pyr]
cachecntrl.cacheFiles = [0 0 0 0 1 0];      
cachecntrl.pathNameCache = [filtdir, 'Cache/'];   % choose your own cache dir
cachecntrl.rootNameCache = 'ein';

basisOutputs = freemanPyramid( cntrl, image, cachecntrl );
Cmaps = getCmaps(basisOutputs);

for a=0:10:170 
   cntrl.thetaDeg = [a];
   cntrl.storeMap = [1 1 1 0 0 0];
   [gradMap, phaseMap, ampMap] = freemanPyramid(cntrl, image, cachecntrl);
   imR = gradMap{1, 1, 1};
   bad = (imR > BIGNEG);
   
   amplA = ampMap{1};
   figure(1);
   displayImage(amplA .* bad);
   imStats(amplA .* bad)
   
   amplB = steerAmpl(Cmaps, a);
   figure(2);
   displayImage(amplB .* bad);
   imStats(amplB .* bad)
   
   figure(3);
   displayImage(bad.*amplA + i* bad.*amplB);
   
   diffA = bad.*amplA - bad.*amplB;
   imStats(diffA)
    disp('hit return to continue.');
   pause;
end

%%%%%%%%%%%%%%%%%%%%%%%
%%% Other old temp code
%%%%%%%%%%%%%%%%%%%%%%%
s = 1;
w = 2;
imR = gradMap{s, w, 1};
imI = gradMap{s, w, 2};
bad = (imR > -99999996802856924650656260769173209088.000000);
figure(1);
displayImage(bad .* imR  + i * bad .* imI)
    
im = phaseMap{s, w};
figure(2);
displayImage(bad .* im)
    
im = ampMap{s, w};
figure(3);
displayImage(bad .* im)
pause(2)

%%%%%%%%%%%%%%%%%%%%%%%
root  = '/tilde/fleet/Jepson/filtering/results/';
imR = pfmRead([root,'Gx_einstein.t045.w08.pfm']);
imI = pfmRead([root,'Gy_einstein.t045.w08.pfm']);
bad = (imR > -99999996802856924650656260769173209088.000000);
figure(4);
displayImage(bad .* imR  + i * bad .* imI)
    
im = pfmRead([root,'Phase_einstein.t045.w08.pfm']);
figure(5);
displayImage(bad .* im)
    
im = pfmRead([root,'Amp_einstein.t045.w08.pfm']);
figure(6);
displayImage(bad .* im)
pause(2)
%%%%%%%%%%%%%%%%%%%%%%%
