% call: DRsegMessidor.m
% John Jenkinson, UTSA ECE Dec. 30 2014
% DR segmentation for Messidor database
f=imread('test.tif');
fGreen=GreenChannelExtraction(f); 
fmiddle3rd=middle3rdimage(fGreen);
x=round(size(f,2)/72);
if(mod(x,2)>0)
    m=x;
else m=x+1;
end
fMed=medfilt2(fmiddle3rd,[m m]);
radius=150; height=0;
se=strel('ball',radius,height);
fTophat=imtophat(fMed,se);
Low_High=stretchlim(fTophat);
fCS=imadjust(fTophat,Low_High,[0 1]);
T=max(max(fCS))-10;
fBW=fCS>T;
seopen=strel('disk',36);
fOD=imopen(fBW,seopen);
[N M L]=size(fOD);
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
maskOD=strel('disk',radius);
maskOD=getnhood(maskOD);
maskOD=im2uint8(maskOD);
maskOD=abs(maskOD-1);
maskODx=size(maskOD,1);
maskODy=size(maskOD,2);
A=zeros(maskODx,mu-floor(radius/1.15));
B=size(f,2)-(size(A,2)+maskODy);
C=size(f,1)-(size(fmiddle3rd,1)+(nu-150)+maskODx);
cut1=[zeros(size(fmiddle3rd,1)+(nu-150),size(f,2))];
cut2=[A maskOD ...
    zeros(maskODx,B)];
cut3=[zeros(C,size(f,2))];
cut=[cut1; cut2; cut3];
fNoOD=fGreen-cut;
fx=fNoOD;
[fxx,zx]=rowBelowSubtract(fx);
