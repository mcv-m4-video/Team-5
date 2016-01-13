clc
clearvars
close all

dataset = 'traffic';

for i = 1050+1:1350
    HIGHWAY(:,:,:,i-1051+1) = (imread(['../Datasets/' sprintf(dataset) '/input/in00' sprintf('%0.4d', i) '.jpg']));
    GTHIGHWAY(:,:,i-1051+1) = imread(['../Datasets/' sprintf(dataset) '/groundtruth/gt00' sprintf('%0.4d', i) '.png']) == 255;
    SHADOWHIGHWAY(:,:,i-1051+1) = imread(['../Datasets/' sprintf(dataset) '/groundtruth/gt00' sprintf('%0.4d', i) '.png']) == 50;
    MOTIONHIGHWAY(:,:,i-1051+1) = imread(['../Datasets/' sprintf(dataset) '/groundtruth/gt00' sprintf('%0.4d', i) '.png']) == 255 | ...
        imread(['../Datasets/' sprintf(dataset) '/groundtruth/gt00' sprintf('%0.4d', i) '.png']) == 50 ;
%     BGHIGHWAY(:,:,i-1051+1) = imread(['../../Datasets/highway/groundtruth/gt00' sprintf('%0.4d', i) '.png']) == 0 | ...
%         imread(['../../Datasets/highway/groundtruth/gt00' sprintf('%0.4d', i) '.png']) == 50 ;
end
HIGHWAY = im2double(HIGHWAY);
GTHIGHWAY = im2double(GTHIGHWAY);
SHADOWHIGHWAY = im2double(SHADOWHIGHWAY);
MOTIONHIGHWAY = im2double(MOTIONHIGHWAY);

MeanHIGHWAY = mean(HIGHWAY(:,:,:,1:size(HIGHWAY, 4)/2), 4);
VarHIGHWAY =   var(HIGHWAY(:,:,:,1:size(HIGHWAY, 4)/2), 0, 4);

% (0 < a < b < 1)
alpha = 0.2;%alpha is lower when in sunny environment
beta = 0.6;%sensitivity to noise
s_threshold = 0.1;
h_threshold = 0.1;
BackgroundImageHSV = rgb2hsv(MeanHIGHWAY);%MEAN OF THE VIDEO
epsilon = 0.0001;
for i = 1:size(SHADOWHIGHWAY,3)
    
   shadow_gt = SHADOWHIGHWAY(:,:,i);%ground truth for shadow
   motion_gt = MOTIONHIGHWAY(:,:,i);%motion+shadow (OUR SEGMENTED FOREGROUND)
   
   img = HIGHWAY(:,:,:,i);
   img_hsv = rgb2hsv(img);
   
   Statement1 = img_hsv(:,:,1) ./ (BackgroundImageHSV(:,:,1) + epsilon);
   Statement1(Statement1 > 1) = 0;
   
   Statement2 = img_hsv(:,:,2) - BackgroundImageHSV(:,:,2);
   
   Statement3 = abs(img_hsv(:,:,3) - BackgroundImageHSV(:,:,3));
   normStatement3 = (Statement3-min(Statement3(:))) / (max(Statement3(:)) - min(Statement3(:)));
   
   shadowmask = (motion_gt) & (Statement1 >= alpha) & (Statement1 <= beta) & (Statement2 <= s_threshold) & (normStatement3 <= h_threshold);
   eliminatedShadow = motion_gt - shadowmask;
   
%    figure(1);imshow(img_hsv);
%    figure(2);imshow(BackgroundImageHSV);

   
   figure(1)
   subplot(1,3,1), subimage(eliminatedShadow);
   subplot(1,3,2), subimage(shadow_gt);
   subplot(1,3,3), subimage(motion_gt);

    
end