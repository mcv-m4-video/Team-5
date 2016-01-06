function Task4_5_7


TestImNames = [45, 157];
imgC = 0;
for iT = TestImNames
    
    imgC = imgC + 1;
    %% Ground truth results
    im_GT = double(imread(['noc000' sprintf('%0.3d', iT) '_10.png']));
    
    % revert operation
    F_uGT = (im_GT(:,:,1)-2^15)/64;
    F_vGT = (im_GT(:,:,2)-2^15)/64;
    F_validGT = min(im_GT(:,:,3),1);
    F_uGT(F_validGT==0) = 0;
    F_vGT(F_validGT==0) = 0;
    
    %% Obtained results
    im_R = double(imread(['LKflow_000' sprintf('%0.3d', iT) '_10.png']));
    
    % revert operation
    F_uR = (im_R(:,:,1)-2^15)/64;
    F_vR = (im_R(:,:,2)-2^15)/64;
    F_validR = min(im_GT(:,:,3),1);
    F_uR(F_validR==0) = 0;
    F_vR(F_validR==0) = 0;
    
    %% Mean magnitude error (Task4)
    [sizex, sizey, sizez] = size(im_GT);
    
    Diff = (F_uGT - F_uR).^2 + (F_vGT - F_vR).^2;
    MMEVal(imgC) = sum(sum((Diff))) ./ length(find(F_validR == 1));
    %     MMEVal(imgC) = sum(sum((Diff))) ./ (sizex * sizey );
    
    %% Percentage of Erroneous Pixels (Task5)
    
    NumError = find(sqrt(Diff) > 3);
    PEPN(imgC) = length(NumError)/(length(find(F_validR == 1))) * 100;
    %     PEPN(imgC) = length(NumError)/(sizex * sizey) * 100;
    
    
    %% Plotting motion vector on image
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

TheEnd = 1;