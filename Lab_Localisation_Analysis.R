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

file_directory = "Data/Lab_Localisation/outputs_threshold_experiments/optimum_threshold"


##### Define Functions #####

# Load in true values: 
true <- read.csv("Data/Real_Location.csv")

section_data <- function(df){
  
  # Function to group the real data into distinct time periods?? 
  # The recordings are then in groups to better compare real/predicted
  #
  # recallibrate start position to -180 
  # 30deg mismatch in the transfer function (See HARKTOOL5)
  
  df$Start.azimuth <- df$Start.azimuth - 30
  
  df$Start.time[df$Start.time < 10] <- 0
  df$Start.time[df$Start.time > 12 & df$Start.time < 16] <- 15
  df$Start.time[df$Start.time > 30 & df$Start.time < 35] <- 30
  df$Start.time[df$Start.time > 45 & df$Start.time < 50] <- 45
  df$Start.time[df$Start.time > 60 & df$Start.time < 75] <- 60
  df$Start.time[df$Start.time > 75 & df$Start.time < 80] <- 75
  df$Start.time[df$Start.time > 90 & df$Start.time < 95] <- 90
  df$Start.time[df$Start.time > 105 & df$Start.time < 110] <- 131 # ignore
  df$Start.time[df$Start.time > 120 & df$Start.time < 125] <- 131 # ignore 
  df$Start.time[df$Start.time > 125] <- 131 # ignore
  
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
  
  merge_df_er <- merge_df[complete.cases(merge_df),]
  
  error_data <- find_error(merge_df_er$Real.Azimuth, merge_df_er$Predicted.Azimuth)
  printout <- paste0("\n###############\nFile:", label, "\nMean Error:", error_data[1],"\nSD:", error_data[2], "\nR_sq:", error_data[3])
  cat(printout)
  
  # TODO: Get some stats for this at some point 
  plot <- ggplot(merge_df, aes(Real.Azimuth, Predicted.Azimuth))+
    ggtitle(label) +
    geom_point(color = "Red", size =4, shape = 4, stroke = 1.5)+
    geom_abline(color= "black", size = 0.6, alpha = 0.5) +
    xlim(-180,180)+
    ylim(-180,180)+
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
      
  i_file <- section_data(i_file) # get data to match up 
  
  #disregard sounds not made at the 15s intervals
  i_file <- i_file[i_file$Start.time %% 15 == 0,]
    
  o_plot <- plot_data_targets(i_file)
    
  assign(label, o_plot)
}

# Patchwork Plots 
# TODO: Still needs some formatting fixes
plot <- `1a_pinknoise2_N_2`| `1a_pinknoise2_N_2` | `1b_bird_N_2`
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
  label = substring(label, 4)
  label = str_remove(label,"_localized_")
  label = str_remove(label,".wav")
  
  #label = substring(label, 4, nchar(label)-2) # For removing unnecessary data in the label
  

  i_file <- section_data(i_file)
  
  o_plot <- true_pred_plots(i_file)
  
  assign(label, o_plot)
}

# Patchwork Plots 
# TODO: Still needs some formatting fixes
# TODO: Resolve threshold issues
plot <- `7a_pinknoise_N_3`| `5a_pinknoise_Y_2`
plot2 <- `1b_bird_N_2` | `5b_bird_Y_2`

plot/plot2










