% call: meanfilter2D.m
% John Jenkinson UTSA ECE, November 14, 2014
%
% f - input image; mask - size of neighborhood mask
% Also called the moving average filter.

function[fAVG]=meanfilter2D(f,mask)

    [M N L]=size(f);
    [m n]=size(mask);
    mpad=floor(m/2);
    npad=floor(n/2);
    
    a=(m-1)/2;
    b=(n-1)/2;
    amax=(2*a)+1;
    bmax=(2*b)+1;
 g=zeros(size(f));
    for x=1+mpad:M-amax
        for y=1+npad:N-bmax
            for s=a:(2*a)+1
                for t=b:(2*b)+1
g(x,y)=(mask(s,t)*f(x+s,y+t))/sum(mask(:));
                end
            end
        end
    end
    
end

% AMG
% function[fAVG]=meanfilt2D(fmiddle3rd,mask)
% 
% 
%     [M N L]=size(fmiddle3rd);
% 
%     [m n]=size(mask);
%     mpad=floor(m/2);
%     npad=floor(n/2);    
%     mask=mask/sum(sum(mask));   
% 
%     g=zeros(size(fmiddle3rd));
%     for x=1+mpad:M-mpad
%         for y=1+npad:N-npad
%                block=fmiddle3rd(x-mpad:x+mpad,y-npad:y+npad);
%                g(x,y) = sum(sum(mask.*block));
%         end
%     end
%  
% end
    
    
