% call: findthresh.m
% JAJ Dec. '14 UTSA ECE
% find the best threshold manually by viewing
% iterative thresholding over the image histogram
% inputs: f (image), nc (# of channels), c (channel)
% user enters threshold value into command prompt...

%*
f=imread('testx.tif');
[N M L]=size(f);
if (L>1)
%*
c=2;
f=f(:,:,c);
end
% mx=max(f(:)); % image negative
% f=mx-f;
H=imhist(f);
h_fig=figure;
set(h_fig,'Name','Threshold Selection','Menubar',...
    'None');
colormap(gray)
subplot(221)
imagesc(f); axis image; axis off;
title('original image')
subplot(2,2,[3 4]);
plot(H);

m=whos('f');
if(m.class=='uint8')
hist_end=256;
else if(m.class=='uint16');
        hist_end=65536;
    else
        disp('Input requires unsigned data type.')
    end
end

f=double(f);
fb=zeros(N,M);
for k=1:hist_end
    fb=(f>k).*f;
    subplot(222);
    imagesc(fb); axis image; axis off;
    stext='threshold by %g';
    stitle=sprintf(stext,k);
    title(stitle)
    subplot(2,2,[3 4])
    L=line([k k],[0 H(k)]);
    set(L,'LineWidth',2,'Color','Red');
    pause(0.1)
    delete(L)
end







