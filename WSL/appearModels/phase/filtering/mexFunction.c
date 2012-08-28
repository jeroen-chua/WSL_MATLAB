/********************************************************
 *
 * MEX interface to Freeman pyramid routines.
 * Thomas F.El-Maraghi
 * June 2001
 *
 ********************************************************/


#include "macros.h"
#include "freemanPyramid.h"
#include "mextools.h"
#include "utils.h"


/* Create a default freeman pyramid control structure, 
   and then customize it with the values from a matlab
   structure */
int mexFreemanPyramidCntrlStruct( const mxArray *mxStruct, 
				  FreemanPyramidCntrlStruct **cntrl,
				  float *epsAmp, float *epsContrast )
{
  mxArray *field;
  double *ptr, ftmp;
  int fn, m, n, k, itmp;
  int nOrient, nScale;

  /* make sure mxStruct is a structure */
  if( !mxIsStruct(mxStruct) )
    mexErrMsgTxt( "Freeman pyramid control structure expected" );

  /* start with a default control structure */
  *cntrl = defaultFreemanPyramidCntrlStruct();
  
  /* get the number of orientations if specified */
  nOrient = -1;
  fn = mxGetFieldNumber( mxStruct, "nOrient" );
  if( fn >= 0 ) {
    field = mxGetFieldByNumber( mxStruct, 0, fn );
    nOrient = (int)mxGetScalar( field );
    if( nOrient < 1 || nOrient > NUMORIENT )
      mexErrMsgTxt( "nOrient - invalid number of orientations" );
    (*cntrl)->nOrient = nOrient;
  }  

  /* get the orientations if they are specified */
  fn = mxGetFieldNumber( mxStruct, "thetaDeg" );
  if( fn >= 0 ) {
    field = mxGetFieldByNumber( mxStruct, 0, fn );
    m = mxGetM(field);
    n = mxGetN(field);
    if( min(m,n) != 1 )
      mexErrMsgTxt( "thetaDeg - must be a vector" );
    if( max(m,n) > NUMORIENT )
      mexErrMsgTxt( "thetaDeg - too many orientations" );
    (*cntrl)->nOrient = max(m,n);
    if( nOrient > 0 && (*cntrl)->nOrient != nOrient )
      mexErrMsgTxt( "nOrient - must match length of vector thetaDeg" );
    ptr = mxGetPr(field);
    for( k = 0; k < (*cntrl)->nOrient; k++ )
      (*cntrl)->thetaDeg[k] = (float)ptr[k];
  } 

  /* get the number of orientations if specified */
  nScale = -1;
  fn = mxGetFieldNumber( mxStruct, "nScale" );
  if( fn >= 0 ) {
    field = mxGetFieldByNumber( mxStruct, 0, fn );
    nScale = (int)mxGetScalar( field );
    if( nScale < 1 || nScale > NUMORIENT )
      mexErrMsgTxt( "nScale - invalid number of scales" );
    (*cntrl)->nScale = nScale;
  }  

  /* get the scales if they are specified */
  fn = mxGetFieldNumber( mxStruct, "lambda" );
  if( fn >= 0 ) {
    field = mxGetFieldByNumber( mxStruct, 0, fn );
    m = mxGetM(field);
    n = mxGetN(field);
    if( min(m,n) != 1 )
      mexErrMsgTxt( "lambda - must be a vector" );
    if( max(m,n) > NUMORIENT )
      mexErrMsgTxt( "lambda - too many scales" );
    (*cntrl)->nScale = max(m,n);
    ptr = mxGetPr(field);
    for( k = 0; k < (*cntrl)->nScale; k++ )
      (*cntrl)->lambda[k] = (float)ptr[k];
  } 

  /* get the size of the pyramid if specified */
  fn = mxGetFieldNumber( mxStruct, "nPyr" );
  if( fn >= 0 ) {
    field = mxGetFieldByNumber( mxStruct, 0, fn );
    itmp = (int)mxGetScalar( field );
    if( itmp < 0 )
      mexErrMsgTxt( "nPyr - cannot be negative" );
    (*cntrl)->nPyr = itmp;
  }  
  
  /* get the storeMap flags if they are specified */
  fn = mxGetFieldNumber( mxStruct, "storeMap" );
  if( fn >= 0 ) {
    field = mxGetFieldByNumber( mxStruct, 0, fn );
    m = mxGetM(field);
    n = mxGetN(field);
    if( min(m,n) != 1 )
      mexErrMsgTxt( "storeMap - must be a vector" );
    n = max(m,n);
    if( n > NUMCODE )
      mexErrMsgTxt( "storeMap - too many values" );
    ptr = mxGetPr(field);
    for( k = 0; k < n; k++ ) {
      itmp = (int)ptr[k];
      if( itmp != 0 && itmp != 1 )
	mexErrMsgTxt( "storeMap - elements must be 0 or 1" );
      (*cntrl)->storeMap[k] = itmp;
    }
  } 

  /* get the size of the border if specified */
  fn = mxGetFieldNumber( mxStruct, "border" );
  if( fn >= 0 ) {
    field = mxGetFieldByNumber( mxStruct, 0, fn );
    itmp = (int)mxGetScalar( field );
    if( itmp < 0 )
      mexErrMsgTxt( "border - cannot be negative" );
    (*cntrl)->border = itmp;
  }  

  /* get preSigma if specified */
  fn = mxGetFieldNumber( mxStruct, "preSigma" );
  if( fn >= 0 ) {
    field = mxGetFieldByNumber( mxStruct, 0, fn );
    ftmp = (float)mxGetScalar( field );
    if( ftmp < 0.0 )
      mexErrMsgTxt( "perSigma - cannot be negative" );
    (*cntrl)->preSigma = ftmp;
  }  

  /* get rockBottom if specified */
  fn = mxGetFieldNumber( mxStruct, "rockBottom" );
  if( fn >= 0 ) {
    field = mxGetFieldByNumber( mxStruct, 0, fn );
    ftmp = (float)mxGetScalar( field );
    if( ftmp < 0.0 )
      mexErrMsgTxt( "rockBottom - cannot be negative" );
    (*cntrl)->rockBottom = ftmp;
  }  

  /* get tauThres if specified */
  fn = mxGetFieldNumber( mxStruct, "tauThres" );
  if( fn >= 0 ) {
    field = mxGetFieldByNumber( mxStruct, 0, fn );
    ftmp = (float)mxGetScalar( field );
    if( ftmp < 0.0 )
      mexErrMsgTxt( "tauThres - cannot be negative" );
    (*cntrl)->tauThres = ftmp;
  }  

  /* get filterDiam if specified */
  fn = mxGetFieldNumber( mxStruct, "filterDiam" );
  if( fn >= 0 ) {
    field = mxGetFieldByNumber( mxStruct, 0, fn );
    ftmp = (float)mxGetScalar( field );
    if( ftmp < 0.0 )
      mexErrMsgTxt( "filterDiam - cannot be negative" );
    (*cntrl)->filterDiam = ftmp;
  }  

  /* get thetaTol if specified */
  fn = mxGetFieldNumber( mxStruct, "thetaTol" );
  if( fn >= 0 ) {
    field = mxGetFieldByNumber( mxStruct, 0, fn );
    ftmp = (float)mxGetScalar( field );
    if( ftmp < 0.0 )
      mexErrMsgTxt( "thetaTol - cannot be negative" );
    (*cntrl)->thetaTol = ftmp;
  }  

  /* get epsAmp if specified */
  fn = mxGetFieldNumber( mxStruct, "epsAmp" );
  if( fn >= 0 ) {
    field = mxGetFieldByNumber( mxStruct, 0, fn );
    ftmp = (float)mxGetScalar( field );
    if( ftmp < 0.0 )
      mexErrMsgTxt( "epsAmp - cannot be negative" );
    *epsAmp = ftmp;
  }  

  /* get epsC if specified */
  fn = mxGetFieldNumber( mxStruct, "epsContrast" );
  if( fn >= 0 ) {
    field = mxGetFieldByNumber( mxStruct, 0, fn );
    ftmp = (float)mxGetScalar( field );
    if( ftmp < 0.0 )
      mexErrMsgTxt( "epsContrast - cannot be negative" );
    *epsContrast = ftmp;
  }  
}


