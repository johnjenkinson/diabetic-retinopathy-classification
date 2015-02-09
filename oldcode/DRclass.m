% call: DRclass.m
% classify DR spots in fundus images.
%
% John Jenkinson, UTSA ECE January 6, 2015.
% Last Modified: 2015/1/8

original = imread('test.tif'); % read pathological Messidor image
green = original(:,:,2);
% ODx=ODremovalMessidor(f); % optic disc removal

% grayscale set operations
discSize = [3 5 15];
for j = discSize
se = strel('disk',j);
opened = imopen(green,se); % morphological opening
closed = imclose(green,se); % morphological closing
tophatFiltered = imtophat(green,se); % top-hat transform
tophatLimits = stretchlim(tophatFiltered);
tophatEnhanced = imadjust(tophatFiltered,[tophatLimits(1) tophatLimits(2)]);
bothatFiltered = imbothat(green,se); % bottom-hat transform
bothatLimits = stretchlim(bothatFiltered); % image filling
bothatEnhanced = imadjust(bothatFiltered,[bothatLimits(1) bothatLimits(2)]);
filled = imfill(green); % fill holes of intensity image
label = watershed(green); % create label matrix of watershed regions
waterShed = label2rgb(label,'cool'); % convert regions to rgb image

figure;
imshow(green)
figure;
imshow(opened)
figure;
imshow(closed)
figure;
imshow(tophatEnhanced)
figure;
imshow(bothatEnhanced)
figure;
imshow(waterShed)

end

% binary set operations
level = graythresh(green); % compute threshold level
bw = im2bw(green,level); % create binary threshold image

figure;
imshow(bw)





