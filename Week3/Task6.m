%%%%%%%----------------Second method: Post/processing Imopen-------
% dbstop if error
% GT -- Ground Truth.
% Best Phi for HIGHWAY is 0.4; and Best Phi for FALL and TRAFFIC are 0.1
%% Read all pixel data and make a multi dimensional image
% HIGHWAY
for i = 1050+1:1350
    HIGHWAY(:,:,i-1051+1) = rgb2gray(imread(['Datasets/highway/input/in00' sprintf('%0.4d', i) '.jpg']));
    GTHIGHWAY(:,:,i-1051+1) = imread(['Datasets/highway/groundtruth/gt00' sprintf('%0.4d', i) '.png']) == 255;
    BGHIGHWAY(:,:,i-1051+1) = imread(['Datasets/highway/groundtruth/gt00' sprintf('%0.4d', i) '.png']) == 0 | ...
        imread(['Datasets/highway/groundtruth/gt00' sprintf('%0.4d', i) '.png']) == 50 ;
end
HIGHWAY = double(HIGHWAY);

% FALL
for i = 1461:1560
    FALL(:,:,i-1461+1) = rgb2gray(imread(['Datasets/fall/input/in00' sprintf('%0.4d', i) '.jpg']));
    GTFALL(:,:,i-1461+1) = imread(['Datasets/fall/groundtruth/gt00' sprintf('%0.4d', i) '.png']) == 255;
    BGFALL(:,:,i-1461+1) = imread(['Datasets/fall/groundtruth/gt00' sprintf('%0.4d', i) '.png']) == 0 | ...
        imread(['Datasets/fall/groundtruth/gt00' sprintf('%0.4d', i) '.png']) == 50 ;
end
FALL = double(FALL);

