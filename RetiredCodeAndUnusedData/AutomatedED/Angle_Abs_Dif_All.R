########################################################################### .
# Scripts for plotting and analysing angle differences.
# Takes HARKBird outputs from a standardised experiment, 
# the file used here was generated through "Angle_Dif_LocalisationPre.r"
# and "Angle_Dif_LocalisationPost.r"
#
# Becky Heath
# r.heath18@imperial.ac.uk
#
# Summer 2022

##### Load Packages and set working directory #####

library(ggplot2)
library(tidyr)
library(dplyr)
library(wesanderson)
library(patchwork)
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))


# Load in values: 
difData <- read.csv("Data/CompleteLabLocalisation/AngleDifferences/allAngles.csv")

difData$tone <- as.factor(difData$tone)
difData$recorder <- as.factor(difData$recorder)
difData$wp <- as.factor(difData$wp)
difData$testTone <- as.factor(difData$testTone)
difData$gainTest <- as.factor(difData$gainTest)

##### Define Functions ####

find_error <- function(difData){
  # finds the mean and sd of the error and r-sq when 
  # given a difference values
  dif <- difData$difference
  dif <- abs(dif)
  mean_val <- mean(dif)
  sd_val <- sd(dif)
  r_sq <- 1-sum((dif)^2)/sum((dif - mean(dif))^2)
  out <- c(mean_val,sd_val,r_sq)
  return(out)
}

true_pred_plots <- function(df, label){
  
  # Creates plots showing true vs. predicted values
  plot <- ggplot(df, aes(trueAzimuth, difference, col = recorder, shape = tone))+
    ggtitle(label) +
    geom_jitter(size =3, alpha = 0.7, position = position_jitter(width=5,height=0))+
    scale_color_manual(values = c("2" =  wes_palette("Darjeeling1",5)[1],
                                  "3"= "black",
                                  "Blue"= wes_palette("Darjeeling1",5)[5],
                                  "Yellow" = wes_palette("Darjeeling1",5)[3],
                                  "yellowGreen" = wes_palette("Darjeeling1",5)[2])) +
    scale_shape_manual(values = c("y" = 16,
                                  "echo"= 10)) +
    geom_hline(yintercept=0)+
    xlim(-185,185)+ # to allow for jitter
    ylim(-20,20)+ # to allow for jitter
    #xlab("Predicted") + 
    #ylab("True") +
    annotate("text", x = -110, y = 150, label ="") +
    theme_minimal()+ 
    theme(legend.position = "none") + 
    theme(axis.text.x=element_blank())+
    #theme(axis.text.y=element_blank())+
    theme(axis.title.x=element_blank())+
    theme(axis.title.y=element_blank()) +
    theme(plot.title = element_text(size = 10))
  
  

  return(plot)
}

##### Run Analysis on the Pre ####

# get right dataset and get rid of Duplicates
pre <- difData[difData$time == "pre", ]     
pre <- pre[, !(names(pre) %in% c("gainTest", "gainAdded"))]
pre <- distinct(pre)

for(i in levels(pre$wp)){
  if(i=="n"){
    WPstr = "NoWP"
  }else{
    WPstr = "WP"
  }
  preWP <- pre[pre$wp == i, ] 
  
  for(j in levels(preWP$testTone)){
   toneStr = j
   
   # Create Label
   label = paste(WPstr, ":",toneStr,sep="")
   
   testDF <- preWP[preWP$testTone == j, ] 
  
   # Find Errors!
   error_data <- find_error(testDF)
   printout <- paste0("\n###############\nFile (with echos):", label, "\nMean Dif:", error_data[1],"\nSD:", error_data[2], "\nR_sq:", error_data[3])
   cat(printout)
   
   plot <- true_pred_plots(testDF,label)
   assign(label,plot)
   
   #Remove Echos (false positives)
   testDF <- testDF[testDF$tone == "y", ] 
   error_data <- find_error(testDF)
   printout <- paste0("\n###############\nFile (without echos):", label, "\nMean Dif:", error_data[1],"\nSD:", error_data[2], "\nR_sq:", error_data[3])
   cat(printout)
  }
  
}

plot1 <- `WP:bird` | `NoWP:bird`
plot2 <- `WP:pinknoise` | `NoWP:pinknoise`
plot <- plot1/plot2
plot

ggsave("Figures/PreDepLocalisation.png", width = 5.7, height = 4.30, device='png', dpi=700)


##### Run Analysis on the Post ####

# get right dataset and get rid of Duplicates
post <- difData[difData$time == "post", ]     
post <- distinct(post)

for(i in levels(post$gainTest)){
  if(i=="n"){
    WPstr = "Raw"
  }else{
    WPstr = "Adjusted"
  }
  postWP <- post[post$gainTest == i, ] 
  
  for(j in levels(post$testTone)){
    toneStr = j
    
    # Create Label
    label = paste(WPstr, ":",toneStr,sep="")
    
    testDF <- postWP[postWP$testTone == j, ] 
    
    # Find Errors!
    error_data <- find_error(testDF)
    printout <- paste0("\n###############\nFile (with echos):", label, "\nMean Dif:", error_data[1],"\nSD:", error_data[2], "\nR_sq:", error_data[3])
    cat(printout)
    
    plot <- true_pred_plots(testDF,label)
    assign(label,plot)
    
    #Remove Echos (false positives)
    testDF <- testDF[testDF$tone == "y", ] 
    error_data <- find_error(testDF)
    printout <- paste0("\n###############\nFile (without echos):", label, "\nMean Dif:", error_data[1],"\nSD:", error_data[2], "\nR_sq:", error_data[3])
    cat(printout)
  }
  
}

plot1 <- `Raw:bird` | `Adjusted:bird`
plot2 <- `Raw:pinknoise` | `Adjusted:pinknoise`
plot <- plot1/plot2
plot


ggsave("Figures/PostDepAdjustLocalisation.png", width = 5.7, height = 4.30, device='png', dpi=700)
