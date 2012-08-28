# include "macros.h"
# include "utils.h"
# include "imageFile-io.h"
# include "phase.h"
# include "freemanPyramid.h"
# include "phaseUtil.h"
# include "dumpFilterImages.h"

/* Helper function prototype */
int readInputParams(char *pathNameCache, char *rootNameCache,
		    char *pathNameOutput, char *outputFileRoot,
		    int *pnOrient, float *thetaDeg,
		    int *pnScale, float *lambda);

/*** Flags for dumping intermediate filter results ***********/
static int dumpMap[NUMCODE] = { 1, 1, 1, 1, 0, 1};
/* The order (left to right) here is:
     grad, phase, amp, filter, basis, and pyramid images.
   Zeroes indicate that the corresponding image is NOT to be dumped. */


int main(argc, argv)
 int argc;
 char **argv;
 {
  FreemanPyramidStruct *fp;
  FreemanCacheCntrlStruct *fpcc;
  unsigned char *image;
  float epsAmp, epsC;
  int nHead, nxImage, nyImage, nImages, size, imFirst, imLast, pad, k;

  char inpath[MAXLEN], fnInput[MAXLEN], fnInputRoot[MAXLEN];
  char fileType[MAXLEN], numExt[MAXLEN];
  char pathNameOutput[MAXLEN], outputFileRoot[MAXLEN], fnCurr[MAXLEN];
  FILE *fpIn;


  /**************** Read image input parameters **********/
  /* Get Input File Info */
  fprintf(stderr," enter pathname for input images: ");
  scanf("%s", inpath);
  fprintf(stderr, "image file type (pgm, ppm, or raw) and  root filename ");
  scanf("%s %s", fileType, fnInputRoot);

  /* Initialize Pyramid Params and data Structure */
  fp = newFreemanPyramidStruct((FreemanPyramidCntrlStruct *)NULL);
  fpcc = defaultFreemanCacheCntrlStruct();

  /**************** Read filter input parameters **********/
  readInputParams(fpcc->pathNameCache, fpcc->rootNameCache,
		  pathNameOutput, outputFileRoot,
		  &(fp->cntrl->nOrient), fp->cntrl->thetaDeg,
                  &(fp->cntrl->nScale), fp->cntrl->lambda);
  fprintf(stderr, "done reading\n\n");

  /* Set up FreemanPyramidStruct.storeMap, which defines the filter response 
     maps to be computed and returned. The order here is:
          grad, phase, amp, filter, basis, and pyramid images.
     Zeroes mean the information is NOT to be computed/retrieved. */
  for(k=0; k<NUMCODE; k++) { fp->cntrl->storeMap[k] = 0; }
  for(k=0; k<NUMCODE; k++) { if (dumpMap[k]) fp->cntrl->storeMap[k] = 1; }

  epsAmp = 3; epsC = 0.0;

  strcpy(fnInput,fnInputRoot);
  strcpy(fnCurr,inpath);
  strcat(fnCurr,fnInput); 
  strcat(fnCurr,"."); 
  strcat(fnCurr,fileType);

  if ((fpIn = fopenInputFile(fnCurr)) == NULL)
  error("Cannot open image file",fnCurr);
  
  if (strcmp(fileType, "pgm") == 0) {
    read_pgm_image(&image, fpIn, fnCurr, &nxImage, &nyImage);
    fclose(fpIn);
  } else if (strcmp(fileType, "ppm") == 0) { /* expect ppm input image */
    unsigned char *cImage[3];
    if (read_ppm_image(cImage, fpIn, fnInput, 
		       &nxImage, &nyImage) < 0)
      error("readInputParams: Cannot read ppm image file", fnInput);
    fprintf(stderr, "Using green channel only.\n");
    image = cImage[1];
    free(cImage[0]);
    free(cImage[2]);
    fclose(fpIn);
  } else if (strcmp(fileType, "raw") == 0) {
    fprintf(stderr, "input image size: nHeader, nx, ny :");
    scanf("%d %d %d", &nHead, &nxImage, &nyImage);
    grabByteMemory((char **) image, nxImage * nyImage, fnInput);
    read_byte_image_strip_bytes(image,fpIn,fnCurr,nxImage,nyImage,nHead);
    fclose(fpIn);
  } else {
    error("readInputParams: Unrecognized file type for", fnInput);
  }

  strcpy(fpcc->rootNameCache,fnInput);
  recoverFreemanPyramid_Byte(fp,image,nxImage,nyImage,epsAmp,epsC,fpcc);

  fprintf(stderr,"out path and root: %s %s", pathNameOutput, fnInput); 
  dumpFilterImages(pathNameOutput, fnInput, fp, dumpMap, PFM_DUMP_TYPE );  
  // dumpFilterImages(pathNameOutput, fnInput, fp, dumpMap, PGM_DUMP_TYPE );  
} 


/*==========================================================================*/
int readInputParams(char *pathNameCache, char *rootNameCache,
		    char *pathNameOutput, char *outputFileRoot,
		    int *pnOrient, float *thetaDeg,
                    int *pnScale, float *lambda)
{
  char fileType[MAXLEN];
  int iOrient, iScale, nHead;
  int nxImage, nyImage;
  int nOrient, nScale;
  FILE *fpIn;

  fprintf(stderr, "Cache files:\n    Input path, rootname:\n    ");
  if (read_file_path_and_root(pathNameCache, rootNameCache) == EOF)
   exit(0);

  fprintf(stderr, "Filter Output files:\n");
  fprintf(stderr, "    pathName and fileRoot\n");
  if (read_file_path_and_root(pathNameOutput, outputFileRoot) == EOF)
   exit(0);

  /** Read wavelengths and steering orientations **/

  fprintf(stderr, " enter number of orientations (<=%d) ", NUMORIENT);
  fprintf(stderr, "and steering directions (degrees):\n");
  if (scanf("%d",&nOrient) == EOF)
   exit(0);
  if (nOrient > NUMORIENT)
   error(" NUMORIENT (in phase.h) too small","");
  if (nOrient<=0)
    exit(0);
  for(iOrient=0; iOrient<nOrient; iOrient++) 
    scanf("%e", thetaDeg+iOrient);

  nScale = 0;
  fprintf(stderr," enter number of scales, and lambdas (increasing):\n");
  if (scanf("%d",&nScale) == EOF)
   exit(0);
  if (index(nOrient-1, nScale-1, nOrient) >= NUMCHANNEL)
   error(" NUMCHANNEL (in phase.h) too small for desired number of scales","");
  if (nScale<=0)
   exit(0);

  for(iScale=0; iScale<nScale; iScale++) {
   if (scanf("%e",lambda+iScale)==EOF)
    error(" EOF while reading lambdas","");
   if (lambda[iScale]< 2.0) {
    fprintf(stderr, " lambda[%d] = %e\n", iScale, lambda[iScale]);
    error(" lambda must be larger than 2 (preferably, lambda >= 4)","");
   }
   if (iScale>0 && lambda[iScale]<= lambda[iScale-1]) 
    error(" lambdas must be increasing","");
  }

  *pnOrient = nOrient;
  *pnScale = nScale;

  return(0);
 }

