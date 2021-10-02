########################################################################### .
# Localisation Accuracy Scripts
#
# Becky Heath
# r.heath18@imperial.ac.uk
#
# Autumn 2021

##### Load Packages and set working directory #####
library(stringr)
library(ggplot2)
library(patchwork)
library(tibble)
library(tidyverse)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))


##### Define Test File Location #####

file_directory = "HARKBird_Localisation_Test_FEB2021/no_intro_thresh=28"


##### Define Functions #####

# Load in true values: 
true <- read.csv("HARKBird_Localisation_Test_FEB2021/Real_Location.csv")

section_data <- function(df){
  
  # Function to group the real data into distinct time periods?? idk if useful
  df$Start.time[df$Start.time < 15] <- 0
  df$Start.time[df$Start.time > 15 & df$Start.time < 30] <- 15
  df$Start.time[df$Start.time > 30 & df$Start.time < 45] <- 30
  df$Start.time[df$Start.time > 45 & df$Start.time < 60] <- 45
  df$Start.time[df$Start.time > 60 & df$Start.time < 75] <- 60
  df$Start.time[df$Start.time > 75 & df$Start.time < 90] <- 75
  df$Start.time[df$Start.time > 90 & df$Start.time < 105] <- 90
  df$Start.time[df$Start.time > 105 & df$Start.time < 120] <- 105
  df$Start.time[df$Start.time > 120 & df$Start.time < 135] <- 120
  return(df)
}

plot_data_targets <- function(df){
  
  # Creates plots showing little grey targets (true values) vs the predicted azimuth in red
  
  # Combine the Data
  df$value <- as.character("predicted")
  df <- df[, c("Start.time", "Start.azimuth", "value")]
  true_ <- true[, c("Start.time", "Start.azimuth", "value")]
  comp <- rbind(df, true_)
  
  plot <- ggplot(data = comp, aes(Start.time, Start.azimuth, color = value, size = value, alpha = value, shape = value)) +
    ggtitle(label) + 
    scale_color_manual(values = c("red","black")) +
    scale_size_manual(values = c(1.8,8)) +
    scale_alpha_manual(values = c(1,0.25)) +
    scale_shape_manual(values = c(4,19)) +
    geom_point() + 
    xlim(0,100) +
    ylim(-180,180)+
    ylab("Azimuth")+
    xlab("Time Point")+
    theme_minimal() +
    theme(legend.position = "none")
  return(plot)
}


true_pred_plots <- function(df){
  
  # Creates plots showing true vs. predicted values
  
  # Merge Data 
  df <- df[, c("Start.time", "Start.azimuth")]
  df <- rename(df, Predicted.Azimuth = Start.azimuth)
  merge_df <- merge(df, true, by=c("Start.time"),all=TRUE)
  merge_df <- rename(merge_df, Real.Azimuth = Start.azimuth)
  
  
  # TODO: Get some stats for this at some point 
  plot <- ggplot(merge_df, aes(Real.Azimuth, Predicted.Azimuth))+
    geom_point(color = "Red", size =4, shape = 4)+
    geom_abline(color= "black", size = 0.6) +
    xlim(-180,180)+
    ylim(-180,180)+
    theme_minimal()
  
  plot
  
  
  return(plot)
}





##### Generate Target Figures ####

# Load in all the files you need: 
for(i in list.dirs(file_directory, recursive = FALSE)){
  path = paste(as.character(i),"sourcelist.csv", sep = "/")
  i_file = read.csv(path, sep = "\t")
  
  # Stop files that didn't catch any signals tripping out the 
  # loop by adding an extra row
  if(nrow(i_file) == 0){
    i_file <- add_row(i_file)
  }
    
    # tidy label/ graph title name: 
  label = str_remove(as.character(i), file_directory)
  label = str_remove(label,"/localized_")
  label = str_remove(label,".wav")
      
  i_file <- section_data(i_file)
    
  o_plot <- plot_data_targets(i_file)
    
  assign(label, o_plot)
}

# Patchwork Plots 
# TODO: Still needs some formatting fixes
plot <- `1a_pinknoise_N_2`| `1a_pinknoise2_N_2` | `1b_bird_N_2`
plot2 <- `7a_pinknoise_N_3` | `5a_pinknoise_Y_2`| `5b_bird_Y_2`

plot/plot2

##### Generate Real vs. Predicted Plots ####

# Load in all the files you need: 
for(i in list.dirs(file_directory, recursive = FALSE)){
  path = paste(as.character(i),"sourcelist.csv", sep = "/")
  i_file = read.csv(path, sep = "\t")
  
  # Stop files that didn't catch any signals tripping out the loop
  if(nrow(i_file) == 0){
    next
  }
  
  # tidy label/ graph title name: 
  label = str_remove(as.character(i), file_directory)
  label = str_remove(label,"/localized_")
  label = str_remove(label,".wav")
  
  i_file <- section_data(i_file)
  
  o_plot <- true_pred_plots(i_file)
  
  assign(label, o_plot)
}

# Patchwork Plots 
# TODO: Still needs some formatting fixes
plot <- `1a_pinknoise_N_2`| `1a2_pinknoise_N_2` | `1b_bird_N_2`
plot2 <- `7a_pinknoise_N_3` | `5a_pinknoise_Y_2`| `5b_bird_Y_2`

plot/plot2

`1a_pinknoise_N_2`
`1a_pinknoise2_N_2`
`1a2_pinknoise_N_2`
`1b_bird_N_2`
`3a_pinknoise_Y_3` # PROBLEM 
`5a_pinknoise_Y_2`
`5b_bird_Y_2` # PROBLEM 
`7a_pinknoise_N_3`
