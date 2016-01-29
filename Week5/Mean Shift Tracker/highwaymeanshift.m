clc
clearvars
close all

% load GTHIghway.mat
% load HIGHWAY.mat

for i = 1050+1:1350
    HIGHWAY(:,:,i-1051+1) = rgb2gray(imread(['../../Datasets/highway/input/in00' sprintf('%0.4d', i) '.jpg']));
    GTHIGHWAY(:,:,i-1051+1) = imread(['../../Datasets/highway/groundtruth/gt00' sprintf('%0.4d', i) '.png']) == 255;
    BGHIGHWAY(:,:,i-1051+1) = imread(['../../Datasets/highway/groundtruth/gt00' sprintf('%0.4d', i) '.png']) == 0 | ...
        imread(['../../Datasets/highway/groundtruth/gt00' sprintf('%0.4d', i) '.png']) == 50 ;
end

Mv = VideoReader('inihighwayvideo.avi');
numberofframes = Mv.NumberOfFrames;
rownumber = Mv.Height;
colnumber = Mv.Width;
totalnumberofcars = 0;

videoFrames = Mv.read();
initializedframes = [1 50 100 210 270];
updatednumberofcars=0;
for frameNo = 1:numberofframes
    
    frameNo
    
    %initialize
    if ismember(frameNo, initializedframes)
       [cmin, cmax, rmin, rmax, wsize, histogram, numberofcars ] = ...
       initializecar(GTHIGHWAY(:,:,frameNo),HIGHWAY(:,:,frameNo));
   
       difference = abs(updatednumberofcars-numberofcars);
       updatednumberofcars = numberofcars;
       totalnumberofcars = totalnumberofcars+difference;
    end
    
    Frame = videoFrames(:,:,:,frameNo);
    hue= rgb2gray(Frame);
    numberofcars = updatednumberofcars;

    [rows, cols] = size(hue);
    probmap = zeros(rows, cols,numberofcars);
    for r=1:rows
        for c=1:cols
            if(hue(r,c) ~= 0)
                probmap(r,c,:)= histogram(:,hue(r,c));
            end
        end
    end
    
    probmap = probmap./(max(probmap(:)));
    probmap = probmap*255;
    
    count = zeros(numberofcars,1);
    rowcenter = zeros(numberofcars,1);% any number just so it runs through at least twice
    colcenter = zeros(numberofcars,1);
    rowcenterold = 5*ones(numberofcars,1);
    colcenterold = 5*ones(numberofcars,1);
    while any(abs(rowcenter - rowcenterold)>2) ...
            && any(abs(colcenter - colcenterold) > 2) || any(count < 15)
        
        %first see which elements fit this situation
        a1 = abs(rowcenter - rowcenterold)>2;
        a2 = abs(colcenter - colcenterold) > 2;
        a3 = count < 15;
        
        elements = or(and(a1,a2),a3);
        rowcenterold(elements) = rowcenter(elements);
        colcenterold(elements) = colcenter(elements);
        
        %cars go away
        if any(rmax > rownumber)
            numberofeliminatedcars = sum(rmax > rownumber ==1);
            numberofcars = numberofcars - numberofeliminatedcars;
            rmin(rmax > rownumber) = [];
            cmin(rmax > rownumber) = [];
            cmax(rmax > rownumber) = [];
            elements(rmax > rownumber) = [];
            wsize((rmax > rownumber),:) = [];
            count(rmax > rownumber) = [];
            probmap(:,:,(rmax > rownumber)) = [];
            histogram((rmax > rownumber),:) = [];
            rowcenterold(rmax > rownumber) = [];
            colcenterold(rmax > rownumber) = [];
            rmax(rmax > rownumber) = [];
        end
        
        
        %rowcenter, colcenter ve M00 güncellenmiþ olarak çýkacak
        %MEANSHIFT ARRAY FONKSÝYONUNU GÜNCELLE, EÐER ÇIKTIYSA ARABA DEFET
        [rowcenter, colcenter, M00] = ...
            meanshift_array(rmin, rmax, cmin,cmax, probmap,numberofcars);
        
        
        rmin_temp = round(rowcenter - wsize(:,1)/2);
        rmin(elements) = rmin_temp(elements);
        if any(rmin(elements)<1)
            rmin(rmin < 1 & elements)=1;
        end
        
        rmax_temp = round(rowcenter + wsize(:,1)/2);
        rmax(elements) = rmax_temp(elements);
        if any(rmax(elements)<1)
            rmax(rmax<1 & elements)=1;
        end
        
        cmin_temp = round(colcenter - wsize(:,2)/2);
        cmin(elements) = cmin_temp(elements);
        if any(cmin(elements)<1)
            cmin(cmin<1 & elements)=1;
        end
        
        
        cmax_temp = round(colcenter+ wsize(:,2)/2);
        cmax(elements) = cmax_temp(elements);
        if any(cmax(elements)<1)
            cmax(cmax<1 & elements)=1;
        end
        wsize(:,1) = abs(rmax - rmin);
        wsize(:,2) = abs(cmax - cmin);
        
        count(elements) = count(elements) + 1;
    end
    
%     trackim=Frame;
%     
%     
%     
%     %just for putting bounding box
%     for i = 1:numberofcars
%         for r= rmin(i):rmax(i)
%             trackim(r, cmin(i):cmin(i)+2) = 0;
%             trackim(r, cmax(i)-2:cmax(i)) = 0;
%         end
%         for c= cmin(i):cmax(i)
%             trackim(rmin(i):rmin(i)+2, c) = 0;
%             trackim(rmax(i)-2:rmax(i), c) = 0;
%         end
%     end
    %just for putting bounding box
    
    
    
    windowsize = 100 * power(M00./256, 0.5); %(M00./256)^(0.5);
    sidelength = sqrt(windowsize);
    
    rmin = round(rowcenter-sidelength/2);
    if any(rmin<1)
        rmin(rmin<1)=1;
    end
    
    rmax = round(rowcenter+sidelength/2);
    if any(rmax<1)
        rmax(rmax<1)=1;
    end
    
    cmin = round(colcenter-sidelength/2);
    if any(cmin<1)
        cmin(cmin<1)=1;
    end
    
    cmax = round(colcenter+sidelength/2);
    if any(cmax<1)
        cmax(cmax<1)=1;
    end
    
    wsize(:,1) = abs(rmax - rmin);
    wsize(:,2) = abs(cmax - cmin);
    updatednumberofcars = numberofcars;
    
    trackim = Frame;
    positionMatrix = [cmin rmin cmax-cmin rmax-rmin];
    positionMatrix = sortrows(positionMatrix, 2);
    label = totalnumberofcars:-1:totalnumberofcars-updatednumberofcars+1;
    
    RGB = insertObjectAnnotation(trackim,'rectangle',positionMatrix,label,...
    'Color','red');
    
    figure(1),imshow(RGB); hold on
end