%%%%%%%----------------Second method: obtain best alpha and  phi together-------
dbstop if error
% GT -- Ground Truth.

%% Read all pixel data and make a multi dimensional image

% HIGHWAY
for i = 1050+1:1350
    HIGHWAY(:,:,i-1051+1) = rgb2gray(imread(['../../Datasets/highway/input/in00' sprintf('%0.4d', i) '.jpg']));
    GTHIGHWAY(:,:,i-1051+1) = imread(['../../Datasets/highway/groundtruth/gt00' sprintf('%0.4d', i) '.png']) == 255;
    BGHIGHWAY(:,:,i-1051+1) = imread(['../../Datasets/highway/groundtruth/gt00' sprintf('%0.4d', i) '.png']) == 0 | ...
        imread(['../../Datasets/highway/groundtruth/gt00' sprintf('%0.4d', i) '.png']) == 50 ;
end
HIGHWAY = double(HIGHWAY);

% FALL
for i = 1461:1560
    FALL(:,:,i-1461+1) = rgb2gray(imread(['../../Datasets/fall/input/in00' sprintf('%0.4d', i) '.jpg']));
    GTFALL(:,:,i-1461+1) = imread(['../../Datasets/fall/groundtruth/gt00' sprintf('%0.4d', i) '.png']) == 255;
    BGFALL(:,:,i-1461+1) = imread(['../../Datasets/fall/groundtruth/gt00' sprintf('%0.4d', i) '.png']) == 0 | ...
        imread(['../../Datasets/fall/groundtruth/gt00' sprintf('%0.4d', i) '.png']) == 50 ;
end
FALL = double(FALL);

% TRAFFIC
for i = 951:1050
    TRAFFIC(:,:,i-951+1) = rgb2gray(imread(['../../Datasets/traffic/input/in00' sprintf('%0.4d', i) '.jpg']));
    GTTRAFFIC(:,:,i-951+1) = imread(['../../Datasets/traffic/groundtruth/gt00' sprintf('%0.4d', i) '.png']) == 255;
    BGTRAFFIC(:,:,i-951+1) = imread(['../../Datasets/traffic/groundtruth/gt00' sprintf('%0.4d', i) '.png']) == 0 | ...
        imread(['../../Datasets/traffic/groundtruth/gt00' sprintf('%0.4d', i) '.png']) == 50;
end
TRAFFIC = double(TRAFFIC);


%% Compute mean and variance for each pixel for first 50% frames
% Task 1.1

% HIGHWAY
MeanHIGHWAY = mean(HIGHWAY(:,:,1:size(HIGHWAY, 3)/2), 3);
VarHIGHWAY = var(HIGHWAY(:,:,1:size(HIGHWAY, 3)/2), 0, 3);

% FALL
MeanFALL = mean(FALL(:,:,1:size(FALL, 3)/2), 3);
VarFALL = var(FALL(:,:,1:size(FALL, 3)/2), 0, 3);

% TRAFFIC
MeanTRAFFIC = mean(TRAFFIC(:,:,1:size(TRAFFIC, 3)/2), 3);
VarTRAFFIC = var(TRAFFIC(:,:,1:size(TRAFFIC, 3)/2), 0, 3);


