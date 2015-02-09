% call: BVsegmentation.m
% John Jenkinson UTSA ECE Dec. 3, 2014
%
% The following implements blood vessel segmentation
% by Saleh and Eswaran, "An automated blood vessel
% segmentation algorithm using histogram equalization
% and automatic threshold selection (2011).
%
% The input is a color fundus image, I, and mask, Y.
% Output BV1 is green channel with bg subtraction &
% BV2 is gray-scale image with bg subtraction.
%
% The green channel typically performs better.

function[BV1,BV2]=BVsegmentation(I,Y)

% read fundus image
% I=imread('test2.tif');
[N M L]=size(I);
IG=I(:,:,2); % green channel
% IG=double(IG);
Igs=0.2989*I(:,:,1)+0.5870*I(:,:,2)+0.1140*I(:,:,3); % grayscale
% Igs=double(Igs);

% read mask image
% Y=imread('test2_mask.gif');

% contrast-limited adaptive histogram equalization (CLAHE)
CEG=adapthisteq(IG);
CEgs=adapthisteq(Igs);

% background removal
n=11; % size of filter mask
h=fspecial('average',n); 
CEGavg=filter2(h,CEG);
CEgsavg=filter2(h,CEgs);
CEGavg=uint8(CEGavg);
CEgsavg=uint8(CEgsavg);
h1=zeros(N,M);
h2=h1;
for j=1:N
    for k=1:M
        if( (CEGavg(j,k)-CEG(j,k))>0 )
            h1(j,k)=CEGavg(j,k)-CEG(j,k); % green channel
            if( (CEgsavg(j,k)-CEgs(j,k))>0 )
            h2(j,k)=CEgsavg(j,k)-CEgs(j,k); % gray-scale
            end
        end
    end
end
X=CEGavg-CEG;
% thresholding by 'Isodata' and post-filtration
[level1, B1]=isodata(h1);
[level2, B2]=isodata(h2);
B1pf=bwareaopen(B1,35); % post-filtration
B2pf=bwareaopen(B2,35);

% mask subtraction
Ibw=im2bw(Y);
se=strel('disk',3);
Imask=imerode(Ibw,se);
BV1=B1pf.*Imask;
BV2=B2pf.*Imask;

% Irgb=I(:,:,1)+I(:,:,2)+I(:,:,3);
% Ibw=Irgb>100;
% Ibw=1-Ibw;
% se=strel('disk',3);
% Imask=imopen(Ibw,se);
% BV1=zeros(N,M);
% BV2=BV1;
% for j=N
%     for k=1:M
%         if( (B1(j,k)-Imask(j,k))>0 )
%             BV1(j,k)=1;
%             if( (B2(j,k)-Imask(j,k))>0 )
%             BV2(j,k)=1;
%             end
%         end
%     end
% end

end

            








