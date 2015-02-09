% call: areaDist.m
% Calculate the characteristic function of object area for a binary image.
% bw is a binary image.  dist is the area distribution.  areas is a vector
% from 1 to the maximum object area value in bw, 1:max(bw).
%
% John Jenkinson, UTSA ECE, January 18, 2015.
function[dist,areas]=areaDist(bw)

    CC = bwconncomp(bw);
    label = labelmatrix(CC);
    stats = regionprops(bw,'Area');
    obj=length(stats);
    objects=1:obj;
    
    x=1:length(stats);
    for k=1:length(stats)
         a(k)=stats(k).Area;
    end
    
    amx=max(a);
    areas=1:amx;
    dist=zeros(1,length(areas));
    for k=areas
        for j=objects
            if(a(j)==k)
                dist(k)=dist(k)+1;
            end
        end
    end
    
    %plot(areas,dist)
    %hist(log(dist))
    %imhist(dist,396) 
        
end
    
