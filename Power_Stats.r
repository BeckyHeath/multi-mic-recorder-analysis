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

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Analysis: ####

# Load data and Split Dataset to 6mic and 1mic

dataset.og <- read.csv("power-usage-data.csv")

dataset <- dataset.og

for(i in c("non_continuous", "continuous")){
  sample <- dataset[dataset$test == i,]
  for(j in c("y", "n")){
    sample <- sample[sample$head == j,]
    dataset$device <- as.factor(dataset$device) 
    dataset$phase <- factor(dataset$phase, levels=c("PO", "REC", "UP","REC+UP","IDLE"))
    if(j =="n"){
      bp <- ggplot(sample, aes(x=device, y=power, fill=device)) + 
        geom_boxplot() +
        scale_fill_brewer(palette="Blues") +
        theme_classic()
    } else {
    bp <- ggplot(sample, aes(x=phase, y=power, fill=device)) + 
      geom_boxplot() +
      scale_fill_brewer(palette="Blues") +
      labs(title="Continuous",x="Phase", y = "Power (W)") +
      theme_classic()
    }
    
    plot_name <- paste("BP_", i,"_",j, sep="")
    assign(plot_name,bp)
    
  } 
  }

top <- BP_continuous_n | BP_continuous_y
bottom <- BP_non_continuous_n | BP_non_continuous_y

top/bottom
  
  }
  if(index %in% c("M","NDSI")){
    plot8 <-ggplot(sample, aes(x=compression, y=median)) + 
      geom_errorbar(aes(ymin=lower, ymax=higher), width=.4, size =0.1) +
      labs(y = "Bias as % of Range") +
      ggtitle(index) + 
      theme_minimal() +
      theme(plot.title = element_text(hjust=0.01, vjust =-5)) +
      theme(axis.title.x=element_blank()) +
      theme(axis.text.x = element_text(size = 8, angle = 90)) +
      theme(axis.title.y=element_blank())+
      theme(legend.position = "none") +
      theme(axis.line = element_line()) +
      theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) +
      #ylim(-100,100)+
      geom_point(size=0.9)+
      annotate("rect", xmin = 0, xmax = 10, ymin = -5, ymax = 5, 
               alpha = .15,fill='green') +
      geom_hline(yintercept = 0, color = "DarkGrey") 
    plot_name <- paste("BA_plt_", index, sep="")
    assign(plot_name,plot8)
    
  } else if(index == "Bio"){
    plot8 <-ggplot(sample, aes(x=compression, y=median)) + 
      geom_errorbar(aes(ymin=lower, ymax=higher), width=.4, size =0.1) +
      labs(y = "Bias as % of Range") +
      ggtitle(index) + 
      theme_minimal() +
      theme(plot.title = element_text(hjust=0.01, vjust =-10)) +
      theme(axis.title.x=element_blank()) +
      theme(axis.text.x = element_text(size = 8, angle = 90)) +
      theme(axis.title.y=element_blank())+
      theme(legend.position = "none") +
      theme(axis.line = element_line()) +
      theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) +
      #ylim(-100,100)+
      geom_point(size=0.9)+
      annotate("rect", xmin = 0, xmax = 10, ymin = -5, ymax = 5, 
               alpha = .15,fill='green') +
      geom_hline(yintercept = 0, color = "DarkGrey") 
    plot_name <- paste("BA_plt_", index, sep="")
    assign(plot_name,plot8)
  } else {
    plot <-ggplot(sample, aes(x=compression, y=median)) + 
      geom_errorbar(aes(ymin=lower, ymax=higher), width=.4, size =0.1) +
      ggtitle(index) + 
      theme_minimal() +
      theme(plot.title = element_text(hjust=0.01, vjust =-5)) +
      theme(panel.grid.major.x = element_blank()) +
      theme(axis.title.x=element_blank()) +
      theme(axis.text.x = element_blank()) +
      theme(axis.title.y=element_blank())+
      theme(legend.position = "none") +
      theme(axis.line = element_line()) +
      theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) +
      geom_point(size=0.9)+
      annotate("rect", xmin = 0, xmax = 9.5, ymin = -5, ymax = 5, 
               alpha = .15,fill='green') +
      geom_hline(yintercept = 0, color = "DarkGrey") 
    plot_name <- paste("BA_plt_", index, sep="")
    assign(plot_name,plot)
  }
}




bp <- ggplot(dataset, aes(x=phase, y=power, fill=device)) + 
  geom_boxplot() +
  scale_fill_brewer(palette="Blues") +
  labs(title="Continuous",x="Phase", y = "Power (W)")
bp + theme_classic()

plt1 <- bp
pl2 <- bp

plt1|pl2



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
