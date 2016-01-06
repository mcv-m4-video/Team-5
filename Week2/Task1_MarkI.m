%%%%%%%--------------------------Gaussian modeling-------------------------
dbstop if error
% GT -- Ground Truth.

%% Read all pixel data and make a multi dimensional image

% HIGHWAY
for i = 1050+1:1350
    HIGHWAY(:,:,i-1051+1) = rgb2gray(imread(['../../Datasets/highway/input/in00' sprintf('%0.4d', i) '.jpg']));
    GTHIGHWAY(:,:,i-1051+1) = imread(['../../Datasets/highway/groundtruth/gt00' sprintf('%0.4d', i) '.png']) == 255;
end
HIGHWAY = double(HIGHWAY);

% FALL
for i = 1461:1560
    FALL(:,:,i-1461+1) = rgb2gray(imread(['../../Datasets/fall/input/in00' sprintf('%0.4d', i) '.jpg']));
    GTFALL(:,:,i-1461+1) = imread(['../../Datasets/fall/groundtruth/gt00' sprintf('%0.4d', i) '.png']) == 255;
end
FALL = double(FALL);

% TRAFFIC
for i = 951:1050
    TRAFFIC(:,:,i-951+1) = rgb2gray(imread(['../../Datasets/traffic/input/in00' sprintf('%0.4d', i) '.jpg']));
    GTTRAFFIC(:,:,i-951+1) = imread(['../../Datasets/traffic/groundtruth/gt00' sprintf('%0.4d', i) '.png']) == 255;
end
TRAFFIC = double(TRAFFIC);


%% Compute mean and variance for each pixel for first 50% frames
% Task 1.1

% HIGHWAY
MeanHIGHWAY = mean(HIGHWAY(:,:,1:size(HIGHWAY, 3)/2), 3);
VarHIGHWAY = std(HIGHWAY(:,:,1:size(HIGHWAY, 3)/2), 0, 3);
 
% FALL
MeanFALL = mean(FALL(:,:,1:size(FALL, 3)/2), 3);
VarFALL = std(FALL(:,:,1:size(FALL, 3)/2), 0, 3);

% TRAFFIC
MeanTRAFFIC = mean(TRAFFIC(:,:,1:size(TRAFFIC, 3)/2), 3);
VarTRAFFIC = std(TRAFFIC(:,:,1:size(TRAFFIC, 3)/2), 0, 3);

%% Testing with other half of frames
% Task 1.2, 2

