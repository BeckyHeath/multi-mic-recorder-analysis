########################################################################### .
# Scripts for Analysing the Localisation Accuracy 
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
data <- read.csv("Data/CompleteLabLocalisation/AllTests_LocalisationData.csv")

# For the analysis at the moment let's just use waterproofed devices
data <- data[data$wpREVERSED == "y",]

data <- data %>%
  mutate(trial = case_when(
    trial == "SilwoodField" ~ "Field",
    trial == "IndoorPre" ~ "Lab",
    # Add more conditions if needed
    TRUE ~ trial  # Keep the original value if no condition matches
  ))

data <- data %>%
  mutate(label = paste0(trial, "_", distance.m, "m_", substr(tone, 1, 1)))

# NOTES - This intentionally ignores weatherproofing! If you want to look at the weatherproofing you'll need
#         to edit this code. 



# Create Coarse Labells (no waterproofing)





# Starting from scratch - go to the retired code if you want to generate the old figures


# Calculate median and IQR per group
data$distance.m <- as.factor(data$distance.m)
data$difference <- as.numeric(data$difference)

medianIQRs <- data %>%
  group_by(distance.m) %>%
  summarise(
    Median = median(difference, na.rm= TRUE),
    Q1 = quantile(difference, 0.25, na.rm= TRUE),
    Q3 = quantile(difference, 0.75, na.rm = TRUE),
    IQR = Q3 - Q1,
    .groups = "keep"
  )

# ALL DATA (INSIDE AND OUT)
ggplot(medianIQRs, aes(x = distance.m, y = Median, fill = distance.m)) +
  geom_boxplot(width = 0.6) +
  geom_errorbar(aes(ymin = Q1, ymax = Q3), width = 0.2) +
  labs(title = "Grouped Boxplot with Median and IQR",
       x = "Group", y = "Value") +
  theme_minimal()


# JUST SILWOOD DATA 
field <- data[data$trial == "SilwoodField",]
field$difference <- as.numeric(field$difference)
field$distance.m <- as.factor(field$distance.m)

# All Sounds
medianIQRSilwood <- field %>%
  group_by(distance.m) %>%
  summarise(
    Median = median(difference, na.rm= TRUE),
    Q1 = quantile(difference, 0.25, na.rm= TRUE),
    Q3 = quantile(difference, 0.75, na.rm = TRUE),
    IQR = Q3 - Q1,
    .groups = "keep"
  )

ggplot(medianIQRSilwood, aes(x = distance.m, y = Median, fill = distance.m)) +
  geom_boxplot(width = 0.6) +
  geom_errorbar(aes(ymin = Q1, ymax = Q3), width = 0.2) +
  labs(title = "Grouped Boxplot with Median and IQR",
       x = "Group", y = "Value") +
  theme_minimal()

# Separated By Sounds
medianIQRSilwoodSep <- field %>%
  mutate(distance.m = factor(distance.m)) %>%
  group_by(distance.m, tone) %>%
  summarise(
    Median = median(difference, na.rm = TRUE),
    Q1 = quantile(difference, 0.25, na.rm = TRUE),
    Q3 = quantile(difference, 0.75, na.rm = TRUE),
    IQR = Q3 - Q1,
    .groups = "keep"
  )


ggplot(medianIQRSilwoodSep, aes(x = distance.m, y = Median, fill = tone, colour = tone)) +
  geom_boxplot(width = 0.5, position = position_dodge(width = 0.7)) +
  geom_errorbar(aes(ymin = Q1, ymax = Q3, colour = tone), width = 0.2, position = position_dodge(width = 0.7)) +
  ylim(-15,15)+
  labs(title = "Grouped Boxplot with Median and IQR", x = "Group", y = expression("Median Angle Difference "~(degree))) +
  theme_minimal()





plot1 <- ggplot(field, aes(x=distance.m, y=difference, fill = distance.m))+
  geom_hline(yintercept=0)+
  geom_violin(width = 0.8)+
  theme_minimal()+
  ylim(-100,100)
  

plot1

###  FROM CHAT GTP: 
library(dplyr)




##########

lab <- data[data$trial == "IndoorPre",]
lab$difference <- as.numeric(lab$difference)
lab$tone <- as.character(lab$tone)

plot1 <- ggplot(lab, aes(x=tone, y=difference, fill = tone))+
  geom_hline(yintercept=0)+
  geom_violin(width = 0.8)+
  theme_minimal()+
  ylim(-180,180)


plot1







# Example dataframe with groups and NA value
