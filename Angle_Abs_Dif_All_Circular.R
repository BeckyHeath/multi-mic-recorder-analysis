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
library(circular)
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))


# Load in values: 
difData <- read.csv("Data/CompleteLabLocalisation/AngleDifferences/allAngles.csv")

difData$tone <- as.factor(difData$tone)
difData$recorder <- as.factor(difData$recorder)
difData$wp <- as.factor(difData$wp)
difData$testTone <- as.factor(difData$testTone)
difData$gainTest <- as.factor(difData$gainTest)
difData$gainAdded <- as.factor(difData$gainAdded)

##### Define Functions ####

find_error <- function(difData){
  # finds the mean and sd of the error and r-sq when 
  # given a difference values
  dif <- difData$difference
  dif <- abs(dif)
  
  # Convert to Circular Data
  circ <- circular(dif, units = "degrees")
  
  mean_val <- mean(circ)[[1]] # just keep the value
  sd_val <- sd(circ)
  
  # Rsquared Removed (See non circular script if needed)
  
  out <- c(mean_val,sd_val)
  
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

##### SETUP OUTPUT DF ####

outFile <- data.frame("angleType" = character(),
                      "test"= character(),
                      "group" = character(),
                      "recs"= character(),
                      "echoRM" = character(),
                      "mean"= numeric(), 
                      "SD" = numeric(), 
                      "maxER" = numeric())





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
   cat(levels(as.factor(testDF$file)))
   printout <- paste0("\n###############\nFile (with echos):", label, "\nMean Dif:", error_data[1],"\nSD:", error_data[2])
   cat(printout)
   
   
   # WRITE TO OUTPUT MARIX
   maxError <- max(testDF$difference)
   echoRM <- "no"
   files <- paste(levels(as.factor(testDF$file)), collapse = "; ")
   outLine <- data.frame("angleType" = "circular",
                         "test" = "pre",
                         "group" = label,
                         "echoRM" = echoRM,
                         "recs" = files,
                         "mean" = error_data[1],
                         "SD" = error_data[2],
                         "maxER" = maxError)
   outFile <- rbind(outFile, outLine)
   
   #plot <- true_pred_plots(testDF,label)
   #assign(label,plot)
   
   #Remove Echos (false positives)
   testDF <- testDF[testDF$tone == "y", ] 
   error_data <- find_error(testDF)
   printout <- paste0("\n###############\nFile (without echos):", label, "\nMean Dif:", error_data[1],"\nSD:", error_data[2])
   cat(printout)
   
   # WRITE TO OUTPUT MARIX
   maxError <- max(testDF$difference)
   echoRM <- "yes"
   files <- paste(levels(as.factor(testDF$file)), collapse = "; ")
   outLine <- data.frame("angleType" = "circular",
                         "test" = "pre",
                         "group" = label,
                         "echoRM" = echoRM,
                         "recs" = files,
                         "mean" = error_data[1],
                         "SD" = error_data[2],
                         "maxER" = maxError)
   outFile <- rbind(outFile, outLine)
   
   
   
  }
  
}

#plot1 <- `WP:bird` | `NoWP:bird`
#plot2 <- `WP:pinknoise` | `NoWP:pinknoise`
#plot <- plot1/plot2
#plot
#
#ggsave("Figures/PreDepLocalisationCIRCULAR.png", width = 5.7, height = 4.30, device='png', dpi=700)


##### Run Analysis on the Post ####

# get right dataset and get rid of Duplicates
post <- difData[difData$time == "post", ]     
post <- distinct(post)

#
for(i in levels(post$gainAdded)){
  if(i=="n"){
    WPstr = "Raw"
  }else{
    WPstr = "Adjusted"
  }
  postWP <- post[post$gainAdded == i, ] 
  
  for(j in levels(post$testTone)){
    toneStr = j
    
    # Create Label
    label = paste(WPstr, ":",toneStr,sep="")
    
    testDF <- postWP[postWP$testTone == j, ] 
    
    # Find Errors!
    error_data <- find_error(testDF)
    printout <- paste0("\n###############\nFile (with echos):", label, "\nMean Dif:", error_data[1],"\nSD:", error_data[2])
    cat(printout)
    
    # WRITE TO OUTPUT MARIX
    maxError <- max(testDF$difference)
    echoRM <- "no"
    files <- paste(levels(as.factor(testDF$file)), collapse = "; ")
    outLine <- data.frame("angleType" = "circular",
                          "test" = "post",
                          "group" = label,
                          "echoRM" = echoRM,
                          "recs" = files,
                          "mean" = error_data[1],
                          "SD" = error_data[2],
                          "maxER" = maxError)
    outFile <- rbind(outFile, outLine)
    
    plot <- true_pred_plots(testDF,label)
    assign(label,plot)
    
    #Remove Echos (false positives)
    testDF <- testDF[testDF$tone == "y", ] 
    error_data <- find_error(testDF)
    printout <- paste0("\n###############\nFile (without echos):", label, "\nMean Dif:", error_data[1],"\nSD:", error_data[2])
    cat(printout)
    
    # WRITE TO OUTPUT MARIX
    maxError <- max(testDF$difference)
    echoRM <- "yes"
    files <- paste(levels(as.factor(testDF$file)), collapse = "; ")
    outLine <- data.frame("angleType" = "circular",
                          "test" = "post",
                          "group" = label,
                          "echoRM" = echoRM,
                          "recs" = files,
                          "mean" = error_data[1],
                          "SD" = error_data[2],
                          "maxER" = maxError)
    outFile <- rbind(outFile, outLine)
    
    
  }
  
}

