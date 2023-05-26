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
data <- read.csv("Data/CompleteLabLocalisation/AllTests_LocalisationData.csv")

# For the analysis at the moment let's just use waterproofed devices
data <- data[data$wpRAW == "y",]


# Create Coarse Labells (no waterproofing)
data <- data %>%
  mutate(trial = case_when(
    trial == "SilwoodField" ~ "Field",
    trial == "IndoorPre" ~ "Lab",
    # Add more conditions if needed
    TRUE ~ trial  # Keep the original value if no condition matches
  ))

data <- data %>%
  mutate(label = paste0(trial, " ", distance.m, "m ", substr(tone, 1, 1)))

# NOTES - This intentionally ignores weatherproofing! If you want to look at the weatherproofing you'll need
#         to edit this code. 


# Calculate median and IQR per group
data$distance.m <- as.factor(data$distance.m)
data$difference <- as.numeric(data$difference)

medianIQRs <- data %>%
  group_by(label) %>%
  summarise(
    Median = median(difference, na.rm= TRUE),
    Q1 = quantile(difference, 0.25, na.rm= TRUE),
    Q3 = quantile(difference, 0.75, na.rm = TRUE),
    IQR = Q3 - Q1,
    .groups = "keep"
  )

# ALL DATA (INSIDE AND OUT)
ggplot(medianIQRs, aes(x = label, y = Median)) +
  geom_boxplot(width = 0.6) +
  geom_rect(aes(xmin = 0.5, xmax = 6.5, ymin = -18, ymax = 18),
            fill = "gray", alpha = 0.03) +
  geom_errorbar(aes(ymin = Q1, ymax = Q3), width = 0.2) +
  labs(title = "True/Predicted Azimuth Error",
       x = "Group", y = "Median Angle Difference") +
  ylim(-50,50)+
  theme_minimal() +
  theme(legend.position = "none")


