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

BIGNEG = -99999996802856924650656260769173209088.000000;

image = pgmRead('/tilde/fleet/data/images/einstein.pgm');

cntrl.thetaDeg = [0 45 90 135];
cntrl.lambda = [8 16];
cntrl.storeMap = [1 1 1 0 0 0];

% optional 0's mean don't cache
cachecntrl.cacheFiles = [0 0 0 0 1 0]; %[Grad,Phase,Amp,Filter,Basis,Pyr]
%cachecntrl.cacheFiles = [0 0 0 0 0 0]; 
cachecntrl.pathNameCache = '/tilde/fleet/matlab/filtering/Cache/';
cachecntrl.rootNameCache = 'ein';

[gradMap, phaseMap, ampMap] = freemanPyramid( cntrl, image, cachecntrl);

for s = 1:length(cntrl.lambda)
  for w = 1:length(cntrl.thetaDeg)
    disp(['scale ', num2str(cntrl.lambda(s)), ...
          '   orientation ', num2str(cntrl.thetaDeg(w))]);
    imR = gradMap{s, w, 1};
    imI = gradMap{s, w, 2};
    bad = (imR > BIGNEG);
    figure(1);
    displayImage(bad .* imR  + i * bad .* imI);
    
    im = phaseMap{s, w};
    figure(2);
    displayImage(bad .* im);
    
    im = ampMap{s, w};
    figure(3);
    displayImage(bad .* im);
    pause;
  end
end


























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
