#!/bin/bash
#Run the R code using Rscript function 
#arguments passed - R file location , Input File Location and Output file Location
#Code to run only the median function and not the graphs
Rscript ./src/get_median.R ./venmo_input/venmo-trans.txt ./venmo_output/output.txt

#commented code to get median with plots
#Rscript ./src/get_median_and_plot.R ./venmo_input/venmo-trans.txt ./venmo_output/output.txt