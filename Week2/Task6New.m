clearvars
close all

%%%%%%%%%
% HIGHWAY
% for i = 1050+1:1350
%     HIGHWAY(:,:,i-1051+1) = rgb2gray(imread(['Datasets/highway/input/in00' sprintf('%0.4d', i) '.jpg']));
%     GTHIGHWAY(:,:,i-1051+1) = imread(['Datasets/highway/groundtruth/gt00' sprintf('%0.4d', i) '.png']) == 255;
% end
% HIGHWAY = double(HIGHWAY);
% 
% FALL
for i = 1461:1560
    FALL(:,:,i-1461+1) = rgb2gray(imread(['Datasets/fall/input/in00' sprintf('%0.4d', i) '.jpg']));
    GTFALL(:,:,i-1461+1) = imread(['Datasets/fall/groundtruth/gt00' sprintf('%0.4d', i) '.png']) == 255;
end
FALL = double(FALL);
% 
% % TRAFFIC
% for i = 951:1050
%     TRAFFIC(:,:,i-951+1) = rgb2gray(imread(['Datasets/traffic/input/in00' sprintf('%0.4d', i) '.jpg']));
%     GTTRAFFIC(:,:,i-951+1) = imread(['Datasets/traffic/groundtruth/gt00' sprintf('%0.4d', i) '.png']) == 255;
% end
% TRAFFIC = double(TRAFFIC);
%%%%%%%%%%%%%%

videoSource1 = vision.VideoFileReader('inihighwayvideo.avi','ImageColorSpace','Intensity','VideoOutputDataType','uint8');
videoSource2 = vision.VideoFileReader('inifallvideo.avi','ImageColorSpace','Intensity','VideoOutputDataType','uint8');
videoSource3 = vision.VideoFileReader('initrafficvideo.avi','ImageColorSpace','Intensity','VideoOutputDataType','uint8');

detector1 = vision.ForegroundDetector(...
    'NumTrainingFrames', 150, ...
    'NumGaussians', 3, ...
    'InitialVariance', 30*30);

detector2 = vision.ForegroundDetector(...
    'NumTrainingFrames', 50, ...
    'NumGaussians', 3, ...
    'LearningRate', 0.002, ...
    'InitialVariance', 30*30);

detector3 = vision.ForegroundDetector(...
    'NumTrainingFrames', 50, ...
    'NumGaussians', 3, ...
    'InitialVariance', 30*30);

% HighWayFGSave = zeros(240,320,300);
% count = 1;
% while ~isDone(videoSource1)
%     frame  = step(videoSource1);
%     HighWayFGSave(:,:,count) = step(detector1, frame);
%     count = count + 1;
% end
% release(videoSource1);
% 
% [pixelTPH, pixelFPH, pixelFNH, pixelTNH]...
%     = PerformanceAccumulationPixel(HighWayFGSave(:,:,151:300), GTHIGHWAY(:, :, 151:300));
% [pixelPrecisionH, ~, ~, pixelSensitivityH] = ...
%     PerformanceEvaluationPixel(pixelTPH, pixelFPH, pixelFNH, pixelTNH);
% F1_H = 2*  pixelPrecisionH * pixelSensitivityH/(pixelPrecisionH + pixelSensitivityH);
% 
% Junk = 1;
% 
FallFGSave = zeros(480,720,100);
count = 1;
while ~isDone(videoSource2)
    frame = step(videoSource2);
    FallFGSave(:,:,count) = step(detector2, frame);
    count = count + 1;
end
release(videoSource2);


[pixelTPF, pixelFPF, pixelFNF, pixelTNF] = ...
    PerformanceAccumulationPixel(FallFGSave(:,:,51:100), GTFALL(:, :, 51:100));
[pixelPrecisionF, ~, ~, pixelSensitivityF] = ...
    PerformanceEvaluationPixel(pixelTPF, pixelFPF, pixelFNF, pixelTNF);
F1_F = 2*  pixelPrecisionF * pixelSensitivityF/(pixelPrecisionF + pixelSensitivityF);
fprintf('F1 Fall = %f\n', F1_F); 

Junk = 1;
% 
% TrafficFGSave = zeros(240,320,100);
% count = 1;
% while ~isDone(videoSource3)
%     frame = step(videoSource3);
%     TrafficFGSave(:,:,count) = step(detector3, frame);
%     count = count + 1;
% end
% release(videoSource3);
% 
% [pixelTPT, pixelFPT, pixelFNT, pixelTNT] =...
%     PerformanceAccumulationPixel(TrafficFGSave(:,:,51:100), GTTRAFFIC(:, :, 51:100));
% [pixelPrecisionT, ~, ~, pixelSensitivityT] = ...
%     PerformanceEvaluationPixel(pixelTPT, pixelFPT, pixelFNT, pixelTNT);
% F1_T = 2*  pixelPrecisionT * pixelSensitivityT/(pixelPrecisionT + pixelSensitivityT);
% 
% 
% Junk = 1;

videoPlayer = vision.VideoPlayer();
while ~isDone(videoSource2)
     frame  = step(videoSource2);
     fgMask = step(detector2, frame);
     %bbox   = step(blob, fgMask);
     %out    = step(shapeInserter, frame, bbox);
     %step(videoPlayer, out);
     step(videoPlayer, fgMask);
end