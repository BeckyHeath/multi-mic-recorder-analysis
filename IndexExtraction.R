###################################################################################
## Script for Extracting Analytical Indices
## January 2020
## from: https://github.com/BeckyHeath/Experimental-Variation-Ecoacoustics-Analysis-Scripts
##
## Edited *considerably* January 2022 to analyse different dataset 
## (and no longer running on cluster)
##
# Different metrics can be used - see soundecology 
# ACI = measures how variable sounds are (go minutewise to avoid bias)
# ADI = divs spectrum into bins and calculates level in each(shannen shifted)
# AEI = divs spectrum into bins and calculates level in each(gini shifted)
# Bio = Frequency band occupancy?
# NDSI = compares anthro noise and biological noise (set bands only)
##
## Becky Heath 
###################################################################################
library(seewave)
library(soundecology) # cite 
library(warbleR)  # cite warbleR 
library(tuneR) 


# Set wd and initialise 
setwd("C:/Users/becky/Desktop/Github/multi-mic-recorder-analysis/multi-mic-recorder-analysis")

#Setup path to and audio directories
dirPath = "Data"
dirNames = list("green","blue","yellow", "yellowgreen")
chNo = 6 # channel numbers

# Set Up Output df
out.file <- data.frame(foler = character(),
                       fileName = character(),
                       ch1 = numeric(),
                       ch2 = numeric(),
                       ch3 = numeric(),
                       ch4 = numeric(),
                       ch5 = numeric (),
                       ch6  = numeric (), 
                       numOutlier = numeric())


outLine = data.frame(0,0,0,0,0,0,0,0,0)

for(i in dirNames){
  
  # Define Path and find Subdirs
  rootPath <- paste(dirPath,"/",i, sep="")
  dirs <- list.dirs(rootPath)
  
  # Iterate through all subdirs 
  for(j in dirs){
    
    # find the files that just end in wav
    for(k in dir(j, pattern = ".wav")){
      
      outLine[1] = j
      outLine[2] = k
      
      
      # Define path to file
      filePath <- paste(j,"/",k,sep="")
      
      # Read in and analyse audio channel by channel
      for(l in 1:chNo){
        aud = read_wave(filePath, channel = l) # Channel = L (l), not one (1)
        
        # Calculate Index (BIO
        
        index.list = ndsi(aud, bio_max = 8000)
        index = as.numeric(index.list$ndsi_left)
        
        # save to the outLine
        outLine[l + 2] = index
      }
      
      outLine[9] = "y"
      
      out.file = rbind(out.file, outLine)
      
      outLine = data.frame(0,0,0,0,0,0,0,0,0)
      
      print(paste(filePath, " Done"))
    }
  }
  
  fileName = paste(dirPath,"/",i,"_NDSIdata.csv",sep="")
  write.table(out.file, file = fileName, sep = ",", append = TRUE, quote = FALSE,
              col.names = FALSE, row.names = FALSE)  
} 

