
%%%%%----------------------------Task 1 and 2--------------------------%%%%
% the results directory 
results_dir = './results/highway';

%the ground truth directory
gt_results_dir = '../highway/groundtruth' ;

% initial the values to 0
pixelTP_A=0; pixelFN_A=0; pixelFP_A=0; pixelTN_A=0;
pixelTP_B=0; pixelFN_B=0; pixelFP_B=0; pixelTN_B=0;

% read the file names
files = ListFiles(results_dir);

for i=1:size(files,1),
    
    i
    % Read results file
    im = imread(strcat(results_dir,'/',files(i).name));
    
    % seperate test A and testB
    if strfind(files(i).name, 'A')
        
        % obtain the image names in test A
        file_name = strtok(files(i).name, 'test_A_');
        
        % read the ground truth images 
        gt = imread(strcat(gt_results_dir,'/','gt',file_name));
        
        % it's for task2, write a specifity image
        if  strcmp(file_name,'001201.png')
            imwrite(gt,'gt001201.png')
            imwrite(im.*255,'test_A_001201.png')
        end
        
        % compute the TP FP FN and TN
        [localPixelTP, localPixelFP, localPixelFN, localPixelTN] = PerformanceAccumulationPixel(im, gt);
        pixelTP_A = pixelTP_A + localPixelTP;
        pixelFP_A = pixelFP_A + localPixelFP;
        pixelFN_A = pixelFN_A + localPixelFN;
        pixelTN_A = pixelTN_A + localPixelTN;
        
    else
        % obtain the image names in test B
        file_name = strtok(files(i).name, 'test_B_');
        gt = imread(strcat(gt_results_dir,'/','gt',file_name));
        
        
        % it's for task2, write a specifity image
        if strcmp(file_name,'001201.png')
            imwrite(im.*255,'test_B_001201.png')
        end
        
        % compute the TP FP FN and TN
        [localPixelTP, localPixelFP, localPixelFN, localPixelTN] = PerformanceAccumulationPixel(im, gt);
        pixelTP_B = pixelTP_B + localPixelTP;
        pixelFP_B = pixelFP_B + localPixelFP;
        pixelFN_B = pixelFN_B + localPixelFN;
        pixelTN_B = pixelTN_B + localPixelTN;
        
    end
    
    
end

% test A : performance evaluation 
[pixelPrecision_A, pixelAccuracy_A, pixelSpecificity_A, pixelSensitivity_A] = PerformanceEvaluationPixel(pixelTP_A, pixelFP_A, pixelFN_A, pixelTN_A);
F1_A = 2*  pixelPrecision_A * pixelSensitivity_A/(pixelPrecision_A + pixelSensitivity_A);

% test B : performance evaluation 
[pixelPrecision_B, pixelAccuracy_B, pixelSpecificity_B, pixelSensitivity_B] = PerformanceEvaluationPixel(pixelTP_B, pixelFP_B, pixelFN_B, pixelTN_B);
F1_B = 2*  pixelPrecision_B * pixelSensitivity_B/(pixelPrecision_B + pixelSensitivity_B);