%% First method: obtain best alpha and then phi
%  first step : obtain best alpha 
BestF1_H=0;BestF1_F=0;BestF1_T=0;
MeanHIGHWAY1=MeanHIGHWAY;VarHIGHWAY1=VarHIGHWAY;
MeanFALL1=MeanFALL;VarFALL1=VarFALL;
MeanTRAFFIC1=MeanTRAFFIC;VarTRAFFIC1=VarTRAFFIC;
Count = 1;
for Alpha = [0.1:0.1:0.9,1:15]
    for phi=0:0.1:1
        % Highway
        MeanHIGHWAY=MeanHIGHWAY1;VarHIGHWAY=VarHIGHWAY1;
        for i=size(HIGHWAY, 3)/2+1:size(HIGHWAY, 3)
            MeanHIGHWAY = phi*HIGHWAY(:,:,i).*(1-GTHIGHWAY(:,:,i))+(1-phi)*MeanHIGHWAY.*(1-GTHIGHWAY(:,:,i))+MeanHIGHWAY.*GTHIGHWAY(:,:,i);
            VarHIGHWAY = phi*(HIGHWAY(:,:,i)-MeanHIGHWAY).^2.*(1-GTHIGHWAY(:,:,i))+(1-phi)*VarHIGHWAY.*(1-GTHIGHWAY(:,:,i))+VarHIGHWAY.*GTHIGHWAY(:,:,i);
        end
        alphaH = Alpha;
        TIHighway = HIGHWAY(:,:,(size(HIGHWAY, 3)/2)+1:size(HIGHWAY, 3));
        TRHighway = abs((TIHighway - repmat(MeanHIGHWAY, [1, 1, size(TIHighway, 3)]))) >= ...
            alphaH*(repmat(sqrt(VarHIGHWAY), [1, 1, size(TIHighway, 3)]) + 2);
        
        [pixelTPH(Count), pixelFPH(Count), pixelFNH(Count), pixelTNH(Count)] = PerformanceAccumulationPixel(TRHighway, GTHIGHWAY(:, :, 151:300));
        [pixelPrecisionH(Count), pixelAccuracyH(Count), pixelSpecificityH(Count), pixelSensitivityH(Count)] = ...
            PerformanceEvaluationPixel(pixelTPH, pixelFPH, pixelFNH, pixelTNH);
        F1_H(Count) = 2*  pixelPrecisionH(Count) * pixelSensitivityH(Count)/(pixelPrecisionH(Count) + pixelSensitivityH(Count));
        if BestF1_H<F1_H(Count)
            BestF1_H=F1_H(Count);
            BestalphaH=alphaH;
            BestphiH=phi;
        end
        % Fall
        
        MeanFALL=MeanFALL1;VarFALL=VarFALL1;
        for i=size(FALL, 3)/2+1:size(FALL, 3)
            MeanFALL = phi*FALL(:,:,i).*(1-GTFALL(:,:,i))+(1-phi)*MeanFALL.*(1-GTFALL(:,:,i))+MeanFALL.*GTFALL(:,:,i);
            VarFALL = phi*(FALL(:,:,i)-MeanFALL).^2.*(1-GTFALL(:,:,i))+(1-phi)*VarFALL.*(1-GTFALL(:,:,i))+VarFALL.*GTFALL(:,:,i);
        end
        alphaF = Alpha;
        TIFall = FALL(:,:,(size(FALL, 3)/2)+1:size(FALL, 3));
        TRFall = abs((TIFall - repmat(MeanFALL, [1, 1, size(TIFall, 3)]))) >= ...
            alphaF*(repmat(sqrt(VarFALL), [1, 1, size(TIFall, 3)]) + 2);
        
        [pixelTPF(Count), pixelFPF(Count), pixelFNF(Count), pixelTNF(Count)] = PerformanceAccumulationPixel(TRFall, GTFALL(:, :, 51:100));
        [pixelPrecisionF(Count), pixelAccuracyF(Count), pixelSpecificityF(Count), pixelSensitivityF(Count)] = ...
            PerformanceEvaluationPixel(pixelTPF(Count), pixelFPF(Count), pixelFNF(Count), pixelTNF(Count));
        F1_F(Count) = 2*  pixelPrecisionF(Count) * pixelSensitivityF(Count)/(pixelPrecisionF(Count) + pixelSensitivityF(Count));
        if BestF1_F< F1_F(Count)
            BestF1_F=F1_F(Count);
            BestalphaF=alphaF;
            BestphiF=phi;
        end
        % Traffic
        MeanTRAFFIC=MeanTRAFFIC1;VarTRAFFIC=VarTRAFFIC1;
        for i=size(TRAFFIC, 3)/2+1:size(TRAFFIC, 3)
            MeanTRAFFIC = phi*TRAFFIC(:,:,i).*(1-GTTRAFFIC(:,:,i))+(1-phi)*MeanTRAFFIC.*(1-GTTRAFFIC(:,:,i))+MeanTRAFFIC.*GTTRAFFIC(:,:,i);
            VarTRAFFIC = phi*(TRAFFIC(:,:,i)-MeanTRAFFIC).^2.*(1-GTTRAFFIC(:,:,i))+(1-phi)*VarTRAFFIC.*(1-GTTRAFFIC(:,:,i))+VarTRAFFIC.*GTTRAFFIC(:,:,i);
        end
        alphaT = Alpha;
        TITraffic = TRAFFIC(:,:,(size(TRAFFIC, 3)/2)+1:size(TRAFFIC, 3));
        TRTraffic = abs((TITraffic - repmat(MeanTRAFFIC, [1, 1, size(TITraffic, 3)]))) >= ...
            alphaT*(repmat(sqrt(VarTRAFFIC), [1, 1, size(TITraffic, 3)]) + 2);
        
        [pixelTPT(Count), pixelFPT(Count), pixelFNT(Count), pixelTNT(Count)] = PerformanceAccumulationPixel(TRTraffic, GTTRAFFIC(:, :, 51:100));
        [pixelPrecisionT(Count), pixelAccuracyT(Count), pixelSpecificityT(Count), pixelSensitivityT(Count)] = ...
            PerformanceEvaluationPixel(pixelTPT(Count), pixelFPT(Count), pixelFNT(Count), pixelTNT(Count));
        F1_T(Count) = 2*  pixelPrecisionT(Count) * pixelSensitivityT(Count)/(pixelPrecisionT(Count) + pixelSensitivityT(Count));
        if BestF1_T< F1_T(Count)
            BestF1_T=F1_T(Count);
            BestalphaT=alphaT;
            BestphiT=phi;
        end
        Count = Count + 1;
    end
end

% second step : obtain best phi

TheEnd = 1;