% TRAFFIC
for i = 951:1050
    TRAFFIC(:,:,i-951+1) = rgb2gray(imread(['Datasets/traffic/input/in00' sprintf('%0.4d', i) '.jpg']));
    GTTRAFFIC(:,:,i-951+1) = imread(['Datasets/traffic/groundtruth/gt00' sprintf('%0.4d', i) '.png']) == 255;
    BGTRAFFIC(:,:,i-951+1) = imread(['Datasets/traffic/groundtruth/gt00' sprintf('%0.4d', i) '.png']) == 0 | ...
        imread(['Datasets/traffic/groundtruth/gt00' sprintf('%0.4d', i) '.png']) == 50;
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
BestF1_N_H=0;BestF1_N_F=0;BestF1_N_T=0;
MeanHIGHWAY1=MeanHIGHWAY;VarHIGHWAY1=VarHIGHWAY;
MeanFALL1=MeanFALL;VarFALL1=VarFALL;
MeanTRAFFIC1=MeanTRAFFIC;VarTRAFFIC1=VarTRAFFIC;
auc=1;
for pixel=[0,7]
    se = strel('disk',pixel);                       
    phiH = 0.4;
    phi=0.1;%0:0.1:1
    Count = 1;
    for Alpha = [0.1:0.1:0.9,1:15]
        
        % Highway
        MeanHIGHWAY=MeanHIGHWAY1;VarHIGHWAY=VarHIGHWAY1;
        for i=size(HIGHWAY, 3)/2+1:size(HIGHWAY, 3)
            MeanHIGHWAY = phiH*HIGHWAY(:,:,i).*(1-GTHIGHWAY(:,:,i))+(1-phiH)*MeanHIGHWAY.*(1-GTHIGHWAY(:,:,i))+MeanHIGHWAY.*GTHIGHWAY(:,:,i);
            VarHIGHWAY = phiH*(HIGHWAY(:,:,i)-MeanHIGHWAY).^2.*(1-GTHIGHWAY(:,:,i))+(1-phiH)*VarHIGHWAY.*(1-GTHIGHWAY(:,:,i))+VarHIGHWAY.*GTHIGHWAY(:,:,i);
        end
        alphaH = Alpha;
        TIHighway = HIGHWAY(:,:,(size(HIGHWAY, 3)/2)+1:size(HIGHWAY, 3));
        TRHighway = abs((TIHighway - repmat(MeanHIGHWAY, [1, 1, size(TIHighway, 3)]))) >= ...
            alphaH*(repmat(sqrt(VarHIGHWAY), [1, 1, size(TIHighway, 3)]) + 2);
        for i =1:150
            IOHighway(:,:,i) = imclose(TRHighway(:,:,i),se);
            IOHighway(:,:,i) = imopen(IOHighway(:,:,i),se);
        end
        [pixelTPH(Count), pixelFPH(Count), pixelFNH(Count), pixelTNH(Count)] = PerformanceAccumulationPixel(IOHighway, GTHIGHWAY(:, :, 151:300));
        [pixelPrecisionH(Count), pixelAccuracyH(Count), pixelSpecificityH(Count), pixelSensitivityH(Count)] = ...
            PerformanceEvaluationPixel(pixelTPH(Count), pixelFPH(Count), pixelFNH(Count), pixelTNH(Count));
        F1_H(Count) = 2*  pixelPrecisionH(Count) * pixelSensitivityH(Count)/(pixelPrecisionH(Count) + pixelSensitivityH(Count));
        
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
        for i =1:50
            IOFall(:,:,i) = imclose(TRFall(:,:,i),se);
            IOFall(:,:,i) = imopen(IOFall(:,:,i),se);
        end
        [pixelTPF(Count), pixelFPF(Count), pixelFNF(Count), pixelTNF(Count)] = PerformanceAccumulationPixel(IOFall, GTFALL(:, :, 51:100));
        [pixelPrecisionF(Count), pixelAccuracyF(Count), pixelSpecificityF(Count), pixelSensitivityF(Count)] = ...
            PerformanceEvaluationPixel(pixelTPF(Count), pixelFPF(Count), pixelFNF(Count), pixelTNF(Count));
        F1_F(Count) = 2*  pixelPrecisionF(Count) * pixelSensitivityF(Count)/(pixelPrecisionF(Count) + pixelSensitivityF(Count));
        
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
        for i =1:50
            IOTraffic(:,:,i) = imclose(TRTraffic(:,:,i),se);
            IOTraffic(:,:,i) = imopen(IOTraffic(:,:,i),se);
        end
        [pixelTPT(Count), pixelFPT(Count), pixelFNT(Count), pixelTNT(Count)] = PerformanceAccumulationPixel(IOTraffic, GTTRAFFIC(:, :, 51:100));
        [pixelPrecisionT(Count), pixelAccuracyT(Count), pixelSpecificityT(Count), pixelSensitivityT(Count)] = ...
            PerformanceEvaluationPixel(pixelTPT(Count), pixelFPT(Count), pixelFNT(Count), pixelTNT(Count));
        F1_T(Count) = 2*  pixelPrecisionT(Count) * pixelSensitivityT(Count)/(pixelPrecisionT(Count) + pixelSensitivityT(Count));
        
        
        %% checking F1 measure
        % for Highway
        [F1_N_H(Count), pixelSensitivity_N_H(Count), pixelPrecision_N_H(Count)] = ...
            WFb(double(IOHighway), GTHIGHWAY(:, :, 151:300));
        
        % for Fall
        [F1_N_F(Count), pixelSensitivity_N_F(Count), pixelPrecision_N_F(Count)] = ...
            WFb(double(IOFall), GTFALL(:, :, 51:100));
        
        % for Traffic
        [F1_N_T(Count), pixelSensitivity_N_T(Count), pixelPrecision_N_T(Count)] = ...
            WFb(double(IOTraffic), GTTRAFFIC(:, :, 51:100));
        
        Count = Count + 1
    end
    
    figure(100+pixel);plot(F1_H, 'r');hold on
    figure(100+pixel);plot(F1_N_H, 'r-.')
    figure(100+pixel);plot(F1_F, 'g')
    figure(100+pixel);plot(F1_N_F, 'g-.')
    figure(100+pixel);plot(F1_T, 'b');
    figure(100+pixel);plot(F1_N_T, 'b-.')
    xlabel('#alpha')
    ylabel('F1 measure')
    title({'Comparison between F1 and F1beta measure'; 'r - Highway, g - Fall, b - Traffic'})
    legend('F1 measure','F1 beta measure')
    
    saveas(100+pixel, ['Compare_F1_se_' num2str(pixel) '.jpg']);
    %     h = getframe(gca);
    %     OutputIm = frame2im(h);
    %     imwrite(OutputIm, ['Compare_F1_se_' num2str(pixel) '.jpg']);
    
    areaH(auc) = trapz(pixelPrecisionH,pixelSensitivityH);
    areaF(auc) = trapz(pixelPrecisionF,pixelSensitivityF);
    areaT(auc) = trapz(pixelPrecisionT,pixelSensitivityT);
    
    if BestF1_H<areaH(auc)
        BestF1_H=areaH(auc);
        BestpixelPrecisionH=pixelPrecisionH;
        BestpixelSensitivityH=pixelSensitivityH;
        BestphiH=phi;
    end
    if BestF1_F< areaF(auc)
        BestF1_F=areaF(auc);
        BestpixelPrecisionF=pixelPrecisionF;
        BestpixelSensitivityF=pixelSensitivityF;
        BestphiF=phi;
    end
    if BestF1_T< areaT(auc)
        BestF1_T=areaT(auc);
        BestpixelPrecisionT=pixelPrecisionT;
        BestpixelSensitivityT=pixelSensitivityT;
        BestphiT=phi;
    end
    AverageAuc(auc)=(areaH(auc)+areaF(auc)+areaT(auc))/3;
    
    %% New method for F1 measure
    area_N_H(auc) = trapz(pixelPrecision_N_H,pixelSensitivity_N_H);
    area_N_F(auc) = trapz(pixelPrecision_N_F,pixelSensitivity_N_F);
    area_N_T(auc) = trapz(pixelPrecision_N_T,pixelSensitivity_N_T);
    
    if BestF1_N_H<area_N_H(auc)
        BestF1_N_H=area_N_H(auc);
        BestpixelPrecision_N_H=pixelPrecision_N_H;
        BestpixelSensitivity_N_H=pixelSensitivity_N_H;
        Bestphi_N_H=phi;
    end
    if BestF1_N_F< area_N_F(auc)
        BestF1_N_F=area_N_F(auc);
        BestpixelPrecision_N_F=pixelPrecision_N_F;
        BestpixelSensitivity_N_F=pixelSensitivity_N_F;
        Bestphi_N_F=phi;
    end
    if BestF1_N_T< area_N_T(auc)
        BestF1_N_T=area_N_T(auc);
        BestpixelPrecision_N_T=pixelPrecision_N_T;
        BestpixelSensitivity_N_T=pixelSensitivity_N_T;
        Bestphi_N_T=phi;
    end
    AverageAuc_N_(auc)=(area_N_H(auc)+area_N_F(auc)+area_N_T(auc))/3;
    
    %     % second step : obtain best phi
    %     figure(pixel); hold on; title('AUC vs pixel curve')
    %     plot(1:20, AverageAuc(auc),'-.r')
    %     grid on
    %     xlabel('#pixel')
    %     ylabel(['Average AUC se = ' num2str(pixel)])
    %
    %     %% second step : obtain best phi for New method of F1 measure
    %     figure(pixel+2); hold on; title('AUC vs pixel curve')
    %     plot(1:20, AverageAuc_N_(auc),'-.r')
    %     grid on
    %     xlabel('#pixel')
    %     ylabel(['Average AUC for Fbeta measure se = ' num2str(pixel)])
    
    auc=auc+1;
    
end

figure(100);plot(F1_H, 'r*');hold on
figure(100);plot(F1_N_H, 'r-')
figure(100);plot(F1_F, 'g*')
figure(100);plot(F1_N_F, 'g-')
figure(100);plot(F1_T, 'b*');
figure(100);plot(F1_N_T, 'b-')


% second step : obtain best phi
figure(1); hold on; title('AUC vs pixel curve')
plot(1:20, AverageAuc,'r*')
grid on
xlabel('#pixel')
ylabel('Average AUC')

%% second step : obtain best phi for New method of F1 measure
figure(2); hold on; title('AUC vs pixel curve')
plot(1:20, AverageAuc_N_,'r*')
grid on
xlabel('#pixel')
ylabel('Average AUC')


TheEnd = 1;
