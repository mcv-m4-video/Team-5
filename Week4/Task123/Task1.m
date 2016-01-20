clc
clearvars
% New Three Step Search
TestImNames = [45, 157];
% 
mbSize=16;p=7;
imgC=0;
for iT = TestImNames
    
    imgC = imgC + 1;
    %% Ground truth results
    im_GT = double(imread(['noc000' sprintf('%0.3d', iT) '_10.png']));
    
    % revert operation
    F_uGT = (im_GT(:,:,1)-2^15)/64;
    F_vGT = (im_GT(:,:,2)-2^15)/64;
    F_validGT = min(im_GT(:,:,3),1);
    % NON_occ
    F_uGT(F_validGT==0) = 0;
    F_vGT(F_validGT==0) = 0;
    
    imgP = double(imread(['im000' sprintf('%0.3d', iT) '_10.png']));
    imgI = double(imread(['im000' sprintf('%0.3d', iT) '_11.png']));
    
    [motionVect,computations ] = motionEstNTSS(imgP,imgI,mbSize,p);
    motionVect = vector2img(imgP,motionVect,mbSize);
    F_uR=motionVect(:,:,1);
    F_vR=motionVect(:,:,2);
    F_uR(F_validGT==0) = 0;
    F_vR(F_validGT==0) = 0;
    
    Diff = (F_uGT - F_uR).^2 + (F_vGT - F_vR).^2;
    MMEVal(imgC) = sum(sum((Diff))) ./ length(find(F_validGT == 1));
    
    %% Percentage of Erroneous Pixels (Task5)
    NumError = find(sqrt(Diff) > 3);
    PEPN(imgC) = length(NumError)/(length(find(F_validGT == 1))) * 100;
    
    %% Optional Task7
    VisParam = 10; % Simplifying for good visualization
    
    % Obtained results
    
    % downsize u and v
    u_deci = F_uR(1:VisParam:end, 1:VisParam:end);
    v_deci = F_vR(1:VisParam:end, 1:VisParam:end);
    
    % get coordinate for u and v in the original frame
    [m, n, d] = size(im_GT);
    [X,Y] = meshgrid(1:n, 1:m);
    X_deci = X(1:VisParam:end, 1:VisParam:end);
    Y_deci = Y(1:VisParam:end, 1:VisParam:end);
    
    OrigIm = imread(['im000' sprintf('%0.3d', iT) '_11.png']);
    figure(1);
    imshow(OrigIm);title(['Obtained results for image ' sprintf('%0.3d', iT)])
    hold on;
    
    % draw the velocity vectors
    quiver(X_deci, Y_deci, u_deci,v_deci, 'y')
    hold off
    FGT_ = getframe(1);
    OutputGT = frame2im(FGT_);
    imwrite(OutputGT, ['Output_OR000' sprintf('%0.3d', iT) '_VSparam' num2str(VisParam) '.png']);
    
     %% Ground truth
    
    % downsize u and v
    u_deci = F_uGT(1:VisParam:end, 1:VisParam:end);
    v_deci = F_vGT(1:VisParam:end, 1:VisParam:end);
    
    % get coordinate for u and v in the original frame
    [m, n, d] = size(im_GT);
    [X,Y] = meshgrid(1:n, 1:m);
    X_deci = X(1:VisParam:end, 1:VisParam:end);
    Y_deci = Y(1:VisParam:end, 1:VisParam:end);
    
    OrigIm = imread(['im000' sprintf('%0.3d', iT) '_11.png']);
    figure(2);
    imshow(OrigIm);title(['Ground truth for image ' sprintf('%0.3d', iT)])
    hold on;
    
    % draw the velocity vectors
    quiver(X_deci, Y_deci, u_deci,v_deci, 'y')
    hold off
    FGT_ = getframe(2);
    OutputGT = frame2im(FGT_);
    imwrite(OutputGT, ['Output_GT000' sprintf('%0.3d', iT) '_VSparam' num2str(VisParam) '.png']);
end
[MMEVal; PEPN]'