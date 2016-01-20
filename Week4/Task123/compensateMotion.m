function [ Stabilization, Newform ] = compensateMotion( frame1, frame2, blockSize, stepSize, Newform )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

mbSize = blockSize; p = stepSize;
[motionVect,NTSScomputations,Points1,Points2 ] = motionEstNTSS(frame1,frame2,mbSize,p);
% hist = sqrt(motionVect(1,:).^2 + motionVect(2,:).^2);
% hist =hist';
% Points1(hist>2)=[];
% Points1(hist>2)=[];

%compensatedImage = motionComp(frame1, motionVect, mbSize);

[tform, inlierPoints1, inlierPoints2] = estimateGeometricTransform(...
    Points1,Points2 , 'affine');

Newform.T = tform.T * Newform.T;
Stabilization = imwarp(frame2, Newform, 'OutputView', imref2d(size(frame2)));

end

