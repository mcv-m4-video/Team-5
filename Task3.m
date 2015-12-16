
%%%%%----------------------------Task 3--------------------------%%%%
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
        
        % compute the TP FP FN and TN
        [localPixelTP, localPixelFP, localPixelFN, localPixelTN] = PerformanceAccumulationPixel(im, gt);
        % test A : performance evaluation
        [pixelPrecision_A, pixelAccuracy_A, pixelSpecificity_A, pixelSensitivity_A] = PerformanceEvaluationPixel(localPixelTP, localPixelFP, localPixelFN, localPixelTN);
        F1_A(i) = 2*  pixelPrecision_A * pixelSensitivity_A/(pixelPrecision_A + pixelSensitivity_A);
        
        gt = gt>0;
        localtp_A(i)=localPixelTP;
        foreground_num_A(i)=sum(sum(gt));       
        
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
        % test A : performance evaluation
        [pixelPrecision_B, pixelAccuracy_B, pixelSpecificity_B, pixelSensitivity_B] = PerformanceEvaluationPixel(localPixelTP, localPixelFP, localPixelFN, localPixelTN);
        F1_B(i-200) = 2*  pixelPrecision_B * pixelSensitivity_B/(pixelPrecision_B + pixelSensitivity_B);
        
        gt = gt>0;
        localtp_B(i-200)=localPixelTP;
        foreground_num_B(i-200)=sum(sum(gt));   
        
    end
    
    
end

% test A : plot True Positive & Total Foreground pixels vs #frame
i=1:200;
figure
plot(i,localtp_A,i,foreground_num_A)
title('Test A : TP & Total Foreground pixels vs #frame')
xlabel('#frame')
ylabel('#pixels')
legend('True Positive',' Foreground pixels')

% test A : plot F1 vs #frame
figure
plot(i,F1_A)
title('Test A : F1 vs #frame')
xlabel('#frame')
ylabel('#F1')

% test B : plot True Positive & Total Foreground pixels vs #frame
figure
plot(i,localtp_B,i,foreground_num_B)
title('Test B : TP & Total Foreground pixels vs #frame')
xlabel('#frame')
ylabel('#pixels')
legend('True Positive',' Foreground pixels')


% test B: plot F1 vs #frame
figure
plot(i,F1_B)
title('Test B : F1 vs #frame')
xlabel('#frame')
ylabel('#F1')
