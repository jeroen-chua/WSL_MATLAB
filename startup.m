RandStream.setDefaultStream(RandStream('mt19937ar', 'seed', 100*sum(clock)))
addpath(genpath('cropper'));
addpath(genpath('appearModels'));
addpath(genpath('utils'));
addpath(genpath('imwarpUtils'));
addpath(genpath('getData'));
addpath(genpath('viewRes'));
addpath(genpath('probCalc'));
addpath(genpath('fitFlow'));