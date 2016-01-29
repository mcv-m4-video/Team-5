function [ cmin, cmax, rmin, rmax, wsize, histogram, numberofcars ] = initializecar( foreground, originalimage )
%foreground for initialization
%original image for histogram acquisition

st = regionprops(foreground, 'BoundingBox','centroid','Area');
rects = {st.BoundingBox};
numberofcars = length(rects);
cmin = zeros(numberofcars,1);
cmax = zeros(numberofcars,1);
rmin = zeros(numberofcars,1);
rmax = zeros(numberofcars,1);

shift = 0;
for i = 1: numberofcars
    cmin(i) = round(rects{i}(1))+shift;
    cmax(i) = round(rects{i}(1) + rects{i}(3))-shift;
    rmin(i) = round(rects{i}(2))+shift;
    rmax(i) = round(rects{i}(2) + rects{i}(4))-shift;
end
%rects{1}, rects{2} ...
%rect [xmin ymin width height]
wsize = zeros(numberofcars,2);
for i = 1: numberofcars
    wsize(i,1) = abs(rmax(i) - rmin(i));
    wsize(i,2) = abs(cmax(i) - cmin(i));
end


hue=originalimage;
%histogram = zeros(256,1);
histogram = zeros(numberofcars, 256);
for k = 1:numberofcars
    for i=rmin(k):rmax(k)
        for j=cmin(k):cmax(k)
            index = uint8(hue(i,j)+1);
            %count number of each pixel
            histogram(k, index) = histogram(k,index) + 1;
        end
    end
end

%normalization of histogram
% x = 1:256;
% for i = 1:numberofcars
%     histogram(i,:) = histogram(i,:)/trapz(x,histogram(i,:));
% end
end

