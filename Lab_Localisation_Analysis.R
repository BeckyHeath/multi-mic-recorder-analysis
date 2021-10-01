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

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))


##### Define Test File Location #####

file_directory = "HARKBird_Localisation_Test_FEB2021/Outputs_1_sound"


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
    xlab("Time")+
    theme_minimal() +
    theme(legend.position = "none")
  return(plot)
  
}

##### Generate Target Figures ####

# Load in all the files you need: 
for(i in list.dirs(file_directory, recursive = FALSE)){
  path = paste(as.character(i),"sourcelist.csv", sep = "/")
  i_file = read.csv(path, sep = "\t")
    
    # tidy label name: 
  label = str_remove(as.character(i), file_directory)
  label = str_remove(label,"/localized_")
  label = str_remove(label,".wav")
      
  #i_file <- section_data(i_file)
    
  o_plot <- plot_data_targets(i_file)
    
  assign(label, o_plot)
}

plot <- `1a_pinknoise_N_2`| `1a_pinknoise2_N_2` | `1b_bird_N_2`
plot



