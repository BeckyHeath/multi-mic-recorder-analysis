########################################################################### .
# Scripts for Analysing the Localisation Accuracy 
#
# Starting from scratch - go to the retired code if you want to generate the old figures
#
# Becky Heath
# rh862@cam.ac.uk
#
# May 2023

##### Load Packages and set working directory #####

library(ggplot2)
library(dplyr)



setwd(dirname(rstudioapi::getActiveDocumentContext()$path))


###### Load in Data ########

# Load in true values: 
# Ignore this one for now, will need to experiment with detections, may need to relable
#data <- read.csv("Data/CompleteLabLocalisation/AllTests_LocalisationData_ALLDETECTIONSTESTS.csv")

# Just use this:
dataRaw <- read.csv("Data/CompleteLabLocalisation/AllTestsJustTrueValues.csv")

# get rid of freq-deps for now:
data <- dataRaw[dataRaw$Trial != "freq-dep",]

# Create Coarse Labels
data <- data %>%
  mutate(Trial = case_when(
     Trial == "field" ~ "Field",
#    trial == "IndoorPre" ~ "Lab",
     Trial == "lab-pre" ~ "Lab",
    TRUE ~ Trial  # Keep the original value if no condition matches
  ))

# Collate label
data <- data %>%
  mutate(label = paste0(Trial, " ", distance.m, "m ", " WP-", WP.))

# Calculate median and IQR per group
data$distance.m <- as.factor(data$distance.m)
data$error <- as.numeric(data$error)

# ALL DATA (INSIDE AND OUT)
ggplot(data = na.omit(data), aes(x = label, y = error)) +
  annotate('rect', ymin = -18, ymax = 18, xmin= -Inf, xmax = Inf, fill = "lightgray", alpha = 0.3)+
  geom_hline(yintercept = 0, color = "darkgray") +
  #geom_jitter(aes(shape = Test.tone), position = position_jitterdodge(0.2)  ,fill = "gray", color = "gray", size = 2, alpha = 0.5) +
  stat_summary(aes(color = Test.tone, shape = Test.tone, fill = Test.tone), fun = "median", geom = "point", size = 3, position = position_dodge(width = 0.3)) +
  stat_summary(aes(color = Test.tone), fun.data = "median_hilow", geom = "errorbar", width = 0.2, position = position_dodge(width = 0.3)) +
  labs(title = "True/Predicted Azimuth Error",
       x = "Group", y = "Angle Difference") +
  scale_color_manual(values = c("red", "blue")) +
  scale_shape_manual(values = c(21, 24)) +
  scale_fill_manual(values = c("red", "blue")) +
  theme_minimal() +
  ylim(-20, 20) +
  theme(legend.position = "none") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))




