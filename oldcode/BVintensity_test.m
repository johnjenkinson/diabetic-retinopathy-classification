f=imread('test2.tif');
[N M L]=size(f);
fRed=f(:,:,1);
mx=max(max(fRed));
fRed=mx-fRed;

figure;
subplot(221)
imshow(fRed)
subplot(2,2,[3,4])
imhist(fRed)
TT=zeros(size(fRed));

for k=2:(mx-1)
    for j=1:N
        for i=1:M
           if( fRed(j,i)==k )
               TT(j,i)=k;
           end
        end
    end    
    subplot(222)
    imshow(TT);
    pause(.1)
end


