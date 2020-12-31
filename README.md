# Image Classification of White Blood Cells with Machine Learning

```matlab
I = imread(imagepath); % READ **IMAGEPATH** INTO ARRAY
J = rgb2hsv(I)(:,:,2); % convert from rgb to hsv and select channel 2
K = imsmooth(J,"P&M",1); % smoothing with anisotropic diffusion

X = imadjust(K,[0.1;1.0],[0;1]); % adjust pixel intensities
X = X - edge(X,"LoG"); % LoG edge detection and removal
X = imsmooth(X,"P&M",1); % smoothing with anisotropic diffusion
```

```matlab
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
```

```matlab
% Nucleus Recognition and Removal of Other Objects
A = imsmooth(Z,"Gaussian",2); % merge pixels belonging to each "object"
tmp = bwlabel(A); % label pixels of each object by object's number
ct = length(unique(tmp)) - 1; % find total number of objects
ht = histc(tmp(:),1:ct); % bincount of pixels by label
val = find(ht == max(ht)); % find label corresponding to largest object
N = im2bw(Z - (tmp != val)); % remove all smaller objects from image
F = (im2uint8(J)).^N; % extract grayscale nucleus from original image
```

```matlab
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
```

```r
library(tidyverse)

headers <- read_csv("headers.csv", col_names = FALSE) %>% t() %>% as.vector()
data <- read_csv("data.csv", col_names = headers)
```

```r
# set train fraction value
f = 0.10

# shuffle and clean data
set.seed(1234)
old.data = data
row.idx = nrow(data) %>% sample()
data = data[row.idx,] %>% select(-filenum) %>% mutate(celltype = as.factor(celltype))
```

```r
# split into train/test by row index
n = nrow(data)
x = (n * f) %>% floor()
train.idx = sample(1:n,x) %>% sort()
test.idx = (1:n)[-train.idx]
```

```r
# standardize data to mean = 0 and sd = 1
unscaled.data = data
tmp = data %>% select(-celltype) %>% scale() %>% as_tibble()
data[,1:13] = tmp
attach(data)
```

```r
# separate predictor variables from response variable
train.X = data[train.idx,] %>% select(-celltype)
test.X = data[test.idx,] %>% select(-celltype)
train.Y = celltype[train.idx]
test.Y = celltype[test.idx]
```

```r
# use k-nearest neighbors algorithm
library(class)
knn.pred = knn(train.X, test.X, train.Y, k = 1)
```

```r
# Get confusion matrix to see hits and misses
table(knn.pred, test.Y)
# knn.pred lymp mono neut
#     lymp   36    3    0
#     mono    4   38    0
#     neut    1    1   43

# Get test accuracy
sum(knn.pred == test.Y) / length(test.Y)
# [1] 0.9285714
```
