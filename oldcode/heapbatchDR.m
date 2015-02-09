% call: heapbatchDR.m
% John Jenkinson UTSA ECE Nov. 2014
% batch image heap transform processing 
% 50 minutes for Base11 processing.

tic
% create file names list
files=dir('Base11/*.tif');
s_dir=pwd;

for id=1:length(files)
    
    % process images by heap transform
    cd Base11
    tw=imread(files(id).name);
    cd(s_dir)
    tw=tw(:,:,2);
    [lenx,leny]=size(tw);
    t=im2double(tw);
    med=median(t,2); % median of each row

    dd=zeros(lenx,leny);
    for k=1:leny
        dd(:,k)=med;% contains the median of each row
    end

    o=zeros(lenx,leny);
    %filteration with heap transform
    for k=1:lenx
        x=t(k,:); 
        z=dd(k,:);
        [o1,U1]=msob(x,z);
        o(k,:)=o1;        
        % o(k,:)=analyt_heap((t(k,:)),dd(k,:));
    end

    %heap transformed image
    mem=t-o;

    % construct output file name
    [~,files_name,files_ext]=fileparts(files(id).name);
    output_name=strcat(files_name,'_heap',files_ext);
    
    % write output file to directory
    cd Base11_heap2
    imwrite(mem,output_name);
    cd(s_dir)

end
toc
