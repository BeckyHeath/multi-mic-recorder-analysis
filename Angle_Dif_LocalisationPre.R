########################################################################### .
# Scripts for Analysing Pre Deployment Localisations
#
# Becky Heath
# r.heath18@imperial.ac.uk
#
# Autumn 2021/Spring 2022

##### Load Packages and set working directory #####

library(stringr)
library(ggplot2)
library(plyr)
library(patchwork)
library(tidyverse)
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))


##### Define Test File Location #####

file_directory = "Data/CompleteLabLocalisation/OutPre/raw"

AngleDifPath = "Data/CompleteLabLocalisation/AngleDifferences/PreRaw.csv"

##### Define Functions #####

# Load in true values: 
true <- read.csv("Data/CompleteLabLocalisation/Real_Location_Pre.csv") #PRE 


section_data <- function(df){
  
  # Function to group the real data into distinct time periods?? 
  # The recordings are then in groups to better compare real/predicted
  
    # 30deg mismatch in the transfer function (See HARKTOOL5)
  df$Start.azimuth <- df$Start.azimuth - 30 # do HARK config Correction
  
  # Correct for Angle Flip-over
  df$Start.azimuth[df$Start.azimuth < -180] <- (df$Start.azimuth[df$Start.azimuth < -180] + 360)
  
  
  # Make Sure Recordings are compared to the right test tone
  # Numbers not divisible by 15 will be Removed 
  #pre
  df$Start.time[df$Start.time < 20] <- 1  # Sweep Signal (ignored)
  df$Start.time[df$Start.time > 29 & df$Start.time < 33] <- 30  # First Tone  
  df$Start.time[df$Start.time > 42 & df$Start.time < 47] <- 45  # Second Tone
  df$Start.time[df$Start.time > 57 & df$Start.time < 63] <- 60  # Third Tone
  df$Start.time[df$Start.time > 72 & df$Start.time < 78] <- 75  # Fourth Tone
  df$Start.time[df$Start.time > 87 & df$Start.time < 93] <- 90  # Fifth Tone
  df$Start.time[df$Start.time > 102 & df$Start.time < 108] <- 105  # Fifth Tone
  df$Start.time[df$Start.time > 108] <- 91  # Fifth Tone (ignored)
  

  return(df)
}


Angle_Dif_Plots <- function(df,diffMatrix,label){
  
  # Creates plots showing true vs. prediced values
  
  # Merge Data 
  df <- df[, c("Start.time", "Start.azimuth")]
  names(df)[names(df) == "Start.azimuth"] <- "Predicted.Azimuth"
  
  merge_df <- merge(df, true, by=c("Start.time"),all=TRUE)
  
  names(merge_df)[names(merge_df) == "Start.azimuth"] <- "Real.Azimuth"
  merge_df_er <- merge_df[complete.cases(merge_df),]
  
  # Generate Differences:
  differences <- getDifferences(merge_df_er)
  differences <- as.data.frame(differences)
  
  
  # Apprend to difference matrix
  outDif <- differences
  outDif <- outDif %>% 
    add_column(file = label,
               .before= "x")
  
  diffMatrix <<- rbind(diffMatrix, outDif)
  
  #Print Data
  
  names(differences)[names(differences) == "x"] <- "True.Azimuth"
  
  plot <- ggplot(differences, aes(True.Azimuth, difference))+
    ggtitle(label) +
    geom_point(color = "Red", size =4, shape = 4, stroke = 1.5)+
    geom_hline(yintercept=0)+
    xlim(-180,180)+
    ylim(-180,180)+
    xlab("True Angle") + 
    #ylab("Angle Difference") +
    #annotate("text", x = -150, y = 150, label = tag) +
    theme_minimal()
  plot
  return(plot)
}


getDifferences <- function(df){
  # Finds difference (accounting for 180 + 5 = -175)!
  # It then returns an array of true v. pred for the
  # difference of smallest magnitude
  #
  #
  # df = dataframe containing true vs. pred data =
  
  # Seperate true and pred
  
  x <- df$Real.Azimuth 
  y <- df$Predicted.Azimuth
  
  
  # Calculate Differences
  dif <- y-x
  dif1 <- y - x - 360 
  dif2 <- y - x + 360
  
  # Find Smallest
  difference <- apply(cbind(dif,dif1,dif2), 1, function(z) z[which.min(abs(z))])
  
  outDf <- cbind(x,difference)
 
  names(outDf)[names(outDf) == "outDF"] <- "True.Azimuth" 
  return(outDf)
}




##### Generate Real vs. Predicted Plots ####

j=0

diffMatrix <- data.frame(file = character(),
                         x = numeric(),
                         difference = numeric(), 
                         stringsAsFactors = FALSE)


# Load in all the files you need: 
for(i in list.dirs(file_directory, recursive = FALSE)){
  path = paste(as.character(i),"sourcelist.csv", sep = "/")
  i_file = read.csv(path, sep = "\t")
  
  # Generate Label
  
  # tidy label/ graph title name: 
  label = str_remove(as.character(i), file_directory)
  label = str_remove(label,"/localized_")
  label = str_remove(label,".wav")
  label = str_remove(label,"AdjG_")
  j=j+1
  
  tag =label
  
  
  # Stop files that didn't catch any signals tripping out the loop
  if(nrow(i_file) == 0){
    next
  }
  
  i_file <- section_data(i_file)
  o_plot <- Angle_Dif_Plots(i_file,diffMatrix,label)
  
  assign(label, o_plot)
}

write.csv(diffMatrix,AngleDifPath,row.names = FALSE)


# PLOTS 

#pre

plot <- `1a_pinknoise_N_2` | `1b_bird_N_2` | `1b_bird_N_2`
plot2 <- `5a_pinknoise_Y_2` | `5b_bird_Y_2` | `5b_bird_Y_2`

plot/plot2
