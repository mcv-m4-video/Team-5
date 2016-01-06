%% To compute the 3D covariance matrix
function [y1,y2,y12]=Computcov(A,B)

y1= zeros(size(A,1),size(A,2));
y2= zeros(size(A,1),size(A,2));
y12= zeros(size(A,1),size(A,2));
for i = 1:size(A,1)
    for j = 1:size(A,2)
        temp=cov(reshape(A(i,j,:),size(A,3),1),reshape(B(i,j,:),size(A,3),1));
        y12(i,j)=temp(1,2);
        y1(i,j)=temp(1,1);
        y2(i,j)=temp(2,2);
    end
end

end