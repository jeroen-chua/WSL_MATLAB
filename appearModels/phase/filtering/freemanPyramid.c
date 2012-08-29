/****  Version 0.0, July 1999. *******************************************
FILE: freemanPyramid.c

Public interface to phaseUtil.V4(+) code, which builds a pyramid of G2/H2 
steerable filters.
*************************************************************************/

#include        "macros.h"
#include        "utils.h"
#include        "phase.h"
#include        "freemanPyramid.h"
#include        "phaseUtil.h"
#include        "mex.h"

/* Allocate a freeman pyramid struct (see freemanUtil.h) and
   initialize it to default values.  If the argument pc is NULL
   then a new FreemanPyramidCntrlStruct is generated with default
   values and linked to the cntrl field.  Otherwise, the cntrl
   field is linked to the provided argument pointer.  */
FreemanPyramidStruct * newFreemanPyramidStruct(FreemanPyramidCntrlStruct * pc) 
{ 
  FreemanPyramidStruct *fp;
  int k;

  grabByteMemory((char **)&fp, sizeof(FreemanPyramidStruct), "newFreemanPyramidStruct");

  if (pc == NULL)
   fp->cntrl = defaultFreemanPyramidCntrlStruct();
  else
   fp->cntrl = pc;
  
  /* Set all image pointers to NULL to indicate empty */
  for(k=0; k<NUMSCALE; k++)
    fp->pyrMap[k] = NULL;
  for(k=0; k<NUMBASIS*NUMSCALE; k++) 
    fp->basisMap[k] = NULL;
  for(k=0; k<NUMCHANNEL; k++)
    fp->phaseMap[k] = fp->ampMap[k] = NULL;
  for(k=0; k<2*NUMCHANNEL; k++)
    fp->filterMap[k] = fp->gradMap[k] = NULL;

  return(fp);
}

/* Allocate a freeman pyramid control struct (see freemanUtil.h) and
   initialize it to default values.  Typically users need to
   change storeMap only.  They should not change the other default values. */
FreemanPyramidCntrlStruct * defaultFreemanPyramidCntrlStruct() 
{
  FreemanPyramidCntrlStruct *pc;
  int k;

  grabByteMemory((char **)&pc, sizeof(FreemanPyramidCntrlStruct), 
		 "defaultFreemanPyramidCntrlStruct");

  /* Default settings for the orientations */
  pc->nOrient = 4;
  pc->thetaDeg[0] = 0.0;
  pc->thetaDeg[1] = 45.0;
  pc->thetaDeg[2] = 90.0;
  pc->thetaDeg[3] = 135.0;

  /* Default settings for the scales */
  pc->nScale = 2;
  pc->lambda[0] = 8.0;
  pc->lambda[1] = 16.0;

  pc->nPyr = 0;

  /* Set storeMap to be empty (do nothing) */
  for(k=0; k<NUMCODE; k++)
    pc->storeMap[k] = 0;

  /* Tunable parameters. But I suggest you leave these as is. */
  pc->border = 0;             /* No border around filtered image */
  pc->preSigma = 0.0;         /* Don't prefilter input image */

  /* Don't change the following unless you know what you are doing */
  pc->rockBottom = ROCK_BOTTOM;
  pc->tauThres = 1.5; /* tau treshold for phase singularity constraint */
  pc->filterDiam = 7.0; /* filter mask is roughly 7*sigmaMax in diameter */
  pc->thetaTol = 30.0; /* Orientation tolerance wrt center filter tuning */

  return(pc);
}

/* Allocate a Freeman pyramid cache control struct (see freemanUtil.h)
   and initialize it to default values.  This structure controls what
   the phaseUtil.V4(+).c routines cache for later use. 
   The typical user only needs to change:
     pathNameCache
     rootNameCache
*/
FreemanCacheCntrlStruct * defaultFreemanCacheCntrlStruct()
{
  FreemanCacheCntrlStruct *pcc;

  grabByteMemory((char **)&pcc, sizeof(FreemanCacheCntrlStruct), 
		 "defaultFreemanCacheCntrlStruct");
  /* cacheFiles array:
       Control flags for caching types of filtered images, namely:
       (gradMap, phaseMap, ampMap, filterMap, basisMap, pyramidFlag)
       The filtering routines will look-up and cache any image map(s)
       for which the corresponding flag is set to 1 (otherwise set the
       flag to 0). */
  pcc->cacheFiles[isGrad] = 0;
  pcc->cacheFiles[isPhase] = 0;
  pcc->cacheFiles[isAmp] = 0;
  pcc->cacheFiles[isFilter] = 0;
  pcc->cacheFiles[isBasis] = 0;  /* 1, caching this makes some sense */
  pcc->cacheFiles[isPyr] = 0;

  strcpy(pcc->pathNameCache, "cache/");
  strcpy(pcc->rootNameCache, "image");  /* User's routine should change this to
				      be a unique image designator */
  return(pcc);
}


/* Recover Freeman filter responses from cache, or compute them if
   the cache results are stale or not found. If new results are
   computed, then these are cached. */
