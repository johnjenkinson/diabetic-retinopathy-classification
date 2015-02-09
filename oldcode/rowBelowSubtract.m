% call: rowBelowSubtract.m
% for grayscale images...
function[fm,zx]=rowBelowSubtract(f)

[N M L]=size(f);
% propagate subtraction
fm=f;
for k=1:N-1
    fm(k,:)=f(k,:)-f(k+1,:);
end

% simple subtraction
zx=zeros(N,M);
for j=1:N-1
    zx(k,:)=f(k,:)-f(k+1,:);
end

    