Count = 1;
for Alpha = [0.1:0.1:15]
    % Highway
    alphaH = Alpha;
    TIHighway = HIGHWAY(:,:,(size(HIGHWAY, 3)/2)+1:size(HIGHWAY, 3));
    TRHighway = abs((TIHighway - repmat(MeanHIGHWAY, [1, 1, size(TIHighway, 3)]))) >= ...
        alphaH*(repmat(VarHIGHWAY, [1, 1, size(TIHighway, 3)]) + 2);
    
    [pixelTPH(Count), pixelFPH(Count), pixelFNH(Count), pixelTNH(Count)] = PerformanceAccumulationPixel(TRHighway, GTHIGHWAY(:, :, 151:300));
    [pixelPrecisionH(Count), pixelAccuracyH(Count), pixelSpecificityH(Count), pixelSensitivityH(Count)] = ...
        PerformanceEvaluationPixel(pixelTPH, pixelFPH, pixelFNH, pixelTNH);
    F1_H(Count) = 2*  pixelPrecisionH(Count) * pixelSensitivityH(Count)/(pixelPrecisionH(Count) + pixelSensitivityH(Count));
    
    % Fall
    alphaF = Alpha;
    TIFall = FALL(:,:,(size(FALL, 3)/2)+1:size(FALL, 3));
    TRFall = abs((TIFall - repmat(MeanFALL, [1, 1, size(TIFall, 3)]))) >= ...
        alphaF*(repmat(VarFALL, [1, 1, size(TIFall, 3)]) + 2);
    
    [pixelTPF(Count), pixelFPF(Count), pixelFNF(Count), pixelTNF(Count)] = PerformanceAccumulationPixel(TRFall, GTFALL(:, :, 51:100));
    [pixelPrecisionF(Count), pixelAccuracyF(Count), pixelSpecificityF(Count), pixelSensitivityF(Count)] = ...
        PerformanceEvaluationPixel(pixelTPF(Count), pixelFPF(Count), pixelFNF(Count), pixelTNF(Count));
    F1_F(Count) = 2*  pixelPrecisionF(Count) * pixelSensitivityF(Count)/(pixelPrecisionF(Count) + pixelSensitivityF(Count));
    
    % Traffic
    alphaT = Alpha;
    TITraffic = TRAFFIC(:,:,(size(TRAFFIC, 3)/2)+1:size(TRAFFIC, 3));
    TRTraffic = abs((TITraffic - repmat(MeanTRAFFIC, [1, 1, size(TITraffic, 3)]))) >= ...
        alphaT*(repmat(VarTRAFFIC, [1, 1, size(TITraffic, 3)]) + 2);
    
    [pixelTPT(Count), pixelFPT(Count), pixelFNT(Count), pixelTNT(Count)] = PerformanceAccumulationPixel(TRTraffic, GTTRAFFIC(:, :, 51:100));
    [pixelPrecisionT(Count), pixelAccuracyT(Count), pixelSpecificityT(Count), pixelSensitivityT(Count)] = ...
        PerformanceEvaluationPixel(pixelTPT(Count), pixelFPT(Count), pixelFNT(Count), pixelTNT(Count));
    F1_T(Count) = 2*  pixelPrecisionT(Count) * pixelSensitivityT(Count)/(pixelPrecisionT(Count) + pixelSensitivityT(Count));
    Count = Count + 1;
end

figure(1);hold on; title(' TP, TN, FP, FN for Highway')
plot(pixelTPH, 'r')
plot(pixelFPH, 'g')
plot(pixelFNH, 'b')
plot(pixelTNH, 'k')
legend('TP','FP','FN','TN');

figure(2);hold on; title(' TP, TN, FP, FN for Fall')
plot(pixelTPF, 'r')
plot(pixelFPF, 'g')
plot(pixelFNF, 'b')
plot(pixelTNF, 'k')
legend('TP','FP','FN','TN');

figure(3);hold on; title(' TP, TN, FP, FN for Traffic')
plot(pixelTPT, 'r')
plot(pixelFPT, 'g')
plot(pixelFNT, 'b')
plot(pixelTNT, 'k')
legend('TP','FP','FN','TN');

figure(4); hold on; title('Precision, Recall, F1 vs alpha of Highway')
plot(pixelPrecisionH,'--r')
plot(pixelSensitivityH,'--g')
plot(F1_H,'--b')
legend('Precision','Recall','F1');

figure(5); hold on; title('Precision, Recall, F1 vs alpha of Fall')
plot(pixelPrecisionF,':r')
plot(pixelSensitivityF,':g')
plot(F1_F,':b')
legend('Precision','Recall','F1');

figure(6); hold on; title('Precision, Recall, F1 vs alpha of Traffic')
plot(pixelPrecisionT,'-.r')
plot(pixelSensitivityT,'-.g')
plot(F1_T,'-.b')
legend('Precision','Recall','F1');

% Task 3 (AUC)
figure(7); hold on; title('Precision vs recall  curve')
plot(pixelSensitivityH, pixelPrecisionH,'-.r')
plot(pixelSensitivityF,pixelPrecisionF ,'-.g')
plot(pixelSensitivityT,pixelPrecisionT ,'-.b')
axis([0 1 0 1])
legend(sprintf('Highway Area %5.4f',areaH),sprintf('Fall Area %5.4f',areaF),sprintf('Traffic Aera %5.4f',areaT));
areaH = trapz(pixelSensitivityH,pixelPrecisionH);
areaF = trapz(pixelSensitivityF,pixelPrecisionF);
areaT = trapz(pixelSensitivityT,pixelPrecisionT);
TheEnd = 1;