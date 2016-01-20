function imgComp = motionCor(imgI, motionVect, mbSize)

[row col] = size(imgI);

Vector1 = zeros(size(imgI),2);
Vector2 = zeros(size(imgI),2);

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
        refBlkVer = i + dy;
        refBlkHor = j + dx;
        Vector1(i:i+mbSize-1,j:j+mbSize-1,1) = i;
        Vector1(i:i+mbSize-1,j:j+mbSize-1,2) = j;
        Vector2(i:i+mbSize-1,j:j+mbSize-1,1) = refBlkVer;
        Vector2(i:i+mbSize-1,j:j+mbSize-1,2) = refBlkHor;
        mbCount = mbCount + 1;
    end
end

imgComp = imageComp;