########################################################################### .
# Script to Consolidate and graph field data volumes from Box
# Files generated either maually of through "MetadataFromBoxADD_OWN_DETAILS.m"
#
# Becky Heath
# r.heath18@imperial.ac.uk
#
# Spring 2022

##### Load Packages and set working directory #####
library(data.table)
library(dplyr)

#### Load in files ####

# Set wd and initialise 
setwd("C:/Users/becky/Desktop/Github/multi-mic-recorder-analysis/multi-mic-recorder-analysis")

# Load in Relevant data
recStatus <- read.csv("Data/Recorder_status.csv")
boxMeta <- read.csv("Data/Full_FileNo_Data.csv")


###### join dataframes #####

# Consolidate Recorder Names so they're the same 

# Convert the box directory names to just recorder colour 
j=1
for(i in boxMeta$Recorder){
  splitLabel <- strsplit(i, "_")
  size <- length(splitLabel[[1]])
  newLabel <- splitLabel[[1]][size]
  newLabel <- tolower(newLabel)
  boxMeta$Recorder[j] = newLabel
  j=j+1
}
  


# Alighn DF properties to make sure they're compatible 
names(recStatus)[1] <- "date"
boxMeta$Recorder <- as.factor(boxMeta$Recorder)
long <- melt(setDT(recStatus), id.vars = c("date"), variable.name = "Recorder")


# Join the dataframes
newFile <- full_join(long,boxMeta, by = c("date","Recorder"))

# Seperate out by recorder 

# Sumup recording hours from each 

# Look at graphing 