Setup/usage instructions:

Note: For clarity, it will be assume that the WSL code is located in $rootDir/WSL/


1) Compiling mex code

This WSL code uses .mex functions to compute the Freeman pyramid phase coefficients; this code must be compiled on your machine. To compile the code, open MATLAB, first navigate to $rootDir/WSL/appearModels/phase/filtering, and if your mex options are not setup, type "mex -setup" and follow the onscreen instructions. Finally, type "make" in MATLAB to compile the code.

There are 2 already-compiled mex functions that could be of use, if you have problems with the above instructions. They are:

freemanPyramid.mexa64 => for 64-bit Ubuntu, Linux
freemanPyramid.mexa64 => for Windows7

Use these files only as a last resort! It is a much better idea to compile the code yourself, if you can.

2) Running the code

The entry function for running the WSL code is $rootDir/WSL/main.m. The function signature is: main(dataset,nHalf,nFrames) where...

dataset: an integer indicating the dataset to be run on (see Section 4 setting up datasets for more info)

nHalf: the half-life to be used for adaptation by the WSL apeparance model. This is n_s in the CVPR paper.

nFrames: an optional parameter for how many frames of the video sequence to track for. If unspecified, the code will track for all given frames.

3) Changing parameters (besides half-life):

All model parameters are set in the function $rootDir/WSL/initParams.m. The comments in that function explain all the model parameters that can be changed.

4) Setting up new datasets

All datasets should be rooted at $rootDir/Data (note relation to the WSL code). To add a new dataset, follow these steps:

i) Ensure all data is scaled in range [0,256]. This is absolutely critical, or else parameters in the code will not work as intended (eg, value for "rock bottom" in initparams.m/getFilterParams()). Note that the data is re-scaled to range [0,1] by the WSL code itself; there is no need to do this yourself.

ii) All frames fo the sequence are expected to follow the format: frame_%0.4d.jpg. Note the .jpg extension, and the 4-digit frame number. For example: "frame_0003.jpg" should be used as the name of Frame 3. Frames are numbered starting from 1 (frame_0001.jpg) and frame numbering must be sequential.

iii) Root the video sequence (recall, .jpg files scaled [0,256], starting from frame_0001.jpg) somewhere under $rootDir/Data/.

iv) Go to $rootDir/WSL/getData/setDataParams.m and insert the path of your dataset sequence, and other information. You must specify: 1) an integer to refer to your dataset by (this will be used when calling "main" to tell it to track your sequence), 2) the dataFolder under $rootDir/Data/ where your sequence lies (eg, the code will look for your sequence under $rootDir/Data/$dataFolder), 3) the total number of frames your sequence has, 4) the initial pose in the first frame. Pose is formatted as [y-origin,x-origin,major-axis,minor-axis, rotation]^T. You may specify the pose either in the setDataParams() function (see dataset cases 1-5), or in the $dataFolder as "pose.mat", with the pose variable being named "pose". See $rootDir/Data/VTD_data_images/animal for an example.

5) Viewing results

The function $rootDir/WSL/viewOverlays.m is used to view results. The function signature is: viewOverlays(folderUse,nHalf,nFrames), where...

folderUse: the folder the results are kept in
nHalf: the half-life used for the experiment
nFrames: optional number of frame sequences to display. If unspecified, tracking results are displayed for all available frames of the sequence

What is shown in Figure 1:
There are 3 panels; the left panel is the original image, the middle panel is the original image, but with only the tracked-region shown, and the right panel is the tracked region warped to a canonical coordinate frame. Note that if tracking is perfect, the right panel should show the stabilized object.

What is shown in Figure 2:
The mixing coefficients of the W,S,L appearance model components, for all orientations and scales. The visualization is in RGB => WSL, so red pixels indicate wandering component-dominated tracking, green indicates stable component-dominated tracking, and blue indicates a lost pixel. Note that to save memory, the appearance model is NOT saved at all frames; rather, it is only saved every 4 frames, and so this figure is updated only every 4 frames.
