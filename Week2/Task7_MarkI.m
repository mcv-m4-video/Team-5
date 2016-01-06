%%%%%%%--------------------------Gaussian modeling-------------------------
% dbstop if error
% GT -- Ground Truth.

%% Read all pixel data and make a multi dimensional image

% HIGHWAY
HIGHWAY=zeros(240,320,3,300);
GTHIGHWAY=zeros(240,320,3,300);
for i = 1050+1:1350
    HIGHWAY(:,:,:,i-1051+1) = imread(['../../Datasets/highway/input/in00' sprintf('%0.4d', i) '.jpg']);
    GTHIGHWAY(:,:,i-1051+1) = imread(['../../Datasets/highway/groundtruth/gt00' sprintf('%0.4d', i) '.png']) == 255;
end
HIGHWAY = double(HIGHWAY);

% FALL
FALL=zeros(480,720,3,100);
GTFALL=zeros(480,720,3,100);
for i = 1461:1560
    FALL(:,:,:,i-1461+1) = imread(['../../Datasets/fall/input/in00' sprintf('%0.4d', i) '.jpg']);
    GTFALL(:,:,i-1461+1) = imread(['../../Datasets/fall/groundtruth/gt00' sprintf('%0.4d', i) '.png']) == 255;
end
FALL = double(FALL);

% TRAFFIC
TRAFFIC=zeros(240,320,3,100);
GTTRAFFIC=zeros(240,320,3,100);
for i = 951:1050
    TRAFFIC(:,:,:,i-951+1) = imread(['../../Datasets/traffic/input/in00' sprintf('%0.4d', i) '.jpg']);
    GTTRAFFIC(:,:,i-951+1) = imread(['../../Datasets/traffic/groundtruth/gt00' sprintf('%0.4d', i) '.png']) == 255;
end
TRAFFIC = double(TRAFFIC);


%% Compute mean and variance for each pixel for first 50% frames
% Task 1.1

% HIGHWAY
MeanHIGHWAY1 = mean(HIGHWAY(:,:,1,1:size(HIGHWAY, 4)/2), 4);
[VarHIGHWAY1 VarHIGHWAY2 VarHIGHWAY12] = Computcov(reshape(HIGHWAY(:,:,1,1:size(HIGHWAY, 4)/2),[240,320,150]),reshape(HIGHWAY(:,:,2,1:size(HIGHWAY, 4)/2),[240,320,150]));

MeanHIGHWAY2 = mean(HIGHWAY(:,:,2,1:size(HIGHWAY, 4)/2), 4);
[VarHIGHWAY2 VarHIGHWAY3 VarHIGHWAY23] = Computcov(reshape(HIGHWAY(:,:,2,1:size(HIGHWAY, 4)/2),[240,320,150]),reshape(HIGHWAY(:,:,3,1:size(HIGHWAY, 4)/2),[240,320,150]));

MeanHIGHWAY3 = mean(HIGHWAY(:,:,3,1:size(HIGHWAY, 4)/2), 4);
[VarHIGHWAY1 VarHIGHWAY3 VarHIGHWAY13] = Computcov(reshape(HIGHWAY(:,:,1,1:size(HIGHWAY, 4)/2),[240,320,150]),reshape(HIGHWAY(:,:,3,1:size(HIGHWAY, 4)/2),[240,320,150]));

CovdetH=CompDet(VarHIGHWAY1,VarHIGHWAY2,VarHIGHWAY3,VarHIGHWAY12,VarHIGHWAY13,VarHIGHWAY23);
 
% FALL
MeanFALL1 = mean(FALL(:,:,1,1:size(FALL, 4)/2), 4);
[VarFALL1 VarFALL2 VarFALL12] = Computcov(reshape(FALL(:,:,1,1:size(FALL, 4)/2),[480,720,50]),reshape(FALL(:,:,2,1:size(FALL, 4)/2),[480,720,50]));


MeanFALL2 = mean(FALL(:,:,2,1:size(FALL, 4)/2), 4);
[VarFALL2 VarFALL3 VarFALL23] = Computcov(reshape(FALL(:,:,2,1:size(FALL, 4)/2),[480,720,50]),reshape(FALL(:,:,3,1:size(FALL, 4)/2),[480,720,50]));


MeanFALL3 = mean(FALL(:,:,3,1:size(FALL, 4)/2), 4);
[VarFALL1 VarFALL3 VarFALL13] = Computcov(reshape(FALL(:,:,1,1:size(FALL, 4)/2),[480,720,50]),reshape(FALL(:,:,3,1:size(FALL, 4)/2),[480,720,50]));

CovdetF=CompDet(VarFALL1,VarFALL2,VarFALL3,VarFALL12,VarFALL13,VarFALL23);
% TRAFFIC
MeanTRAFFIC1 = mean(TRAFFIC(:,:,1,1:size(TRAFFIC, 4)/2), 4);
[VarTRAFFIC1 VarTRAFFIC2 VarTRAFFIC12] = Computcov(reshape(TRAFFIC(:,:,1,1:size(TRAFFIC, 4)/2),[240,320,50]),reshape(TRAFFIC(:,:,2,1:size(TRAFFIC, 4)/2),[240,320,50]));

MeanTRAFFIC2 = mean(TRAFFIC(:,:,2,1:size(TRAFFIC, 4)/2), 4);
[VarTRAFFIC2 VarTRAFFIC3 VarTRAFFIC23] = Computcov(reshape(TRAFFIC(:,:,2,1:size(TRAFFIC, 4)/2),[240,320,50]),reshape(TRAFFIC(:,:,3,1:size(TRAFFIC, 4)/2),[240,320,50]));

MeanTRAFFIC3 = mean(TRAFFIC(:,:,3,1:size(TRAFFIC, 4)/2), 4);
[VarTRAFFIC1 VarTRAFFIC3 VarTRAFFIC13] = Computcov(reshape(TRAFFIC(:,:,1,1:size(TRAFFIC, 4)/2),[240,320,50]),reshape(TRAFFIC(:,:,3,1:size(TRAFFIC, 4)/2),[240,320,50]));
CovdetT=CompDet(VarHIGHWAY1,VarTRAFFIC2,VarTRAFFIC3,VarTRAFFIC12,VarTRAFFIC13,VarTRAFFIC23);
%% Testing with other half of frames
% Task 1.2, 2

Count = 1;
for Alpha = [0.1:0.1:15]
    % Highway
    alphaH = Alpha;
    TIHighway = HIGHWAY(:,:,:,(size(HIGHWAY, 4)/2)+1:size(HIGHWAY, 4));
    TRHighway = sqrt(((TIHighway(:,:,1,:) - repmat(MeanHIGHWAY1, [1, 1, 1,size(TIHighway, 4)]))).^2+ ...
        ((TIHighway(:,:,2,:) - repmat(MeanHIGHWAY2, [1, 1, 1,size(TIHighway, 4)]))).^2+ ...
        ((TIHighway(:,:,3,:) - repmat(MeanHIGHWAY3, [1, 1, 1,size(TIHighway, 4)]))).^2)>= ...
        alphaH*(repmat(CovdetF, [1, 1, 1, size(TIHighway, 4)]) + 2);
    
    [pixelTPH(Count), pixelFPH(Count), pixelFNH(Count), pixelTNH(Count)] = PerformanceAccumulationPixel(TRHighway, GTHIGHWAY(:, :,:, 151:300));
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



