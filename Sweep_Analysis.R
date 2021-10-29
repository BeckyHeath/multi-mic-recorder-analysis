########################################################################### .
# Scripts for Comparing Wateroofed vs. Non-Waterproofed Sweeps
#
# Becky Heath
# r.heath18@imperial.ac.uk
#
# Autumn 2021

##### Load Packages and set working directory #####

library(seewave)
library(soundecology)
library(tuneR)


setwd(dirname(rstudioapi::getActiveDocumentContext()$path))


##### Define Test File Location #####

file_directory = "Data/Lab_Localisation/Audio_Data_Edited/Files_standardised"


##### Define Functions #####

# tbc 


##### Run Audio Analysis ####

# TODO make this iterative 
files <- list.files(file_directory, recursive = FALSE)

in_file <- files[8] # just the single - channel test file for now
path <- paste(file_directory,in_file, sep = "/")

# Load in Audio 

# Looking through this: https://cran.r-project.org/web/packages/tuneR/tuneR.pdf 
audio_file <- readWave(path)

power_spectrum <- spec(audio_file) #LOOK UP SPEC- ADD IN ALL THE EXRA DATA TOO GO BACK OVER LORENZO'S EMAIL 


