#####################################################################
# Script for Calculating Stats/ Figures on the Power Consumption
# Data. (6 Mic Circular Array vs 1 USB Microphone)
#
# Both set ups were based on a raspberry Pi 4B+ (4GB)
#
# Becky Heath January 2021
# 

# Load Libraries and Set WD ####
library(ggplot2)
library(patchwork)
library(stringr)
library(tools)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Analysis: ####

# Load data and Split Dataset to 6mic and 1mic

dataset.og <- read.csv("power-usage-data.csv")

dataset <- dataset.og
dataset$test <- as.factor(dataset$test)
dataset$head <- as.factor(dataset$head)

for(i in c("non_continuous", "continuous")){
  sample.og <- dataset[dataset$test == i,]
  for(j in c("y", "n")){
    sample <- sample.og[sample.og$head == j,]
    sample$device <- as.factor(sample$device) 
    sample$phase <- factor(sample$phase, levels=c("PO", "REC", "UP","REC+UP","IDLE"))
    if(j =="n"){
      title = str_replace(i,"_"," ")
      title = toTitleCase(title)
      bp <<- ggplot(sample, aes(x=device, y=power, fill=device)) + 
        geom_boxplot(lwd=0.2) +
        scale_fill_brewer(palette="Blues") +
        labs(title= title ,x="Mic Number.", y = "Power (W)") +
        theme_classic() +
        ylim(0,6) +
        theme(legend.position = "none")
    } else {
      bp <<- ggplot(sample, aes(x=phase, y=power, fill=device)) + 
        geom_boxplot(lwd=0.2) +
        scale_fill_brewer(palette="Blues", name = "Mic No.") +
        labs(x="Phase") +
        theme_classic() +
        ylim(0,6) +
        theme(legend.position =c(0.9,0.3)) +
        theme(axis.title.y=element_blank())
    }
    
    if(i == "continuous"){
      bp <<- bp + theme(axis.title.x = element_blank()) +
          theme(legend.position = "none")
    }
    plot_name <- paste("BP_", i,"_",j, sep="")
    assign(plot_name,bp) 
  }
}

top <- BP_continuous_n | BP_continuous_y
bottom <- BP_non_continuous_n | BP_non_continuous_y
top/bottom



##### Stats (TODO) ####

find_values_non_cont <- function(dataset){
  for(i in c("PO", "REC", "UP","REC+UP", "IDLE")){
    df <- dataset[dataset$phase == i,]
    mean <- mean(df[["power"]])
    SE <- sd(df[["power"]])
    out.string = paste(i, " Mean = ",mean, ". Standard Deviation = ",SE, sep="")
    print (out.string) # to show means
    model <- t.test(power ~ device, data = df)
    out <- paste0("########################## ", i)
    print(out)
    print(model)
  }
}

find_values_cont <- function(dataset){
  for(i in c("PO", "REC","REC+UP")){
    df <- dataset[dataset$phase == i,]
    mean <- mean(df[["power"]])
    SE <- sd(df[["power"]])
    out.string = paste(i, " Mean = ",mean, ". Standard Deviation = ",SE, sep="")
    print (out.string) # to show means
    model <- t.test(power ~ device, data = df)
    out <- paste0("########################## ", i)
    print(out)
    print(model)
  }
}

find_values_cont(dataset)
