#!/usr/bin/env Rscript

# semgrep should skip this file.

args = commandArgs(trailingOnly=TRUE)

if (length(args)!=1)
  stop("Need a report file.\n", call.=FALSE)

library(ggplot2,quietly = TRUE, warn.conflicts = FALSE)

g = ggplot(report)
