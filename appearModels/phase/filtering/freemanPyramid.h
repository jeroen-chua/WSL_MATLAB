/* FILE: freemanPyramid.h 
   May 1999 */

#ifndef _PHASE_H
# include "phase.h"   /* Provides constants, NUMSCALE ... */
#endif

#ifndef _FREEMAN_PYRAMID_H
# define _FREEMAN_PYRAMID_H

#ifndef MAXLEN
#define MAXLEN 1024
#endif
/**********************************************************
  Structure type definitions for Freeman G2/H2 pyramid
**********************************************************/

typedef struct {
  /* storeMap array:
       Control flags for recovering types of filtered images, namely:
       (gradMap, phaseMap, ampMap, filterMap, basisMap, pyramidFlag)
       The filtering routines will return any image map(s) for which
       the corresponding flag is set to 1 (otherwise set the flag to 0). */
  int storeMap[NUMCODE];

  int nScale;  /* number of scales */
  float lambda[NUMSCALE];  /* wavelengths for Freeman filters at each scale, 
		     in increasing order (eg. 4.0, 8.0, 16.0) */
  int nOrient;    /* number of orientation channels (eg. 3 or 4) */
  /* peak orientation for each channel (eg. 0, 45, 90, 135)*/  
  float thetaDeg[NUMORIENT]; 

  int border; /* Do not filter pixels within border subsampled pixels
                 of the image borders */
  float preSigma; /* Prefilter the original image by a 2D Gaussian
		     with standard deviation preSigma before applying
		     the Freeman pyramid.  (preSigma==0.0 implies no
		     prefiltering is to be done. */
  float rockBottom; /* Minimum amplitude of filter response to consider */
  float tauThres;  /* tau treshold for phase singularity constraint */
  float filterDiam ; /* filter mask is roughly 7*sigma in diameter */
  float thetaTol; /* Orientation tolerance wrt center filter tuning */

  /* DERIVED values.  These are determined by the above choices,
     but are useful to have reported back to the user. */
  int subSample[NUMSCALE]; /* subSampling rate used for G2/H2 filters */
  int nPyr;  /* Number of levels in the pyramid (determined by lambda's) */

} FreemanPyramidCntrlStruct;

typedef struct {
  /* cacheFiles array:
       Control flags for caching types of filtered images, namely:
       (gradMap, phaseMap, ampMap, filterMap, basisMap, pyramidFlag)
       The filtering routines will look-up and cache any image map(s)
       for which the corresponding flag is set to 1 (otherwise set the
       flag to 0). */
  int cacheFiles[NUMCODE];
  char pathNameCache[MAXLEN];
  char rootNameCache[MAXLEN];
} FreemanCacheCntrlStruct;

typedef struct {
  FreemanPyramidCntrlStruct *cntrl;  
  /* cntrl Controls the filtering operations, including
      - storeMap field to specify what is to be computed,
      - various constants which should not be changed. */
  int nxImage, nyImage;  /* Size of original image */
  int nxPyr[NUMSCALE], nyPyr[NUMSCALE];
                      /* nxPyr[s], nyPyr[s] - size of pyramid response image
                         for scale s, 0 <= s < nPyr */
  float *pyrMap[NUMSCALE]; /* pyrMap[s] = pyramid image (floats) for scale s */
  int newPyrBase; /* Set to 1 if pyrMap[0] is in separate storage,
		     otherwise 0 indicates pyrMap[0] references the user's
		     allocated image */
  int nxFilt[NUMSCALE], nyFilt[NUMSCALE];
                        /* nxFilt[s], nyFilt[s] - size of filter response
			   images for scale s, 0 <= s < nScale */
  /* Filter response images, eg filterMap[k] for each scale and orientation */
  float *basisMap[NUMBASIS * NUMSCALE];
  float *filterMap[2*NUMCHANNEL];
  float *phaseMap[NUMCHANNEL], *ampMap[NUMCHANNEL];
  float *gradMap[2*NUMCHANNEL];
} FreemanPyramidStruct;

/**********************************************************
  Function prototypes for freemanPyramid.c
**********************************************************/

/* Allocate a freeman pyramid struct (see freemanUtil.h) and
   initialize it to default values.  If the argument pc is NULL
   then a new FreemanPyramidCntrlStruct is generated with default
   values and linked to the cntrl field.  Otherwise, the cntrl
   field is linked to the provided argument pointer.  */
FreemanPyramidStruct * newFreemanPyramidStruct(
                              FreemanPyramidCntrlStruct * pc); 

/* Allocate a freeman pyramid control struct (see freemanUtil.h) and
   initialize it to default values.  Typically users need to
   change storeMap only.  They should not change the other default values. */
FreemanPyramidCntrlStruct * defaultFreemanPyramidCntrlStruct();

/* Allocate a Freeman pyramid cache control struct and initialize it
   to default values.  This structure controls what
   the phaseUtil.V4(+) routines cache for later use. */
FreemanCacheCntrlStruct * defaultFreemanCacheCntrlStruct();

/* Recover Freeman filter responses from cache, or compute them if
   the cache results are not found. If new results are
   computed, then these are cached. */
void recoverFreemanPyramid_Byte(FreemanPyramidStruct *fp,
   unsigned char *image, int nxImage, int nyImage,
   float epsAmp, float epsContrast,
   FreemanCacheCntrlStruct *fpcc); 

/* Recover Freeman filter responses from cache, or compute them if
   the cache results are not found. If new results are
   computed, then these are cached. */
void recoverFreemanPyramid_Float(FreemanPyramidStruct *fp,
   float *fimage, int nxImage, int nyImage,
   float epsAmp, float epsContrast,
   FreemanCacheCntrlStruct *fpcc); 

/* Compute Freeman filter responses, byte image. Cache not used. */
void computeFreemanPyramid_Byte(FreemanPyramidStruct *fp,
   unsigned char *image, int nxImage, int nyImage,
   float epsAmp, float epsContrast);

/* Compute Freeman filter responses, float image. Cache not used. */
void computeFreemanPyramid_Float(FreemanPyramidStruct *fp,
   float *fimage, int nxImage, int nyImage,
   float epsAmp, float epsContrast);
						   
/* Deallocate the memory used for the Freeman pyramid, stored
   according to fp->cntrl->storeMap */
void freeFreemanPyramid(FreemanPyramidStruct *fp);

/* Deallocate the memory used for the Freeman pyramid in
   the corresponding map, as specified by:
     isMap = isGrad, isPhase, isAmp, isFilter, isBasis, isPyr
   (as defined in phase.h). */
void freeFreemanPyramidMap(FreemanPyramidStruct *fp, int isMap);

#endif
