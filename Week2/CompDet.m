%% To compute the det of the covariance matrix
function y=CompDet(a,b,c,ab,ac,bc)

y=zeros(size(a,1),size(a,2));

for i=1:size(a,1)
    for j=1:size(a,2)
        temp=[a(i,j) ab(i,j) ac(i,j);ab(i,j) b(i,j) bc(i,j); ac(i,j)  bc(i,j) c(i,j)];
        y(i,j)=abs(det(temp));
    end
end
end