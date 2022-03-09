########################################################################### .
# Script to Consolidate and graph field data volumes from Box
# Files generated either maually of through "MetadataFromBoxADD_OWN_DETAILS.m"
#
# Becky Heath
# r.heath18@imperial.ac.uk
#
# Spring 2022

##### Load Packages and set working directory #####


#### Load in files ####
# Set wd and initialise 
setwd("C:/Users/becky/Desktop/Github/multi-mic-recorder-analysis/multi-mic-recorder-analysis")


# Load in Relevant data 
recStatus <- read.csv("Data/Recorder_status.csv")
boxMeta <- read.csv("Data/Full_FileNo_Data.csv")

# Consolidate Recorder Names so they're the same 

# Join the dataset 

# Seperate out by recorder 

# Sumup recording hours from each 

# Look at graphing 