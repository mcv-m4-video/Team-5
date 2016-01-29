% Adam Kukucka
% Zach Clay
% Marcelo Molina
% CSE 486 Project 3

function [ rowcenter, colcenter, M00] = meanshift_array(rmin, rmax, cmin,...
    cmax, probmap,numberofcars)
%inputs
%   rmin, rmax, cmin, cmax are the coordiantes of the window
%   I is the image
%outputs
%   colcenter rowcenter are the new center coordinates
%   Moo is the zeroth mean

% **********************************************************************
% initialize
% **********************************************************************

% M00 = 0; %zeroth mean
% M10 = 0; %first moment for x
% M01 = 0; %first moment for y

M00 = zeros(numberofcars,1);
M10 = zeros(numberofcars,1);
M01 = zeros(numberofcars,1);

% **********************************************************************
% Main code
% **********************************************************************

%%%%%DÜZELT BURAYI
% determine zeroth moment
%cmin cmax are arrays
%probmap = zeros(rows, cols, numberofcars);
for k = 1:numberofcars
    for c = cmin(k):cmax(k)
        for r = rmin(k):rmax(k)
            %araba sahneden çýkýnca index out of bounds hatasý
            %mesela 241,163 gibi probmap(r,c)'de (240,320)
            M00(k) = M00(k) + probmap(r, c, k);
        end
    end
end



% determine first moment for x(col) and y(row)
for k = 1:numberofcars
    for c = cmin(k):cmax(k)
        for r = rmin(k):rmax(k)
            M10(k) = M10(k) + c*probmap(r,c,k);
            M01(k) = M01(k) + r*probmap(r,c,k);
        end
    end
end

%ÞÝMDÝLÝK, SONRA DEÐÝÞTÝR



% determine new centroid
% x is cols
colcenter = M10./ M00;

% y is rows
rowcenter = M01./M00;
end


