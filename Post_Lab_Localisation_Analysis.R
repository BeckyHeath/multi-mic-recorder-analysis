########################################################################### .
# Scripts for Analysing Post Deployment Localisations
#
# Becky Heath
# r.heath18@imperial.ac.uk
#
# Autumn 2021

##### Load Packages and set working directory #####

library(stringr)
library(ggplot2)
library(plyr)
library(patchwork)
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))


##### Define Test File Location #####

file_directory = "Data/postMortem/LocalisedYellow"


##### Define Functions #####

# Load in true values: 
true <- read.csv("Data/Real_Location_Clean.csv")

section_data <- function(df){
  
  # Function to group the real data into distinct time periods?? 
  # The recordings are then in groups to better compare real/predicted
  #
  # recallibrate start position to -180 
  # 30deg mismatch in the transfer function (See HARKTOOL5)
  
  df$Start.azimuth <- df$Start.azimuth - 30 # do HARK config Correction
  df$Start.azimuth <- df$Start.azimuth - 180 # do experiment orientation correction
  
  # Correct for Angle Limitations
  df$Start.azimuth[df$Start.azimuth < -180] <- (df$Start.azimuth[df$Start.azimuth < -180] + 360)
  
  # Numbers not divisible by 15 will be Removed 
  
  df$Start.time[df$Start.time < 7] <- 1  # Sweep Signal (ignored)
  df$Start.time[df$Start.time > 14 & df$Start.time < 21] <- 15  # First Tone  
  df$Start.time[df$Start.time > 27 & df$Start.time < 36] <- 30  # Second Tone
  df$Start.time[df$Start.time > 42 & df$Start.time < 51] <- 45  # Third Tone
  df$Start.time[df$Start.time > 57 & df$Start.time < 66] <- 60  # Fourth Tone
  df$Start.time[df$Start.time > 72 & df$Start.time < 81] <- 75  # Fifth Tone

  return(df)
}


true_pred_plots <- function(df,tag,label){
  
  # Creates plots showing true vs. predicted values
  
  # Merge Data 
  df <- df[, c("Start.time", "Start.azimuth")]
  df <- rename(df, c("Start.azimuth" = "Predicted.Azimuth"))
  merge_df <- merge(df, true, by=c("Start.time"),all=TRUE)
  merge_df <- rename(merge_df, c("Start.azimuth" = "Real.Azimuth"))
  merge_df_er <- merge_df[complete.cases(merge_df),]
  
  dif <- merge_df_er$Real.Azimuth - merge_df_er$Predicted.Azimuth
  difLabel = paste("dif_",label, sep="")
  assign(difLabel, dif, envir = .GlobalEnv)
  
  error_data <- find_error(merge_df_er$Real.Azimuth, merge_df_er$Predicted.Azimuth)
  printout <- paste0("\n###############\nFile:", label, "\nMean Error:", error_data[1],"\nSD:", error_data[2], "\nR_sq:", error_data[3])
  cat(printout)
  
  plot <- ggplot(merge_df, aes(Real.Azimuth, Predicted.Azimuth))+
    ggtitle(label_g) +
    geom_point(color = "Red", size =4, shape = 4, stroke = 1.5)+
    geom_abline(color= "black", size = 0.6, alpha = 0.5) +
    xlim(-180,180)+
    ylim(-180,180)+
    xlab("Predicted") + 
    ylab("True") +
    annotate("text", x = -150, y = 150, label = tag) +
    theme_minimal()
  
  return(plot)
}


find_error <- function(x,y){
  # finds the mean and sd of the error and r-sq where:
  # x = real 
  # and y = predicted
  dif <- y-x
  dif = dif * dif 
  dif = sqrt(dif)
  mean_val <- mean(dif)
  sd_val <- sd(dif)
  r_sq <- 1-sum((x-y)^2)/sum((x - mean(x))^2)
  out <- c(mean_val,sd_val,r_sq)
  return(out)
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
  label = str_remove(label,".wav")
  j=j+1
  
  
  # Set Graph Labels (Tags)
  tags = array(data=c('A','C','B','D'))
  tag = tags[j]
  
  print(paste0("J = ",j))
  
  if(j == 1){
    label_g = "Not Weatherproofed"
  } else if(j==3){
    label_g = "Weatherproofed"
  } else {
    label_g =""
  }
  
  # Stop files that didn't catch any signals tripping out the loop
  if(nrow(i_file) == 0){
    next
  }
  
  i_file <- section_data(i_file)
  o_plot <- true_pred_plots(i_file,tag,label)
  
  assign(label, o_plot)
}




# Patchwork Plots 
plot <- `Yellow_Bird` | `Yellow_Pink02`

plot



