clear all; close all; clc;
tw=imread('ST386_NGC5864.tif');
tw=tw(:,:,1);
[lenx,leny]=size(tw);
t=im2double(tw);
dd=zeros(lenx,leny);
avg=median(t,2);

for k=1:leny
    dd(:,k)=avg;% contains theaverage of each row
end

o=zeros(lenx,leny);
%filteration with heap transform
for k=1:lenx
    o(k,:)=analyt_heap((t(k,:)),dd(k,:));
end

%heap transformed image
mem=t-o;

%EME
E1=eme2(t,lenx,leny,10);
E2=eme2(abs(t-o),lenx,leny,10);
display('EME of the original image');
display(E1);
display('EME of the enhanced image');
display(E2);

%save the enhanced image
imwrite(mem,'ST386_NGC5864_heap.tif')
