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
library(tidyverse)
library(scales)
library(ggplot2)
library(tidyquant)

#### Load in files ####

# Set wd and initialise 
setwd("C:/Users/becky/Desktop/Github/multi-mic-recorder-analysis/multi-mic-recorder-analysis")

# Load in Relevant data
recStatus <- read.csv("Data/Recorder_status.csv")
boxMeta <- read.csv("Data/BoxData_Apr14.csv")


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
combinedDF <- full_join(long,boxMeta, by = c("date","Recorder"))

##### Get data about the recordings #####


# Finding totals accross the whole dataset: 
recMeta <- data.frame(Recorder = character(),
                       Phase = character(),
                       recHours = numeric(),
                       recVol = numeric())

# Iterate through recorders and phases and get meta info
for(i in levels(as.factor(combinedDF$Recorder))){
  recorder = i 
  singleRec <- combinedDF[combinedDF$Recorder == recorder,]
  for(j in levels(as.factor(singleRec$value))){
    phase = j
    singlePhase <- singleRec[singleRec$value == phase,]
    
    # Get Data 
    numHours = (sum(singlePhase$numFiles,na.rm = TRUE)*10)/60 # TEN MINUTE RECORDINGS 
    numHours = round(as.numeric(numHours), digits = 2) # 2 dp 
    
    dataVol = (sum(singlePhase$TotFileSizeMB, na.rm = TRUE))/1000
    
    # Write to df 
    outLine <- data.frame(recorder, phase, numHours, dataVol)
    recMeta <- rbind(recMeta, outLine)
    
  }
  
}

# Get Totals 
metaTotals <- data.frame(Phase = character(),
                      recHours = numeric(),
                      recVol = numeric())

for(i in levels(as.factor(recMeta$phase))){
  phase = i
  singlePhase <- recMeta[recMeta$phase == phase,]
  
  recHours = sum(singlePhase$numHours, na.rm = TRUE)
  recVol = sum(singlePhase$dataVol, na.rm = TRUE)#
  
  outLine = data.frame(phase, recHours, recVol)
  metaTotals = rbind(metaTotals,outLine)
}

# Finding the per diem recorder numbers 

fieldPhases <- c("conifer","oak")
fieldRecs <- combinedDF[combinedDF$value == fieldPhases,]



# Graph the actual recording period

fullDep <- fieldRecs %>% filter(date >= "2021-08-25")
fullDep <- fullDep %>% filter(date <= "2022-01-22")

tot <- sum(fullDep$TotFileSizeMB,na.rm='True')

fullDep$date <- as.Date(fullDep$date)

cols <- c("darkgreen","gold1","yellowgreen","steelblue3")

Recs <-ggplot(fullDep, aes(x=date, y= numFiles,col = Recorder, fill = Recorder))+
  scale_x_date(breaks = "1 month", minor_breaks = "1 week", labels = date_format("%B")) +
  scale_colour_manual(values=cols,labels=c("ANSW1","PAWS1","PAWS2","ANSW2")) +
  scale_fill_manual(values=cols, labels=c("ANSW1","PAWS1","PAWS2","ANSW2")) +
  geom_point(shape = 4,alpha=1) +
  geom_ma(ma_fun = SMA, n = 5, size = 0.8 , aes(linetype = "solid")) +    
  scale_y_continuous(limits= c(0,150), oob = squish)+
  labs(x= "Date")+
  labs(y= "Daily Uploads (max 144)")+
  theme_minimal()+
  theme(legend.position = c(0.9,0.79))+
  guides(linetype = "none")+
  theme(legend.title=element_text(size=9), 
        legend.text=element_text(size=8))
Recs

ggsave("Figures/RecNumbers5Day.png", width = 5.4, height = 3.2, device='png', dpi=700)


rm(Recs) 

# Present data in hours 

fullDep$numFiles <- fullDep$numFiles/6

cols <- c("darkgreen","gold1","yellowgreen","steelblue3")

Recs <- ggplot(fullDep, aes(x=date, y= numFiles,col = Recorder, fill = Recorder))+
  scale_x_date(breaks = "1 month", minor_breaks = "1 week", labels = date_format("%B")) +
  scale_colour_manual(values=cols,labels=c("ANSW1","PAWS1","PAWS2","ANSW2")) +
  scale_fill_manual(values=cols, labels=c("ANSW1","PAWS1","PAWS2","ANSW2")) +
  geom_point(shape = 4,alpha=0.5) +
  geom_smooth(method = lm, formula = y ~ splines::bs(x, 3), alpha = 0.0)+
  scale_y_continuous(limits= c(0,24), oob = squish)+
  labs(x= "Date")+
  labs(y= "Hours of Uploaded Data (daily)")+
  theme_minimal()+
  theme(legend.title=element_text(size=9), 
        legend.text=element_text(size=8))+
  theme(legend.position = c(0.85,0.75))
Recs

ggsave("Figures/RecHours.png", width = 5.4, height = 3.2, device='png', dpi=700)
rm(Recs) 





