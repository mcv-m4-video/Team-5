clc
clearvars
Stabilizaton=1;  % 1 --  Stabilization ;      2 ---- Non-Stabilization
Crop = 0;        % 1 ----Crop   others    Non-crop
Newform = affine2d(eye(3));
dbstop if error
% TRAFFIC
for i = 950:1049
    TRAFFIC(:,:,i-950+1) = imread(['../../Datasets/traffic/input_1/Image_' sprintf('%d', i+1) '.jpg']);
    GTTRAFFIC(:,:,i-950+1) = imread(['../../Datasets/traffic/groundtruth/gt00' sprintf('%0.4d', i) '.png']) == 255;
    BGTRAFFIC(:,:,i-950+1) = imread(['../../Datasets/traffic/groundtruth/gt00' sprintf('%0.4d', i) '.png']) == 0 | ...
        imread(['../../Datasets/traffic/groundtruth/gt00' sprintf('%0.4d', i) '.png']) == 50;
end
TRAFFIC = double(TRAFFIC);
switch Stabilizaton
    case 1
        i = 1;
        while i ~= size(TRAFFIC,3)
            
            frame1 = TRAFFIC(:,:,i);
            frame2 = TRAFFIC(:,:,i+1);
            [compensatedImage, Newform] = compensateMotion(frame1, frame2, 16, 7, Newform);
            
            %             figure(1);imshow(uint8([frame1, compensatedImage]));
            %             pause(0.01);
            STABILIZEDTRAFFIC(:,:,i) = compensatedImage;
            i = i + 1;
        end
        
        % TRAFFIC
        MeanSTABILIZEDTRAFFIC = mean(STABILIZEDTRAFFIC(:,:,1:size(STABILIZEDTRAFFIC, 3)/2), 3);
        VarSTABILIZEDTRAFFIC = var(STABILIZEDTRAFFIC(:,:,1:size(STABILIZEDTRAFFIC, 3)/2), 0, 3);
        MeanTRAFFIC1=MeanSTABILIZEDTRAFFIC;VarTRAFFIC1=VarSTABILIZEDTRAFFIC;
        
        % Crop
        if Crop ==1
            MeanSTABILIZEDTRAFFIC = MeanSTABILIZEDTRAFFIC(10:end-10,10-end-10);
            VarSTABILIZEDTRAFFIC = VarSTABILIZEDTRAFFIC(10:end-10,10-end-10);
        end
    case 2
        % TRAFFIC
        MeanTRAFFIC = mean(TRAFFIC(:,:,1:size(TRAFFIC, 3)/2), 3);
        VarTRAFFIC = var(TRAFFIC(:,:,1:size(TRAFFIC, 3)/2), 0, 3);
        MeanTRAFFIC1=MeanTRAFFIC;VarTRAFFIC1=VarTRAFFIC;
        
        % Crop
        if Crop ==1
            MeanSTABILIZEDTRAFFIC = MeanSTABILIZEDTRAFFIC(10:end-10,10-end-10);
            VarSTABILIZEDTRAFFIC = VarSTABILIZEDTRAFFIC(10:end-10,10-end-10);
        end
        
    otherwise
        print('otherwise')
end
%% First method: obtain best alpha and then phi
%  first step : obtain best alpha
auc=1;
se = strel('disk',7);
for phi=0.1; %0:0.1:1
    Count = 1;
    for Alpha =[0.1:0.1:0.9,1:15]
        5
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
            %best config
            ICTraffic(:,:,i) = imclose(TRTraffic(:,:,i),se);
            ICTraffic(:,:,i) = imopen(ICTraffic(:,:,i),se);
            figure(1);imshow(ICTraffic(:,:,i),[]);
            pause(0.05)
        end
        [pixelTPT(Count), pixelFPT(Count), pixelFNT(Count), pixelTNT(Count)] = PerformanceAccumulationPixel(ICTraffic, GTTRAFFIC(:, :, 51:100));
        [pixelPrecisionT(Count), pixelAccuracyT(Count), pixelSpecificityT(Count), pixelSensitivityT(Count)] = ...
            PerformanceEvaluationPixel(pixelTPT(Count), pixelFPT(Count), pixelFNT(Count), pixelTNT(Count));
        F1_T(Count) = 2*  pixelPrecisionT(Count) * pixelSensitivityT(Count)/(pixelPrecisionT(Count) + pixelSensitivityT(Count));
        
        Count = Count + 1;
    end
    BestF(auc) = max(F1_T);
    areaT(auc) = trapz(pixelPrecisionT,pixelSensitivityT);
end

figure(1); hold on; title('Precision vs recall  curve')
plot(pixelSensitivityT,pixelPrecisionT ,'-.b')
axis([0 1 0 1])
legend(sprintf('Traffic Aera %5.4f   BestF1 %5.4f ',areaT(1),BestF(1)));
xlabel('Recall')
ylabel('Precision')
TheEnd = 1;