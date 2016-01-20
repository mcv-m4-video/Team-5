% Computes motion compensated image using the given motion vectors
%
% Input
%   imgI : The reference image 
%   motionVect : The motion vectors
%   mbSize : Size of the macroblock
%
% Ouput
%   imgComp : The motion compensated image
%
% Written by Aroh Barjatya

function imgComp = vector2img(imgI, motionVect, mbSize)

[row,col] = size(imgI);
imageComp = zeros(row,col,3);

% we start off from the top left of the image
% we will walk in steps of mbSize
% for every marcoblock that we look at we will read the motion vector
% and put that macroblock from refernce image in the compensated image

mbCount = 1;
for i = 1:mbSize:row-mbSize+1
    for j = 1:mbSize:col-mbSize+1
        
        % dy is row(vertical) index
        % dx is col(horizontal) index
        % this means we are scanning in order
        
        dy = motionVect(1,mbCount);
        dx = motionVect(2,mbCount);
        imageComp(i:i+mbSize-1,j:j+mbSize-1,1) = dx;
        imageComp(i:i+mbSize-1,j:j+mbSize-1,2) = dy;
    
        mbCount = mbCount + 1;
    end
end

imgComp = imageComp;