% pkg load image;
I = imread(imagepath); % READ **IMAGEPATH** INTO ARRAY

J = rgb2hsv(I)(:,:,2); % convert from rgb to hsv and select channel 2
K = imsmooth(J,"P&M",1); % smoothing with anisotropic diffusion

X = imadjust(K,[0.1;1.0],[0;1]); % adjust pixel intensities
X = X - edge(X,"LoG"); % LoG edge detection and removal
X = imsmooth(X,"P&M",1); % smoothing with anisotropic diffusion

% Thresholding to Isolate Nucleus
% runs thresholding with "i" levels
% extract pixels at all levels greater "j" if they total <1% image area
Y = X*0;
for i = 2:6
  for j = 0:(i - 1)
    tmp = (grayslice(X,i) > j);
    avg = mean(tmp(:));
    if (avg > 0) && (avg < 0.01)
      Y += tmp;
    endif
  endfor
endfor

% fill holes in object and background
Z = bwareaopen(Y,300);
Z = bwareaopen(!Z,50);
Z = !Z;

% Nucleus Recognition and Removal of Other Objects
A = imsmooth(Z,"Gaussian",2); % merge pixels belonging to each "object"
tmp = bwlabel(A); % label pixels of each object by object's number
ct = length(unique(tmp)) - 1; % find total number of objects
ht = histc(tmp(:),1:ct); % bincount of pixels by label
val = find(ht == max(ht)); % find label corresponding to largest object
N = im2bw(Z - (tmp != val)); % remove all smaller objects from image

F = (im2uint8(J)).^N; % extract grayscale nucleus from original image
multi = cat(2,J,X,Y,N);
% montage(multi);

% Feature Extraction from Binary Image of Nucleus
data = (1:13)*0;
fts = regionprops(N,"ConvexArea","Eccentricity","EquivDiameter",...
                    "Extent","FilledArea","MajorAxisLength","Solidity");

data(1) = bwarea(N);
data(2) = bwconncomp(N).NumObjects;
data(3) = bweuler(N);
data(4) = sum(bwperim(N)(:));
data(5) = fts.ConvexArea;
data(6) = fts.Eccentricity;
data(7) = fts.EquivDiameter;
data(8) = fts.Extent;
data(9) = fts.FilledArea;
data(10) = fts.MajorAxisLength;
data(11) = fts.Solidity;
data(12) = sum(F(:)); % mean grayscale intensity
data(13) = entropy(F);

headers = ["bwarea";"bwconncomp";"bweuler";"sumbwperim";"convexarea";
"eccentricity";"equivdiameter";"extent";"filledarea";"majoraxislength";
"solidity";"meangrayintensity";"entropy"];
headers = cellstr(headers);