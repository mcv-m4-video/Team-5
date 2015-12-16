function [meanf1] = calculatemeanf1(resultDir, gtDir, segmentationType, numberofComparasions, shift)

resultFolder = resultDir;
gtfolder = gtDir;
f1 = 0;

for i = 1:numberofComparasions
    
    imfile = ['test_' segmentationType '_' '00' int2str(1200+i) '.png'];
    gtfile = ['gt' '00' int2str(1200+i+shift) '.png'];
    
    img = imread([resultFolder imfile]);
    gt = imread([gtfolder gtfile]);
    
    [localPixelTP, localPixelFP, localPixelFN, localPixelTN] = PerformanceAccumulationPixel(img, gt);
    [pixelPrecision_A, ~, ~, pixelSensitivity_A] = PerformanceEvaluationPixel(localPixelTP,...
        localPixelFP, localPixelFN, localPixelTN);
    
    %there are some NaN's in B, because it finds nothing, 
    %just black. so precison becomes 0 divided by 0
    temp = 2*  pixelPrecision_A * pixelSensitivity_A/(pixelPrecision_A + pixelSensitivity_A);
    if isnan(temp)
       temp = 0; 
    end
    f1 = f1 + temp;

end

meanf1 = f1/numberofComparasions;
end