void recoverFreemanPyramid_Byte(FreemanPyramidStruct *fp,
   unsigned char *image, int nxImage, int nyImage, 
   float epsAmp, float epsContrast,
   FreemanCacheCntrlStruct *pcc)
{
  int bytesPerPixel=1;

  resetFreemanPyramidParams(fp->cntrl);
  fp->nxImage = nxImage;
  fp->nyImage = nyImage;

  recoverFastFilterOutputs((void *)image, bytesPerPixel, nxImage, nyImage,
      pcc->pathNameCache, pcc->rootNameCache, pcc->cacheFiles,
      fp->cntrl->lambda,  fp->cntrl->nScale, 
      fp->cntrl->thetaDeg, fp->cntrl->nOrient,
      fp->cntrl->storeMap,
      fp->pyrMap, &(fp->cntrl->nPyr), &(fp->newPyrBase), 
      fp->basisMap, fp->filterMap, 
      fp->phaseMap, fp->ampMap, fp->gradMap,
      epsAmp, epsContrast, 
      fp->nxPyr, fp->nyPyr, fp->nxFilt, fp->nyFilt);
} 



/* Recover Freeman filter responses from cache, or compute them if
   the cache results are not found. If new results are
   computed, then these are cached. */
void recoverFreemanPyramid_Float(FreemanPyramidStruct *fp,
   float *fimage, int nxImage, int nyImage, 
   float epsAmp, float epsContrast,
   FreemanCacheCntrlStruct *pcc)
{
  int bytesPerPixel=4;

  resetFreemanPyramidParams(fp->cntrl);
  fp->nxImage = nxImage;
  fp->nyImage = nyImage;

  recoverFastFilterOutputs((void *)fimage, bytesPerPixel,
      nxImage, nyImage,
      pcc->pathNameCache, pcc->rootNameCache, pcc->cacheFiles,
      fp->cntrl->lambda,  fp->cntrl->nScale, 
      fp->cntrl->thetaDeg, fp->cntrl->nOrient,
      fp->cntrl->storeMap,
      fp->pyrMap,  &(fp->cntrl->nPyr),&(fp->newPyrBase), 
      fp->basisMap, fp->filterMap, 
      fp->phaseMap, fp->ampMap, fp->gradMap,
      epsAmp, epsContrast, 
      fp->nxPyr, fp->nyPyr, fp->nxFilt, fp->nyFilt);
} 

/* Compute Freeman filter responses, byte image. Cache not used. */
void computeFreemanPyramid_Byte(FreemanPyramidStruct *fp,
   unsigned char *image, int nxImage, int nyImage, 
   float epsAmp, float epsContrast)
{
  int bytesPerPixel=1;

  resetFreemanPyramidParams(fp->cntrl);
  fp->nxImage = nxImage;
  fp->nyImage = nyImage;

  computeFastFilterOutputs((void *)image, bytesPerPixel, nxImage, nyImage,
      fp->cntrl->lambda,  fp->cntrl->nScale, 
      fp->cntrl->thetaDeg, fp->cntrl->nOrient,
      fp->cntrl->storeMap,
      fp->pyrMap, &(fp->cntrl->nPyr), &(fp->newPyrBase), 
      fp->basisMap, fp->filterMap, 
      fp->phaseMap, fp->ampMap, fp->gradMap,
      epsAmp, epsContrast, 
      fp->nxPyr, fp->nyPyr, fp->nxFilt, fp->nyFilt);
} 

/* Compute Freeman filter responses, float image. Cache not used. */
void computeFreemanPyramid_Float(FreemanPyramidStruct *fp,
   float *fimage, int nxImage, int nyImage, 
   float epsAmp, float epsContrast)
{
  int bytesPerPixel=4;

  resetFreemanPyramidParams(fp->cntrl);
  fp->nxImage = nxImage;
  fp->nyImage = nyImage;

  /* Cast the float image pointer, but set bytesPerPixel to be 4
     to indicate that the image is actually a float image */
  computeFastFilterOutputs((void *) fimage, bytesPerPixel, 
      nxImage, nyImage,
      fp->cntrl->lambda,  fp->cntrl->nScale, 
      fp->cntrl->thetaDeg, fp->cntrl->nOrient,
      fp->cntrl->storeMap,
      fp->pyrMap, &(fp->cntrl->nPyr), &(fp->newPyrBase), 
      fp->basisMap, fp->filterMap, 
      fp->phaseMap, fp->ampMap, fp->gradMap,
      epsAmp, epsContrast, 
      fp->nxPyr, fp->nyPyr, fp->nxFilt, fp->nyFilt);
} 

/* Deallocate the memory used for the Freeman pyramid, stored
   according to pc->cntrl->storeMap */
