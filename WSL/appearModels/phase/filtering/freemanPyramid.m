% [...] = freemanPyramid( CNTRL, IMAGE, CACHECNTRL )
%
% Builds a steerable Freeman pyramid from an image.  This
% function is a MEX interface to the Freeman pyramid C code.
% The input arguments are CNTRL, which is a matlab structure that 
% is analgous to the FreemanPyramidCntrlStruct in C, and IMAGE,
% which is the image to be filtered.  Depending on the CNTRL
% structure (i.e., on the value of the storeMap field), the
% function returns between 0 and 6 cell arrays containing the
% results of the filtering.  CACHECNTRL, which is optional,
% provides an interface to the FreemanCacheCntrlStruct in C,
% thus allowing caching of results to speed up processing
% when filtering the same image many times.
%
% To use the function, you first build a CNTRL structure, and
% then pass the structure and the IMAGE to the freemanPyramid
% function.  All of the fields in the CNTRL structure are
% optional.  If a field is omitted, then the value of that field will
% be taken from the default FreemanPyramidCntrlStruct created
% by the C code (i.e., the fields in CNTRL, if specified,
% override those in the default control structure in the C code).
%
% The fields in the CNTRL structure are the same as those
% in the FreemanPyramidCntrlStruct in the C code (with the
% addition of epsAmp and epsContrast).  They are:
%
% CNTRL.nOrient - number of orientations.  If specified must
%   be the same as the length of CNTRL.thetaDeg.  If omitted, it
%   is determined by the length of thetaDeg or by the default
%   number of orientations.
%   Default value: 4 (or length of CNTRL.thetaDeg)
%
% CNTRL.thetaDeg - orientations, in degrees.  Must be a vector.
%   Default value: [0.0 45.0 90.0 135.0]
%
% CNTRL.nScale - number of scales.  If specified must be the same
%   as the length of CNTRL.lambda.  If omitted, it is determined
%   by the length of lambda, or by the default number of scales.
%   Default value: 2 (or length of CNTRL.lambda)
%
% CNTRL.lambda - wavelengths, in pixels.  Must be a vector of
%   non-decreasing values.
%   Default value: [8.0 16.0]
%
% CNTRL.nPyr - minimum number of pyramid levels to compute.
%   Default value: 0 (i.e., calculate pyramid height)
%
% CNTRL.storeMap - a vector specifying what results should be
%   returned to the user.  The vector must contain only 0's
%   and 1's (0 specifying discard the result, 1 specifying
%   return the result).  The maximum length of the vector is
%   6, although it may be shorter because trailing 0's can
%   be omitted.  The components of storeMap have the same
%   meaning as do the corresponding components in the C code.
%   In order, they are:
%
%     [isGrad, isPhase, isAmp, isFilter, isBasis, isPyr]
%
%   For example, to return just the filter maps, you would set
%   storeMap to [0 0 0 1 0 0].  The freemanPyramid function
%   returns only those values maps for which storeMap is set
%   to 1, and it returns them in the order they appear in
%   storeMap.
%   Default value: [0 0 0 0 0 0] (i.e., do nothing)
%
% CNTRL.border - do not filter pixels within border subsampled 
%   pixels of the image borders.
%   Default value: 0
%
% CNTRL.preSigma - prefilter the original image by a 2D Gaussian
%   with standard deviation preSigma before applying the Freeman 
%   pyramid.  preSigma = 0 implies no prefiltering is to be done.
%   Default value: 0
%
% CNTRL.rockBottom - minimum amplitude of filter response to
%   consider.
%   Default value: 0.1
%
% CNTRL.tauThres - tau treshold for phase singularity constraint.
%   Default value: 1.3
%
% CNTRL.fitlerDiam - filter mask is roughly 7*sigma in diameter.
%   Default value: 7.0
%
% CNTRL.thetaTol - Orientation tolerance with respect to center 
%   filter tuning.
%   Default value: 30.0
%
% CNTRL.epsAmp - amplitude threshold.
%   Default value: 3.0
%
% CNTRL.epsContrast - contrast threshold.
%   Default value: 0.0
%
% The CACHECNTRL structure is optional.  If it is not specified,
% then the filtering results will not be cached.  If you wish to
% use caching, you build a CACHECNTRL structure in the same
% manner as the CNTRL object, overriding the default value of any
% fields you wish to change:
%
% CACHECNTRL.cacheFiles - a vector specifying what results should be
%   cached.  The vector must contain only 0's and 1's (0
%   specifying discard the result, 1 specifying cache the
%   result).  The order of the components is the same as
%   that of CNTRL.storeMap.
%   Default value: [0 0 0 0 0 0] (i.e., cache nothing)
%
% CACHECNTRL.pathNameCache - a string specifying the path and
%   base name for the cache files.
%   Default value: 'cache/'
%
% CACHECNTRL.rootNameCache - a string specifying the root name
%   to use for the cache files.
%   Default value: 'image'
%
% Note that the field names in the CNTRL and CACHECNTRL
% structures are case sensitive.
%
% The function freemanPyramid returns its results as cell arrays.
% Only those results for which the corresponding element in
% CNTRL.storeMap is 1 are returned, and they are returned in the
% order they appear in storeMap.  The possible results are:
%
% gradMap - an nScale-by-nOrient-by-2 cell array containing the
%   phase gradient maps.  The x-component of the gradient is
%   returned in gradMap{:,:,1} and the y-component in
%   gradMap{:,:,2}.  Important note: phase singularities are marked 
%   in these gradient maps by the constant BIG_NEG = -1.0e+38.
%
% phaseMap - an nScale-by-nOrient cell array containing the phase 
%   maps.  (Phase singularities are marked in the gradient map.)
%
% ampMap - an nScale-by-nOrient cell array containing the
%   amplitude maps.
%
% filterMap - an nScale-by-nOrient-by-2 cell array containing the
%   raw G2, H2 responses.  G2 is stored in filterMap{:,:,1}, and
%   H2 is stored in filterMap{:,:,2}.
%
% basisMap - an nScale-by-7 cell array containing the basis maps
%   for each scale.
%
% pyrMap - an nPyr-by-1 cell array containing the pyramid maps.
%
% The following is an example which filters an image at
% orientations 0 and 90 degrees and scales 8 and 16, then
% returns the phase and amplitude maps:
%
%   cntrl.thetaDeg = [0 90];
%   cntrl.lambda = [8 16];
%   cntrl.storeMap = [0 1 1 0 0 0];
%   [phaseMap,ampMap] = freemanPyramid( cntrl, image );
%     
% June 2001, Thomas F. El-Maraghi
