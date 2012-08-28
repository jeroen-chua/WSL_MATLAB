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

image = pgmRead('/tilde/fleet/data/images/einstein.pgm');

cntrl.tauThres 
cntrl.thetaDeg = [0 45 90 135];
cntrl.lambda = [8 16];
cntrl.storeMap = [1 1 1 0 0 0];
cntrl.epsAmp - amplitude threshold.
cntrl.epsContrast - contrast threshold.

[phaseMap,ampMap] = freemanPyramid( cntrl, image );

