% call: DRpreprocssing.m
% John Jenkinson, UTSA ECE, Nov. 2014
% Last updated: 2015/1/13
% 
% The following implements DR classification by
% Saleh and Eswaran, "An automated decision-support 
% system for non-proliferative diabetic retinopathy
% disease based on MAs and HAs detection (2012)" 
% for the Messidor pathlogical database.


% read DR image
f=imread('test.tif'); 

% extract channel G
fGreen=GreenChannelExtraction(f); 

% FOR OPTIC DISC REMOVAL...
% g=ODremovalMessidor(fGreen);

%% FOR BACKGROUND SUBTRACTION...

% contrast enhancement by top and bot hat transforms
se=strel('line',12,0);
fGreentophat=imtophat(fGreen,se);
fGreenbothat=imbothat(fGreen,se);
fCE=(fGreen+fGreentophat)-fGreenbothat;

% median filtering
xx=round(size(fGreen,1)/24);
if (mod(xx,2)>0)
    mm=xx;
else
    mm=xx+1;
end
fCEMed=medfilt2(fGreen,[mm mm]);

% thresholding
[NN MM LL]=size(fGreen);
fNoBG=zeros(size(fGreen));
for n=1:NN
    for m=1:MM
        if ((fCEMed(n,m)-fGreen(n,m))>0)
        fNoBG(n,m)=(fCEMed(n,m)-fGreen(n,m));
        end
    end
end
fNoBG=uint8(fNoBG);

% constrast stretching
Low_High=stretchlim(fNoBG);
fNoBGCS=imadjust(fNoBG,Low_High,[0 1]);

se=strel('disk',2);
fx=imopen(fNoBGCS,se);
se=strel('disk',5);
fy=imclose(fx,se);
imshow(fy)

% median filter for noise removal
xxx=floor((size(f,1)/120));
if (mod(2,xxx)>0)
    mmm=xxx;
else
    mmm=xxx+1;
end
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

% direct filtering by morphological opening
BV=bwareaopen(HBW,600);
DS=HBW-BV;

figure;
subplot(121)
imshow(HBW)
subplot(122)
imshow(DS)

CC=bwconncomp(HBW); % find connected components in bw image
L=labelmatrix(CC); % create label matrix from CC structure
stats=regionprops(HBW,'Area','BoundingBox',...
    'ConvexArea','ConvexHull','MajorAxisLength',...
    'MinorAxisLength','Orientation','Perimeter');
density=zeros(length(stats),1);
R=zeros(length(stats),1);
spotArea=zeros(length(stats),1);
for  e=1:length(stats)
    areaBBox=stats(e).BoundingBox(3)*stats(e).BoundingBox(4);
    density(e)=stats(e).Area/areaBBox; % feature density
    % feature axes ratio
    R(e)=stats(e).MajorAxisLength/stats(e).MinorAxisLength;
end

ee=1:length(stats);
figure;
subplot(211)
stem(ee,density); title('density feature')
subplot(212)
stem(ee,R); title('axes ratio feature')

HBW2=HBW;
for i=1:length(stats)
    if(density(i)<0.6)
      HBW2(CC.PixelIdxList{i})=0;
    end
end
HBWdiff=HBW-HBW2;

figure;
subplot(121)
imshow(HBW); title('threshold image')
subplot(122)
imshow(HBW2); title('blood vessel removal')

% Second approach: using BVsegmentation.m
Y=imread('MessidorThresholdImage_Mask.tif');
BV1=BVsegmentation(f,Y);