#plot1 <- `Raw:bird` | `Adjusted:bird`
#plot2 <- `Raw:pinknoise` | `Adjusted:pinknoise`
#plot <- plot1/plot2
#plot


#ggsave("Figures/PostDepAdjustLocalisationCIRCULAR.png", width = 5.7, height = 4.30, device='png', dpi=700)


##### Go Recorder Specific ####

# get right dataset and get rid of Duplicates
post <- difData[difData$time == "post", ]     
post <- distinct(post)

# Go through Everything: 

# Recorder
for(k in levels(post$recorder)){
  recStr = k
  postR <- post[post$recorder == k, ] 
  
  # Gain Shift 
  for(i in levels(postR$gainAdded)){
    if(i=="n"){
      gainStr = "Raw"
    }else{
      gainStr = "Adjusted"
    }
    postG <- postR[postR$gainAdded == i, ] 
    
    # Weatherproofing
    for(l in levels(postR$wp)){
      if(l=="n"){
        WPStr = "NoWP"
      }else{
        WPStr = "WP"
      }
      postWP <- postG[postG$gainAdded == l, ] 
      
      # Test Tone
      for(j in levels(postWP$testTone)){
        toneStr = j
        
        # Create Label
        label = paste(recStr, ":", WPStr, ":" , gainStr, ":",toneStr,sep="")
        
        testDF <- postWP[postWP$testTone == j, ]
        
        # Find Errors!
        error_data <- find_error(testDF)
        printout <- paste0("\n###############\nFile (with echos):", label, "\nMean Dif:", error_data[1],"\nSD:", error_data[2])
        cat(printout)
        
        # WRITE TO OUTPUT MARIX
        maxError <- max(testDF$difference)
        echoRM <- "no"
        files <- paste(levels(as.factor(testDF$file)), collapse = "; ")
        outLine <- data.frame("angleType" = "circular",
                              "test" = "post",
                              "group" = label,
                              "echoRM" = echoRM,
                              "recs" = files,
                              "mean" = error_data[1],
                              "SD" = error_data[2],
                              "maxER" = maxError)
        outFile <- rbind(outFile, outLine)
        
        
        #plot <- true_pred_plots(testDF,label)
        #assign(label,plot)
        
        #Remove Echos (false positives)
        testDF <- testDF[testDF$tone == "y", ] 
        error_data <- find_error(testDF)
        printout <- paste0("\n###############\nFile (without echos):", label, "\nMean Dif:", error_data[1],"\nSD:", error_data[2])
        cat(printout)
        
        # WRITE TO OUTPUT MARIX
        maxError <- max(testDF$difference)
        echoRM <- "yes"
        files <- paste(levels(as.factor(testDF$file)), collapse = "; ")
        outLine <- data.frame("angleType" = "circular",
                              "test" = "post",
                              "group" = label,
                              "echoRM" = echoRM,
                              "recs" = files,
                              "mean" = error_data[1],
                              "SD" = error_data[2],
                              "maxER" = maxError)
        outFile <- rbind(outFile, outLine)
        
        
      }
    }
  }   
}
    
    
outFile <- outFile[complete.cases(outFile),] 

write.csv(outFile, "Data/circularDifferenceMeasures.csv", row.names = FALSE)  
    
    



#plot1 <- `Raw:bird` | `Adjusted:bird`
#plot2 <- `Raw:pinknoise` | `Adjusted:pinknoise`
#plot <- plot1/plot2
#plot


#ggsave("Figures/PostDepAdjustLocalisationCIRCULAR.png", width = 5.7, height = 4.30, device='png', dpi=700)





