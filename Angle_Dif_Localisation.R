########################################################################### .
# Scripts for Analysing Post Deployment Localisations
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

file_directory = "Data/postMortem/AllFiles/yellowOUT/Thresh27"


##### Define Functions #####

# Load in true values: 
true <- read.csv("Data/Real_Location_Clean2.csv")

section_data <- function(df){
  
  # Function to group the real data into distinct time periods?? 
  # The recordings are then in groups to better compare real/predicted
  #
  # recallibrate start position to -180 
  # 30deg mismatch in the transfer function (See HARKTOOL5)
  
  df$Start.azimuth <- df$Start.azimuth - 30 # do HARK config Correction
  df$Start.azimuth <- df$Start.azimuth - 180 # do experiment orientation correction
  
  # Correct for Angle Flip-over
  df$Start.azimuth[df$Start.azimuth < -180] <- (df$Start.azimuth[df$Start.azimuth < -180] + 360)
  
  # Numbers not divisible by 15 will be Removed 
  
  df$Start.time[df$Start.time < 7] <- 1  # Sweep Signal (ignored)
  df$Start.time[df$Start.time > 14 & df$Start.time < 19] <- 15  # First Tone  
  df$Start.time[df$Start.time > 29 & df$Start.time < 31] <- 30  # Second Tone
  df$Start.time[df$Start.time > 44 & df$Start.time < 46] <- 45  # Third Tone
  df$Start.time[df$Start.time > 59 & df$Start.time < 61] <- 60  # Fourth Tone
  df$Start.time[df$Start.time > 74.49 & df$Start.time < 77] <- 75  # Fifth Tone

  return(df)
}


Angle_Dif_Plots <- function(df,tag,label){
  
  # Creates plots showing true vs. prediced values
  
  # Merge Data 
  df <- df[, c("Start.time", "Start.azimuth")]
  names(df)[names(df) == "Start.azimuth"] <- "Predicted.Azimuth"
  
  merge_df <- merge(df, true, by=c("Start.time"),all=TRUE)
  
  names(merge_df)[names(merge_df) == "Start.azimuth"] <- "Real.Azimuth"
  merge_df_er <- merge_df[complete.cases(merge_df),]
  
  differences <- getDifferences(merge_df_er)
  differences <- as.data.frame(differences)
  names(differences)[names(differences) == "x"] <- "True.Azimuth"
  
  plot <- ggplot(differences, aes(True.Azimuth, difference))+
    ggtitle(label_g) +
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

# Load in all the files you need: 
for(i in list.dirs(file_directory, recursive = FALSE)){
  path = paste(as.character(i),"sourcelist.csv", sep = "/")
  i_file = read.csv(path, sep = "\t")
  
  # Generate Label
  
  # tidy label/ graph title name: 
  label = str_remove(as.character(i), file_directory)
  label = str_remove(label,"/localized_")
  label = str_remove(label,"_PostMortem")
  label = str_remove(label,"Loc")
  label = str_remove(label,".wav")
  label = str_remove(label,"AdjG_")
  j=j+1
  
  tag = str_remove(label,".*_")
  tag = gsub('[[:digit:]]+', '', tag)
  
  # Set Graph Labels (Tags)
  print(paste0("J =",tag))
  
  if(tag == "pink"){
    label_g = "Pink Noise"
  } else if(tag=="bird"){
    label_g = "Bird Song"
  } else {
    label_g ="??????"
  }

  tag =label_g
  
  
  # Stop files that didn't catch any signals tripping out the loop
  if(nrow(i_file) == 0){
    next
  }
  
  i_file <- section_data(i_file)
  o_plot <- Angle_Dif_Plots(i_file,tag,label)
  
  assign(label, o_plot)
}




# Patchwork Plots This is to see all plots 
plot <- `YelloGreen_bird01` | `YelloGreen_bird02` | `YelloGreen_bird03`
plot2 <- `YelloGreen_pink01`| `YelloGreen_pink02` | `YellowGreen_flipped_bird01`

plot/plot2

Plot <- `Yellow_bird01` | `Yellow_pink03` |`YelloGreen_bird02` | `YelloGreen_pink02` 
Plot


