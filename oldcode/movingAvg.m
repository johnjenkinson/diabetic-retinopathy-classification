% call: movingAvg.m
% John Jenkinson UTSA ECE October 26, 2014
%
% Smoothing filter, linear spatial filtering,
% moving average filter; used for
% noise removal or image blurring
%
f=imread('20051019_38557_0100_PP.tif');
f=f(:,:,2);
f=double(f);
[N M L]=size(f);

% method 1
g=zeros(N,M);
for n=2:N-1
    for m=2:M-1
        g(n,m)=(1/16)*(1*f(n-1,m-1)+2*f(n,m-1)+...
            1*f(n+1,m-1)+2*f(n,m-1)+4*f(n,m)+...
            2*f(n,m+1)+1*f(n+1,m-1)+2*f(n+1,m)+...
            1*f(n+1,m+1));
    end
end

% method 2
h=(1/16)*[1 2 1; 2 4 2; 1 2 1];
b=zeros(N,M);
for n=2:N-1
    for m=2:M-1
        neighborhood=f(n-1:n+1,m-1:m+1);
        b(n,m)=sum(sum(h.*neighborhood));
    end
end

figure;
colormap(autumn(255))
subplot(131)
image(f); axis image;
subplot(132)
image(g); axis image;
subplot(133)
image(b); axis image;