/* Create a default freeman pyramid cache control structure, 
   and then customize it with the values from a matlab
   structure */
int mexFreemanCacheCntrlStruct( const mxArray *mxStruct, 
				FreemanCacheCntrlStruct **fpcc )
{
  mxArray *field;
  double *ptr, ftmp;
  int fn, m, n, k, itmp;
  int nOrient, nScale;

  /* make sure mxStruct is a structure */
  if( !mxIsStruct(mxStruct) )
    mexErrMsgTxt( "Freeman cache control structure expected" );

  /* start with a default control structure */
  *fpcc = defaultFreemanCacheCntrlStruct();
  
  /* get the cacheFiles flags if they are specified */
  fn = mxGetFieldNumber( mxStruct, "cacheFiles" );
  if( fn >= 0 ) {
    field = mxGetFieldByNumber( mxStruct, 0, fn );
    m = mxGetM(field);
    n = mxGetN(field);
    if( min(m,n) != 1 )
      mexErrMsgTxt( "cacheFiles - must be a vector" );
    n = max(m,n);
    if( n > NUMCODE )
      mexErrMsgTxt( "cacheFiles - too many values" );
    ptr = mxGetPr(field);
    for( k = 0; k < n; k++ ) {
      itmp = (int)ptr[k];
      if( itmp != 0 && itmp != 1 )
	mexErrMsgTxt( "cacheFiles - elements must be 0 or 1" );
      (*fpcc)->cacheFiles[k] = itmp;
    }
  } 

  /* get the pathNameCache field */
  fn = mxGetFieldNumber( mxStruct, "pathNameCache" );
  if( fn >= 0 ) {
    field = mxGetFieldByNumber( mxStruct, 0, fn );
    if( !mxIsChar( field ) )
      mexErrMsgTxt( "pathNameCache - must be a string" );
    if( mxGetM(field)*mxGetN(field) > MAXLEN - 1 )
      mexErrMsgTxt( "pathNameCache - string too long" );
    mxGetString( field, (*fpcc)->pathNameCache, MAXLEN - 1 );
  }  

  /* get the pathNameCache field */
  fn = mxGetFieldNumber( mxStruct, "rootNameCache" );
  if( fn >= 0 ) {
    field = mxGetFieldByNumber( mxStruct, 0, fn );
    if( !mxIsChar( field ) )
      mexErrMsgTxt( "rootNameCache - must be a string" );
    if( mxGetM(field)*mxGetN(field) > MAXLEN - 1 )
      mexErrMsgTxt( "rootNameCache - string too long" );
    mxGetString( field, (*fpcc)->rootNameCache, MAXLEN - 1 );
  }  
}


