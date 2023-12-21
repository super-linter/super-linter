#!/usr/bin/env Rscript

# Based on: https://stackoverflow.com/questions/26244530/how-do-i-make-install-packages-return-an-error-if-an-r-package-cannot-be-install

packages = commandArgs(trailingOnly=TRUE)

for (l in packages) {
  install.packages(l, repos='https://cloud.r-project.org/');
  if ( ! library(l, character.only=TRUE, logical.return=TRUE) ) {
    quit(status=1, save='no')
  }
}
