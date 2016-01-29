function [F1_T, pixelPrecision, pixelSensitivity] = F1Measure_(TestImgs, GTImgs)

% Extract TP, FP, TN, FN parameters
[pixelTP, pixelFP, pixelFN, pixelTN] = PerformanceAccumulationPixel(double(TestImgs), double(GTImgs));

% Extract precision, accuracy, specificity, sensitivity
[pixelPrecision, pixelAccuracy, pixelSpecificity, pixelSensitivity] = ...
    PerformanceEvaluationPixel(pixelTP, pixelFP, pixelFN, pixelTN);

% F1 measure
F1_T = 2*  pixelPrecision * pixelSensitivity/(pixelPrecision + pixelSensitivity);

end