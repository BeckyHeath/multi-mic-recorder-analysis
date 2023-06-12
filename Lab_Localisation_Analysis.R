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
data <- read.csv("Data/CompleteLabLocalisation/AllTestsJustTrueValues.csv")

# For the analysis at the moment let's just use waterproofed
data <- data[data$WP. == "y",]


# Create Coarse Labels (no waterproofing)
data <- data %>%
  mutate(Trial = case_when(
     Trial == "field" ~ "Field",
#    trial == "IndoorPre" ~ "Lab",
     Trial == "lab-pre" ~ "Lab",
    TRUE ~ Trial  # Keep the original value if no condition matches
  ))

# Collate label
data <- data %>%
  mutate(label = paste0(Trial, " ", distance.m, "m ", substr(Test.tone, 1, 1), " WP-", WP.))

# NOTES - This intentionally ignores weatherproofing! If you want to look at the weatherproofing you'll need
#         to edit this code. 

# Calculate median and IQR per group
data$distance.m <- as.factor(data$distance.m)
data$error <- as.numeric(data$error)

# ALL DATA (INSIDE AND OUT)
ggplot(data= na.omit(data), aes(x = label, y = error)) +
  geom_jitter(position = position_jitter(width = 0.2), shape = 16, colour = "gray",alpha=0.5) +
  stat_summary(fun = "median", geom = "point", shape = 18, size = 3, color = "red") +
  stat_summary(fun.data = "median_hilow", geom = "errorbar", width = 0.2, color = "red") +
  labs(title = "True/Predicted Azimuth Error",
       x = "Group", y = "Angle Difference") +
  theme_minimal() +
  ylim(-20, 20)+
  theme(legend.position = "none")+
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))


