dir = "C:/Users/RV/Google Drive/ImageRecognition/Main Dataset";
% **SET WORKING DIRECTORY**
imtype = "bmp"; % **SET IMAGE FILETYPE**




cd(dir);
pkg load image;
pkg load io;

arr = cell(0,0); % initialize feature data cell array
folders = glob("*_cells"); % get folder names containing cell images

for i = 1:length(folders) % for each folder in sequence
  
  cd(dir);
  folname = folders{i}
  celltype = strsplit(folname,"_"){1};
  folpath = cat(2,dir,"/",folname);
  cd(folpath); % open folder
  pics = glob(cat(2,"*",imtype));
  cd(dir);
  
  for j = 1:length(pics) % for each image in folder
    
    filename = pics{j};
    filenum = strsplit(filename,cat(2,".",imtype)){1};
    imagepath = cat(2,folpath,"/",filename);
    feature_extract; % call feature extraction script
    datarow = num2cell(data);
    datarow = cat(2,datarow,filenum,celltype);
    arr = cat(1,arr,datarow); % record feature and image id data
    
    cd(folpath);
    imwrite(multi,cat(2,filenum,"_montage",".",imtype)); % write montage image
    cd(dir);
  
  endfor

endfor

headers = cat(1,headers,"filenum","celltype");
headers = headers';
arr = cat(1,headers,arr);