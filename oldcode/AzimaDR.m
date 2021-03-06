f=imread('test.tif'); 

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

% DARK SPOT SEGMENTATION...
x=fNoOD;
imhist(x)