void freeFreemanPyramid(FreemanPyramidStruct *fp)
{
  int k, iScale, iShift;

  if (fp->cntrl->storeMap[isPyr]) {
    /* Free any non-NULL image pointers, other than the pyramid base,
       which may be user allocated. */
    if (fp->pyrMap[0] != NULL) {
      if (fp->newPyrBase) {
	utilFree((void **) &(fp->pyrMap[0]));
      } else {
	/* Careful NOT to free user's image */
	fp->pyrMap[0] = NULL;
      }
    }

    for(k=1; k<fp->cntrl->nPyr; k++)
      if (fp->pyrMap[k] != NULL) {
	utilFree((void **) &(fp->pyrMap[k]));
      }
  }

  for(iScale=0;iScale<fp->cntrl->nScale;iScale++) {

    if (fp->cntrl->storeMap[isBasis]) {
      iShift = iScale*NUMBASIS;
      for(k=0; k<NUMBASIS; k++)
	if (fp->basisMap[k+iShift] != NULL) { 
	  utilFree((void **) &(fp->basisMap[k+iShift]));
	}
    }

    if (fp->cntrl->storeMap[isFilter]) {
      iShift = iScale*(fp->cntrl->nOrient)*2;
      for(k=0; k<2*(fp->cntrl->nOrient); k++) 
	if (fp->filterMap[k+iShift] != NULL) { 
	  utilFree((void **) &(fp->filterMap[k+iShift]));
	}
    }

    if (fp->cntrl->storeMap[isPhase]) {
      iShift = iScale*(fp->cntrl->nOrient);
      for(k=0; k<(fp->cntrl->nOrient); k++)
	if (fp->phaseMap[k+iShift] != NULL) { 
	  utilFree((void **) &(fp->phaseMap[k+iShift]));
	}
    }

    if (fp->cntrl->storeMap[isAmp]) {
      iShift = iScale*(fp->cntrl->nOrient);
      for(k=0; k<(fp->cntrl->nOrient); k++) 
	if (fp->ampMap[k+iShift] != NULL) { 
	  utilFree((void **) &(fp->ampMap[k+iShift]));
	}
    }

    if (fp->cntrl->storeMap[isGrad]) {
      iShift = iScale*(fp->cntrl->nOrient)*2;
      for(k=0; k<2*(fp->cntrl->nOrient); k++) 
	if (fp->gradMap[k+iShift] != NULL) { 
	  utilFree((void **) &(fp->gradMap[k+iShift]));
	}
    }
  }
}

/* Deallocate the memory used for the Freeman pyramid in
   the corresponding map, as specified by:
     isMap = isGrad, isPhase, isAmp, isFilter, isBasis, isPyr
   (as defined in phase.h). */
void freeFreemanPyramidMap(FreemanPyramidStruct *fp, int isMap)
{
  int k, iScale, iShift;
  switch(isMap) {
  case isGrad:
    for(iScale=0;iScale<fp->cntrl->nScale;iScale++) {
      iShift = iScale*(fp->cntrl->nOrient)*2;
      for(k=0; k<2*(fp->cntrl->nOrient); k++) 
	if (fp->gradMap[k+iShift] != NULL) { 
	  utilFree((void **) &(fp->gradMap[k+iShift]));
	}
    }
    break;
  case isPhase:
    for(iScale=0;iScale<fp->cntrl->nScale;iScale++) {
      iShift = iScale*(fp->cntrl->nOrient);
      for(k=0; k<(fp->cntrl->nOrient); k++)
	if (fp->phaseMap[k+iShift] != NULL) { 
	  utilFree((void **) &(fp->phaseMap[k+iShift]));
	}
    }
    break;
  case isAmp:
    for(iScale=0;iScale<fp->cntrl->nScale;iScale++) {
      iShift = iScale*(fp->cntrl->nOrient);
      for(k=0; k<(fp->cntrl->nOrient); k++) 
        if (fp->ampMap[k+iShift] != NULL) { 
          utilFree((void **) &(fp->ampMap[k+iShift]));
        }
    }
    break;
  case isFilter:
    for(iScale=0;iScale<fp->cntrl->nScale;iScale++) {
      iShift = iScale*(fp->cntrl->nOrient)*2;
      for(k=0; k<2*(fp->cntrl->nOrient); k++) 
        if (fp->filterMap[k+iShift] != NULL) { 
          utilFree((void **) &(fp->filterMap[k+iShift]));
        }
    }
    break;
  case isBasis:
    for(iScale=0;iScale<fp->cntrl->nScale;iScale++) {
      iShift = iScale*NUMBASIS;
      for(k=0; k<NUMBASIS; k++)
	if (fp->basisMap[k+iShift] != NULL) { 
	  utilFree((void **) &(fp->basisMap[k+iShift]));
	}
    }
    break;
  case isPyr:
    /* Free any non-NULL image pointers, other than the pyramid base,
       which may be user allocated. */
    if (fp->pyrMap[0] != NULL) {
      if (fp->newPyrBase) {
	utilFree((void **) &(fp->pyrMap[0]));
      } else {
	/* Careful NOT to free user's image */
	fp->pyrMap[0] = NULL;
      }
    }

    for(k=1; k<fp->cntrl->nPyr; k++)
      if (fp->pyrMap[k] != NULL) {
	utilFree((void **) &(fp->pyrMap[k]));
      }
    break;
  default:
    mexPrintf( "freeFreemanPyramidMap: %s %d\n",
            "Unknown freeman pyramid map type:", isMap);
  }

}
