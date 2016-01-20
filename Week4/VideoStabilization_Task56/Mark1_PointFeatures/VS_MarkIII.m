function VS_MarkIII

dbstop if error
hVPlayer = vision.VideoPlayer; % Create video viewer
StartF = 951;
EndF = 1050;

ii = 2;
Hcumulative = eye(3);
movMean = [];
ptThresh = 0.01;

h = fspecial('gaussian');
% h = []
VidOBj = VideoWriter('traffic_AferStablization.avi');
VidOBj.FrameRate = 10;
open(VidOBj);
for i = StartF:EndF
    
    % Read in new frame
    imgA = imread(['..\..\Datasets\traffic\input\in' sprintf('%0.6d', i-1), '.jpg']);
    imgB = imread(['..\..\Datasets\traffic\input\in' sprintf('%0.6d', i), '.jpg']);
    
    % apply gaussian filter over the image
    imgA = single(rgb2gray(imfilter(imgA, h)));
    imgB = single(rgb2gray(imfilter(imgB, h)));
    
    
    imgAp = imgA;
    imgBp = imgB;
    
    correctedMean = imgBp;
    
    if(i == StartF)
        movMean = imgB;
    else
        movMean = movMean + imgB;
    end
    
    if(ii == 85)
        qq = 1;
    end
    
    % Estimate transform from frame A to frame B, and fit as an s-R-t
    [H, NomatchFound] = cvexEstStabilizationTform_MarkII(uint8(imgA),uint8(imgB), ptThresh);
    if(NomatchFound)
        ii = ii+1
        continue;
    end
    HsRt = cvexTformToSRT(H);
    Hcumulative = HsRt * Hcumulative;
    imgBp = imwarp(imgB,affine2d(Hcumulative),'OutputView',imref2d(size(imgB)));
    
    % Display as color composite with last corrected frame
    step(hVPlayer, imfuse(imgAp,imgBp,'ColorChannels','red-cyan'));
    correctedMean = correctedMean + imgBp;
    
    imwrite([uint8(imgBp)], ['Results/Image_' num2str(i) '.jpg']);
    %     imwrite([uint8(imgB) uint8(imgBp)], ['Results/ImageMerge_' num2str(ii) '.jpg']);
    %     ii = ii+1
    writeVideo(VidOBj, uint8([imgB imgBp]));
    
end
close(VidOBj);
