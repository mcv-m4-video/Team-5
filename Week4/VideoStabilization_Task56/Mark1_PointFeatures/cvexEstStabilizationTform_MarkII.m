function [H, NomatchFound] = cvexEstStabilizationTform_MarkII(leftI,rightI,ptThresh)
%Get inter-image transform and aligned point features.
%  H = cvexEstStabilizationTform(leftI,rightI) returns an affine transform
%  between leftI and rightI using the |estimateGeometricTransform|
%  function.
%
%  H = cvexEstStabilizationTform(leftI,rightI,ptThresh) also accepts
%  arguments for the threshold to use for the corner detector.

% Copyright 2010 The MathWorks, Inc.

% Set default parameters
if nargin < 3 || isempty(ptThresh)
    ptThresh = 0.1;
end
NomatchFound = 0;
%% Generate prospective points
% pointsA = detectFASTFeatures(leftI, 'MinContrast', ptThresh);
% pointsB = detectFASTFeatures(rightI, 'MinContrast', ptThresh);
pointsA = detectSURFFeatures(leftI);
pointsB = detectSURFFeatures(rightI);
% pointsA	= detectMinEigenFeatures(leftI,'MinQuality', 0.000001);
% pointsB	= detectMinEigenFeatures(rightI, 'MinQuality', 0.000001);
% pointsA = detectFASTFeatures(edge(leftI)); %, 'MinContrast', ptThresh);
% pointsB = detectFASTFeatures(edge(rightI)); %, 'MinContrast', ptThresh);

%% Select point correspondences
% Extract features for the corners
[featuresA, pointsA] = extractFeatures(leftI, pointsA, 'BlockSize', 31);
[featuresB, pointsB] = extractFeatures(rightI, pointsB, 'BlockSize', 31);
% [featuresA, pointsA] = extractFeatures(leftI, pointsA, 'Method', 'SURF', 'BlockSize', 25, 'SURFSize', 128);
% [featuresB, pointsB] = extractFeatures(rightI, pointsB, 'Method', 'SURF', 'BlockSize', 25, 'SURFSize', 128);

% Match features which were computed from the current and the previous
% images
indexPairs = matchFeatures(featuresA, featuresB, 'MaxRatio', 0.85); %, 'Unique', true);
pointsA = pointsA(indexPairs(:, 1), :);
pointsB = pointsB(indexPairs(:, 2), :);


if(length(pointsB) <= 2)
    NomatchFound = 1; H = [];
    return;
end

%% Use MSAC algorithm to compute the affine transformation
tform = estimateGeometricTransform(pointsB, pointsA, 'affine');
H = tform.T;
