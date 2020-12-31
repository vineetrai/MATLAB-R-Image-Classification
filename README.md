# wbc_ml
Image Recognition and Machine Learning Classification of White Blood Cells

```matlab
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
