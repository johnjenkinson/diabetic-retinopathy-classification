% call: DRpreprocssing2.m
% John Jenkinson, UTSA ECE, Dec. 11 2014
% Code 2 is built for use with the Drive database.
% 
% The following implements DR classification by
% Saleh and Eswaran, "An automated decision-support 
% system for non-proliferative diabetic retinopathy
% disease based on MAs and HAs detection (2012).


% read DR image
f=imread('test2.tif'); 

% extract channel G
fGreen=GreenChannelExtraction(f); 

% FOR OPTIC DISC REMOVAL...

% extract the middle 3rd of the image
fmiddle3rd=middle3rdimage(fGreen);

% filtering to merge optic disc together
% x=round(size(f,2)/72);
% if(mod(x,2)>0)
%     m=x;
% else m=x+1;
% end
m=11;
fMed=medfilt2(fmiddle3rd,[m m]);

% contrast enhancement by tophat transform
% tophat transform is defined as:
% T(f) = fMed - (open(fMed))
% size of optic disc ~300=r pixels (used for s.e.)
radius=50; height=0;
se=strel('ball',radius,height);
fTophat=imtophat(fMed,se);

% contrast stretching to use the full dynamic range
% Low_High = stretchlim(I) returns Low_High, 
% a two-element vector of pixel values that specify 
% lower and upper limits that can be used for  
% contrast stretching image I. By default, values 
% in Low_High specify the bottom 1% and the top 1% 
% of all pixel values. The gray values returned 
% can be used by the imadjust function to increase 
% the contrast of an image.
Low_High=stretchlim(fTophat);
fCS=imadjust(fTophat,Low_High,[0 1]);

% binary image by thresholding
% T = max(fCS)-10
T=max(max(fCS))-10;
fBW=fCS>T;

% morphological opening to remove small objects
seopen=strel('disk',9);
fOD=imopen(fBW,seopen);
[N M L]=size(fOD);

figure;
subplot(321)
imshow(fmiddle3rd); title('green intensity image')
subplot(322)
imshow(fMed); title('median-filtered image')
subplot(323)
imshow(fTophat); title('contrast-enhanced image')
subplot(324)
imshow(fCS); title('contrast-stretched image')
subplot(325)
imshow(fBW); title('binary image')
subplot(326)
imshow(fOD); title('optic disc rough location')

% finding optic disc centroid
mu=0; nu=0;
for n=1:N
    for m=1:M
        nu=nu+fOD(n,m)*n;
        mu=mu+fOD(n,m)*m;
    end
end
nu=round(nu/sum(fOD(:)));
mu=round(mu/sum(fOD(:)));
centroidOD=[nu mu];

% create mask for optic disc removal
maskOD=strel('disk',radius);
maskOD=getnhood(maskOD);
maskOD=im2uint8(maskOD);
maskOD=abs(maskOD-1);
maskODx=size(maskOD,1);
maskODy=size(maskOD,2);
A=zeros(maskODx,mu-floor(radius));
B=size(f,2)-(size(A,2)+maskODy);
C=size(f,1)-(size(fmiddle3rd,1)+(nu-radius)+maskODx);
cut1=[zeros(size(fmiddle3rd,1)+(nu-radius),size(f,2))];
cut2=[A maskOD ...
    zeros(maskODx,B)];
cut3=[zeros(C,size(f,2))];
cut=[cut1; cut2; cut3];

% optic disk removal
fNoOD=fGreen-cut;
fNoOD=fNoOD;

% FOR BACKGROUND SUBTRACTION...

% contrast enhancement by top and bot hat transforms
se=strel('square',5);
fNoODtophat=imtophat(fNoOD,se);
fNoODbothat=imbothat(fNoOD,se);
fCE=(fNoOD+fNoODbothat)-fNoODbothat;

% median filtering
% xx=round(size(fCE,1)/24);
% if (mod(xx,2)>0)
%     mm=xx;
% else
%     mm=xx+1;
% end
mm=25;
fCEMed=medfilt2(fCE,[mm mm]);

% thresholding
[NN MM LL]=size(fCE);
fNoBG=zeros(size(fCE));
for n=1:NN
    for m=1:MM
        if ((fCEMed(n,m)-fCE(n,m))>0)
        fNoBG(n,m)=(fCEMed(n,m)-fCE(n,m));
        end
    end
