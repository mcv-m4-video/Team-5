function HS_MarkII

dbstop if error

% Input images
Data{1}.im = imread('../../Datasets/OpticalFlow_Dataset/im000157_10.png');
Data{2}.im = imread('../../Datasets/OpticalFlow_Dataset/im000157_11.png');

%% Ground truth results
im_GT = imread('../../Datasets/OpticalFlow_Dataset/noc000157_10.png');

% revert operation
F_uGT = (im_GT(:,:,1)-2^15)/64;
F_vGT = (im_GT(:,:,2)-2^15)/64;
F_validGT = min(im_GT(:,:,3),1);
F_uGT(F_validGT==0) = 0;
F_vGT(F_validGT==0) = 0;


%% Obtained results

% Create optical flow object.
opticFlow = opticalFlowHS;

% Estimate the optical flow of objects in the video.
for i = 1:length(Data)
    
    flow = estimateFlow(opticFlow,Data{i}.im);
    
    imshow(Data{i}.im)
    hold on
    plot(flow,'DecimationFactor',[5 5],'ScaleFactor',25)
    hold off
end

%% Mean magnitude error (Task4)
F_uR = flow.Vx; F_vR = flow.Vy;
F_uR(F_validGT==0) = 0;
F_vR(F_validGT==0) = 0;

Diff = (double(F_uGT) - double(F_uR)).^2 + (double(F_vGT) - double(F_vR)).^2;
MMEVal = sum(sum((Diff))) ./ length(find(F_validGT == 1));

%% Percentage of Erroneous Pixels (Task5)

NumError = find(sqrt(Diff) > 3);
PEPN = length(NumError)/(length(find(F_validGT == 1))) * 100;

[MMEVal, PEPN]
TheEnd = 1;



% 
% %% Task7
% % downsize u and v
% u_deci = im_GT(1:10:end, 1:10:end, 1);
% v_deci = im_GT(1:10:end, 1:10:end, 2);
% % get coordinate for u and v in the original frame
% [m, n, d] = size(im_GT);
% [X,Y] = meshgrid(1:n, 1:m);
% X_deci = X(1:10:end, 1:10:end);
% Y_deci = Y(1:10:end, 1:10:end);
% 
% SourceInPath = 'F:\Computer_Vision\MCV_Course\Assignment\M4\Week1\data_stereo_flow\training\image_0\';
% OrigIm = imread([SourceInPath, '000045_11.png']);
% figure();
% imshow(OrigIm);
% hold on;
% % draw the velocity vectors
% quiver(X_deci, Y_deci, u_deci,v_deci, 'y')
% 
% 
