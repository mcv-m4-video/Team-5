The foreground segmentation code, provides the possible F1 scores with
the given parameters alpha and phi. It uses adaptive learning. The F1 calculation 
is done by PerformanceEvaluationPixel.m and PerformanceEvaluationPixel.m. So they need to be
in the same folder. The shadow detection code does not affect the result, because we could not increase
the F1 score. Precision-recall and AUC value are also calculated. 

The optical flow estimation is based on the block matching. It gives good results. The affine transform
matrix can be extracted from the optical flow estimation. It is used for the stabilize the traffic sequence. 
The block matching algorithm is more useful than Lucas-Kanade considering the stabilization, because its
estimation is better. 

The tracking is done by three methods: Deep Learning Tracker, Mean Shift Tracker and Kalman Filter. Kalman filter
is the MATLAB's built-in function. Deep learning and mean shift codes are made available for multi-object tracking. 