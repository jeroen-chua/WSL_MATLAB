%mex -O -c -largeArrayDims dllmain.c
%mex -O -largeArrayDims filterImage.c

mex -O -c -largeArrayDims -v COMPFLAGS="\$CC= gcc -O2 -DNDEBUG -DMATLAB_MEX_FILE -fPIC" LFLAGS="-lm" "LD= gcc" utils.c utils.h
mex -O -c -largeArrayDims -v COMPFLAGS="\$CC= gcc -O2 -DNDEBUG -DMATLAB_MEX_FILE -fPIC" LFLAGS="-lm" "LD= gcc" mextools.c mextools.h
mex -O -c -largeArrayDims -v COMPFLAGS="\$CC= gcc -O2 -DNDEBUG -DMATLAB_MEX_FILE -fPIC" LFLAGS="-lm" "LD= gcc" phaseUtil.c
mex -O -c -largeArrayDims -v COMPFLAGS="\$CC= gcc -O2 -DNDEBUG -DMATLAB_MEX_FILE -fPIC" LFLAGS="-lm" "LD= gcc" imageFile-io.c
mex -O -c -largeArrayDims -v COMPFLAGS="\$CC= gcc -O2 -DNDEBUG -DMATLAB_MEX_FILE -fPIC" LFLAGS="-lm" "LD= gcc" freemanPyramid.c utils.h phase.h phaseUtil.o freemanPyramid.h mextools.o

mex -O -largeArrayDims -v COMPFLAGS="\$CC= gcc -O2 -DNDEBUG -DMATLAB_MEX_FILE -fPIC" LFLAGS="-lm" "LD= gcc" mexFunction.c freemanPyramid.o macros.h mextools.o utils.o phaseUtil.o imageFile-io.o -o freemanPyramid