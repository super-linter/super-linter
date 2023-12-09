#!/usr/bin/env bash

mkdir -p /home/r-library
cp -r /usr/lib/R/library/ /home/r-library/
Rscript -e "install.packages(c('lintr','purrr'), repos = 'https://cloud.r-project.org/')"
R -e "install.packages(list.dirs('/home/r-library',recursive = FALSE), repos = NULL, type = 'source')"
mv /etc/R/* /usr/lib/R/etc/
