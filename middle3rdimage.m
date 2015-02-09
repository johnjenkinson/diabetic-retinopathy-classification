% call: middle3rdimage.m
% John Jenkinson UTSA ECE October 26, 2014
%
% Crop the middle 3rd of the image to 
% process for optic disc (OD) removal.
%
function[fmiddle3rd]=middle3rdimage(fGreen);

    [N M L]=size(fGreen);
    fmiddle3rd=fGreen(N/3:N-(N/3),:);

end