/* MEX interface function */
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{
  FreemanPyramidCntrlStruct *cntrl = NULL;
  FreemanPyramidStruct *fp = NULL;
  FreemanCacheCntrlStruct *fpcc = NULL;
  float *image, *tmp;
  float epsAmp = 0.0;
  float epsC = 0.0;
  int nxImage, nyImage;
  int iChannel, iScale, iOrient;
  int iCell, iOut, iBasis;
  int k, n;
  mwSize dims[3];
  mxArray *mxTmp;

  /* check for the required input arguments */
  if( nrhs < 2 || nrhs > 3 )
    mexErrMsgTxt( "Input expected: CNTRL, IMAGE, CACHECNTRL" );

  /* decode the matlab version of the pyramid control structure 
     and allocate the pyramid structure */ 
  mexFreemanPyramidCntrlStruct( prhs[0], &cntrl, &epsAmp, &epsC );
  fp = newFreemanPyramidStruct( cntrl );
  if( nrhs == 3 )
    mexFreemanCacheCntrlStruct( prhs[2], &fpcc );

  /* get the image to be filtered */
  mex2float( prhs[1], &image, &nxImage, &nyImage );

  /* build the pyramid */
  if( fpcc == NULL ) {    
    computeFreemanPyramid_Float(fp, image, nxImage, nyImage, 
				epsAmp, epsC);
  } else {
    recoverFreemanPyramid_Float(fp, image, nxImage, nyImage, 
				epsAmp, epsC, fpcc );
  }

  /* return the results to matlab in the order
     they appear in cntrl->storeMap */
  iOut = 0;
  /* return the gradient maps if necessary */
  if( cntrl->storeMap[isGrad] ) {
    if( iOut >= nlhs )
      mexErrMsgTxt( "Too few output arguments" );

    dims[0] = cntrl->nScale;
    dims[1] = cntrl->nOrient;
    dims[2] = 2;
    plhs[iOut] = mxCreateCellArray( 3, dims );

    for( iScale = 0; iScale < cntrl->nScale; iScale++ ) {
      for( iOrient = 0; iOrient < cntrl->nOrient; iOrient++ ) {	
	iChannel = 2*(cntrl->nOrient*iScale + iOrient);
	dims[0] = iScale;
	dims[1] = iOrient;
	float2mex( fp->gradMap[iChannel], &mxTmp, 
		   fp->nxFilt[iScale], 
		   fp->nyFilt[iScale] );
	dims[2] = 0;
	iCell = mxCalcSingleSubscript( plhs[iOut], 3, dims ); 
	mxSetCell( plhs[iOut], iCell, mxTmp );
	float2mex( fp->gradMap[iChannel+1], &mxTmp, 
		   fp->nxFilt[iScale], 
		   fp->nyFilt[iScale] );
	dims[2] = 1;
	iCell = mxCalcSingleSubscript( plhs[0], 3, dims ); 
	mxSetCell( plhs[iOut], iCell, mxTmp );
      }
    }

    iOut++;
  }

  /* return the phase maps if necessary */
  if( cntrl->storeMap[isPhase] ) {
    if( iOut >= nlhs )
      mexErrMsgTxt( "Too few output arguments" );

    dims[0] = cntrl->nScale;
    dims[1] = cntrl->nOrient;
    plhs[iOut] = mxCreateCellArray( 2, dims );

    for( iScale = 0; iScale < cntrl->nScale; iScale++ ) {
      for( iOrient = 0; iOrient < cntrl->nOrient; iOrient++ ) {
	iChannel = cntrl->nOrient*iScale + iOrient;
	dims[0] = iScale;
	dims[1] = iOrient;
	float2mex( fp->phaseMap[iChannel], &mxTmp, 
		   fp->nxFilt[iScale], 
		   fp->nyFilt[iScale] );
	iCell = mxCalcSingleSubscript( plhs[iOut], 2, dims ); 
	mxSetCell( plhs[iOut], iCell, mxTmp );
      }
    }

    iOut++;
  }

  /* return the amplitude maps if necessary */
  if( cntrl->storeMap[isAmp] ) {
    if( iOut >= nlhs )
      mexErrMsgTxt( "Too few output arguments" );

    dims[0] = cntrl->nScale;
    dims[1] = cntrl->nOrient;
    plhs[iOut] = mxCreateCellArray( 2, dims );

    for( iScale = 0; iScale < cntrl->nScale; iScale++ ) {
      for( iOrient = 0; iOrient < cntrl->nOrient; iOrient++ ) {
	iChannel = cntrl->nOrient*iScale + iOrient;
	dims[0] = iScale;
	dims[1] = iOrient;
	float2mex( fp->ampMap[iChannel], &mxTmp, 
		   fp->nxFilt[iScale], 
		   fp->nyFilt[iScale] );
	iCell = mxCalcSingleSubscript( plhs[iOut], 2, dims ); 
	mxSetCell( plhs[iOut], iCell, mxTmp );
      }
    }

    iOut++;
  }

  /* return the filter maps if necessary */
  if( cntrl->storeMap[isFilter] ) {
    if( iOut >= nlhs )
      mexErrMsgTxt( "Too few output arguments" );

    dims[0] = cntrl->nScale;
    dims[1] = cntrl->nOrient;
    dims[2] = 2;

    plhs[iOut] = mxCreateCellArray( 3, dims );

    for( iScale = 0; iScale < cntrl->nScale; iScale++ ) {
      for( iOrient = 0; iOrient < cntrl->nOrient; iOrient++ ) {

        iChannel = 2*(cntrl->nOrient*iScale + iOrient);
	dims[0] = iScale;
	dims[1] = iOrient;
	float2mex( fp->filterMap[iChannel], &mxTmp, 
		   fp->nxFilt[iScale], 
		   fp->nyFilt[iScale] );
	dims[2] = 0;
	iCell = mxCalcSingleSubscript( plhs[iOut], 3, dims ); 
	mxSetCell( plhs[iOut], iCell, mxTmp );
	float2mex( fp->filterMap[iChannel+1], &mxTmp, 
		   fp->nxFilt[iScale], 
		   fp->nyFilt[iScale] );
	dims[2] = 1;
	iCell = mxCalcSingleSubscript( plhs[0], 3, dims ); 
	mxSetCell( plhs[iOut], iCell, mxTmp );
      }
    }

    iOut++;
  }

  /* return the basis maps if necessary */
  if( cntrl->storeMap[isBasis] ) {
    if( iOut >= nlhs )
      mexErrMsgTxt( "Too few output arguments" );

    dims[0] = cntrl->nScale;
    dims[1] = NUMBASIS;
    plhs[iOut] = mxCreateCellArray( 2, dims );

    for( iScale = 0; iScale < cntrl->nScale; iScale++ ) {
      for( iBasis = 0; iBasis < NUMBASIS; iBasis++ ) {
	iChannel = NUMBASIS*iScale + iBasis;
	dims[0] = iScale;
	dims[1] = iBasis;
	float2mex( fp->basisMap[iChannel], &mxTmp, 
		   fp->nxFilt[iScale], 
		   fp->nyFilt[iScale] );
	iCell = mxCalcSingleSubscript( plhs[iOut], 2, dims ); 
	mxSetCell( plhs[iOut], iCell, mxTmp );
      }
    }

    iOut++;
  }

  /* return the pyramid maps if necessary */
  if( cntrl->storeMap[isPyr] ) {
    if( iOut >= nlhs )
      mexErrMsgTxt( "Too few output arguments" );

    dims[0] = cntrl->nPyr;
    plhs[iOut] = mxCreateCellArray( 1, dims );

    for( iScale = 0; iScale < cntrl->nPyr; iScale++ ) {
      dims[0] = iScale;
      float2mex( fp->pyrMap[iScale], &mxTmp, 
		 fp->nxPyr[iScale], 
		 fp->nyPyr[iScale] );
      iCell = mxCalcSingleSubscript( plhs[iOut], 1, dims ); 
      mxSetCell( plhs[iOut], iCell, mxTmp );
    }

    iOut++;
  }

  /* free the pyramid, etc. */
  freeFreemanPyramid( fp );

  utilFree( (void **)&fp );
  utilFree( (void **)&cntrl );
  utilFree( (void **)&fpcc );

  return;
}

