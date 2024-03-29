library(tidyverse)

headers <- read_csv("headers.csv", col_names = FALSE) %>% t() %>% as.vector()
data <- read_csv("data.csv", col_names = headers)

# set train fraction value
f = 0.10

# shuffle and clean data
set.seed(1234)
old.data = data
row.idx = nrow(data) %>% sample()
data = data[row.idx,] %>% select(-filenum) %>% mutate(celltype = as.factor(celltype))

# split into train/test by row index
n = nrow(data)
x = (n * f) %>% floor()
train.idx = sample(1:n,x) %>% sort()
test.idx = (1:n)[-train.idx]

# standardize data to mean = 0 and sd = 1
unscaled.data = data
tmp = data %>% select(-celltype) %>% scale() %>% as_tibble()
data[,1:13] = tmp
attach(data)

# separate predictor variables from response variable
train.X = data[train.idx,] %>% select(-celltype)
test.X = data[test.idx,] %>% select(-celltype)
train.Y = celltype[train.idx]
test.Y = celltype[test.idx]

# use k-nearest neighbors algorithm
library(class)
knn.pred = knn(train.X, test.X, train.Y, k = 1)


# Get confusion matrix to see hits and misses
table(knn.pred, test.Y)
# knn.pred lymp mono neut
#     lymp   36    3    0
#     mono    4   38    0
#     neut    1    1   43

# Get test accuracy
sum(knn.pred == test.Y) / length(test.Y)
# [1] 0.9285714
