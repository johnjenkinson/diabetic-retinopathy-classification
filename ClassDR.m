% call: ClassDR.m
% classify DR spots in fundus images.
%
% John Jenkinson, UTSA ECE January 8, 2015.
% Last Modified: 2015/1/18

original = imread('test.tif'); % read pathological Messidor image
%original=256*uint16(original);
%green = original(:,:,2);
green=ODremovalMessidor(original); % optic disc removal

% grayscale set operations
% discSize = [3 5 15]; % for testing
discSize = 5;
for j = discSize
    
se = strel('disk',j);
tophatFiltered = imtophat(green,se); % top-hat transform
tophatLimits = stretchlim(tophatFiltered);
tophatEnhanced = imadjust(tophatFiltered,[tophatLimits(1) tophatLimits(2)]);

figure;
imshow(tophatEnhanced)

end

% image histogram and threshold selection
Hist = imhist(tophatEnhanced); % uint16 imhist(tophatEnhanced,65535)
thresh_levels = find(Hist>0);
thresh_levels = thresh_levels';
figure;
subplot(221)
imshow(tophatEnhanced)
subplot(2,2,[3 4])
plot(Hist)
for j = thresh_levels
    tophatBinary = tophatEnhanced>j; % threshold found to be 224
    subplot(222)
    imshow(tophatBinary)
    pause(1)
end

n=length(thresh_levels);
tophatBinary = tophatEnhanced>thresh_levels(n-1);

se=strel('disk',1);
Opened=imopen(tophatBinary,se);
imshow(Opened)

radius_range = 0:22;
intensity_area = zeros(size(radius_range));
for counter = radius_range
    remain = imopen(Opened, strel('disk', counter));
    intensity_area(counter + 1) = sum(remain(:));
end
figure
plot(intensity_area, 'm - *')
grid on
title('Sum of pixel values in opened image versus radius')
xlabel('radius of opening (pixels)')
ylabel('pixel value sum of opened objects (intensity)')

intensity_area_prime = diff(intensity_area);
plot(intensity_area_prime, 'm - *')
grid on
title('Granulometry (Size Distribution) of objects')
ax = gca;
ax.XTick = [0 2 4 6 8 10 12 14 16 18 20 22];
xlabel('radius of objects (pixels)')
ylabel('Sum of pixel values in objects as a function of radius')

open2 = imopen(Opened,strel('disk',2));
open3 = imopen(Opened,strel('disk',3));
rad2 = imsubtract(open2,open3);
imshow(rad2)

% plot area distribution
CC = bwconncomp(Opened);
label = labelmatrix(CC);
stats = regionprops(Opened,'Area','Centroid','MajorAxisLength',...
     'MinorAxisLength','BoundingBox');
objects=1:length(stats);

stats(465).Area=0;
aa=find(label==465);
label(aa)=0;  % suppress the largest object which is noise
Opened(aa)=0;
x=1:length(stats);
 for k=1:length(stats)
     a(k)=stats(k).Area;
 end
a=sort(a);
A=bar(x,a);
title('Image object area distribution: sorted ascending')
xlabel('objects')
ylabel('object area')
hold on
line1=line([450 450],[0 250],'Color',[1 0 0]);
line2=line([512 512],[0 250],'Color',[1 0 0]);


% select two thresholds from the area distribution
figure;
subplot(221)
imshow(Opened)
subplot(2,2,[3 4])
plot(1:length(a),a)
Opened1=zeros(size(Opened));
for j = 1:length(a)
    Opened1=zeros(size(Opened));
    for k=objects
    if(stats(k).Area>a(j))
    obj=find(label==k);
    Opened1(obj)=1;
    end
    end
    subplot(222)
    imshow(Opened1)
    stext=sprintf('Threshold by %g',j);
    title(stext)
    pause(0.1)
end

% thresholding the area distribution by two thresholds
areaThresh475=Opened;
for k=objects
    if(stats(k).Area<a(475))
    obj=find(label==k);
    areaThresh475(obj)=0;
    end
end
imshow(areaThresh)

figure;
subplot(3,2,[1,2])
subplot(323)
imshow(areaThresh350)
title('(b)')
subplot(324)
imshow(areaThresh400)
title('(c)')
subplot(325)
imshow(areaThresh)
title('(d)')
subplot(326)
imshow(areaThresh475)
title('(e)')

% noise suppression
MedFiltered=medfilt2(Opened,[7 7]);
imshow(MedFiltered)



% FEATURE EXTRACTION...

% objects=length(stats);
% objects=1:objects;
% density=zeros(size(objects));
% R=zeros(size(objects));
% for j=objects
%      BBox=stats(j).BoundingBox(3)*stats(j).BoundingBox(4);
%      density(j)=stats(j).Area/BBox;
%      R(j)=stats(j).MajorAxisLength/stats(j).MinorAxisLength;
% end
% %density=density*100;
% % found empirically
% for j=objects
%     if(density(j)>0.55 && density(j)<0.57)
%         density(j)=0;
%     else if(density(j)>0.66 && density(j)<0.68)
%             density(j)=0;
%         end
%     end
% end
% den=density(density>0);

% % Selection of DR feature value density
% figure;
% subplot(221)
% imshow(Opened)
% subplot(2,2,[3 4])
% plot(1:length(den),den)
% Opened1=zeros(size(Opened));
% for j = den
%     Opened1=zeros(size(Opened));
%     for k=objects
%         BBox=stats(k).BoundingBox(3)*stats(k).BoundingBox(4);
%     if(stats(k).Area/BBox==j)
%     obj=find(label==k);
%     Opened1(obj)=1;
%     end
%     end
%     subplot(222)
%     imshow(Opened1)
%     stext=sprintf('Threshold by %g',j);
%     title(stext)
%     pause(0.5)
% end
 

% Selection of DR feature value R
% figure;
% subplot(221)
% imshow(Opened)
% subplot(2,2,[3 4])
% plot(1:length(R),R)
% Opened1=zeros(size(Opened));
% for j = R(450:475)
%     Opened1=zeros(size(Opened));
%     for k=objects
%     if(stats(k).MajorAxisLength/stats(k).MinorAxisLength==j)
%     obj=find(label==k);
%     Opened1(obj)=1;
%     end
%     end
%     subplot(222)
%     imshow(Opened1)
%     stext=sprintf('Threshold by %g',j);
%     title(stext)
%     pause(0.5)
% end
 
 
 