end
fNoBG=uint8(fNoBG);

% constrast stretching
Low_High=stretchlim(fNoBG);
fNoBGCS=imadjust(fNoBG,Low_High,[0 1]);

% median filter for noise removal
% xxx=floor((size(f,1)/120));
% if (mod(2,xxx)>0)
%     mmm=xxx;
% else
%     mmm=xxx+1;
% end
mmm=5;
fNoBGCSMed=medfilt2(fNoBGCS,[mmm mmm]);

figure;
colormap(gray(255))
subplot(221)
image(fCE); axis image; axis off; 
title('contrast-enhanced image')
subplot(222)
image(fCEMed); axis image; axis off;
title('median-filtered image')
subplot(223)
image(fNoBGCS); axis image; axis off;
title('difference of enhanced from median filtered')
subplot(224)
image(fNoBGCSMed); axis image; axis off;
title('median-filtered difference image')

fp=fNoBGCSMed;

% FOR DARK SPOT SEGMENTATION

I=fNoBGCSMed(:);
% h-Maxima transformation
% find h
NM=length(I);
c=[];
for j=1:NM % using only non zero pixels to compute h
    if(I(j)>0)
        a=I(j);
        c=[c a];
    end
end
I2=c;
NM2=length(I2);
% muI=sum(I)/NM; % using all pixels to compute h
% muI=muI*ones(1,length(NM));
% muI=muI';
% A=I-muI;
% A=A.^2;
% A=double(A);
% sumA=sum(A);
% N1=2/NM;
% h=N1*sqrt(sumA);
% H=imhmax(fNoBGCSMed,h);
% imshow(H)
muI=sum(I2)/NM2;
muI=muI*ones(1,length(NM2));
muI=muI';
A=I2-muI;
A=A.^2;
A=double(A);
sumA=sum(A);
N1=2/NM2;
h2=N1*sqrt(sumA);
H=imhmax(fNoBGCSMed,h2);
mmax=max(max(H));

% thresholding
thresh=multithresh(H,3);
Hindexed=imquantize(H,thresh);
Hindexed=uint8(Hindexed);
HBW=H>=thresh(1);

figure;
colormap(gray(255))
subplot(221)
imagesc(H); axis image; axis off;
title('(a) h-Maxima transformed image')
subplot(222)
imhist(H)
title('histogram of (a)')
subplot(223)
imagesc(Hindexed); axis image; axis off;
title('(b) indexed image with 4 grey levels')
subplot(224)
imhist(Hindexed)
title('histogram of (b)')

figure;
imshow(HBW,[])

% BLOOD VESSEL SEGMENTATION...
I=imread('test2.tif'); 
Y=imread('test2_mask.gif');
[BV1,~]=BVsegmentation(I,Y);
BV1=im2bw(BV1);
Y=im2bw(Y);
se=strel('disk',3);
YY=imerode(Y,se);
Obw=HBW.*YY;
BV=Obw-BV1;

fig1=figure;
set(fig1,'name','BV Segmentation by Algorithm in [2]','numbertitle','off')
subplot(221)
imagesc(I); axis image; axis off;
title('original image')
subplot(222)
imshow(HBW); axis image; axis off;
title('objects image')
subplot(223)
imagesc(Y); axis image; axis off
title('image mask')
subplot(224)
imshow(BV); axis image; axis off
title('BV segmented image')

% element-wise multiply preprocessed image by FOV mask
% x=imread('test2_mask.gif');
% x=im2bw(x);
% se=strel('disk',3);
% x1=imerode(x,se);
% y=x1.*HBW;
% imshow(y)
% 
% % Subtract DRIVE segmented vessels from logical image
xx=imread('test2_segBV.gif');
xx=double(xx);
mx=max(max(xx));
xx=xx/mx;
XX=Obw-xx;

fig2=figure;
set(fig2,'name','BV Segmentation "gold standard" subtraction','numbertitle','off')
subplot(221)
imagesc(I); axis image; axis off;
title('original image')
subplot(222)
imshow(HBW); axis image; axis off;
title('objects image')
subplot(223)
imagesc(xx); axis image; axis off
title('gold standard')
subplot(224)
imshow(XX); axis image; axis off
title('BV difference image')


% yy=xx-y;
% imshow(yy)
% figure;
% subplot(211)
% imshow(xx)
% subplot(212)
% imshow(yy)
% imshow(y)






