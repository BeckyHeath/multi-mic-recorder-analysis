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
library(tidyr)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

###### Load in Data ########

# Load in true values: 
# Ignore this one for now, will need to experiment with detections, may need to relable
#data <- read.csv("Data/CompleteLabLocalisation/AllTests_LocalisationData_ALLDETECTIONSTESTS.csv")

# Just use this:
dataRaw <- read.csv("Data/CompleteLabLocalisation/AllTestsJustTrueValues.csv")

##### PRECISION CHARTS #####
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

# get rid of the situations where a signal was not localised: 
data <- data[!is.na(data$error), ]

# ALL DATA (INSIDE AND OUT)
ggplot(data = data, aes(x = label, y = error)) +
  annotate('rect', ymin = -18, ymax = 18, xmin= -Inf, xmax = Inf, fill = "lightgray", alpha = 0.3)+
  geom_hline(yintercept = 0, color = "darkgray") +
  #geom_jitter(aes(shape = Test.tone), position = position_jitterdodge(0.2)  ,fill = "gray", color = "gray", size = 2, alpha = 0.5) +
  stat_summary(aes(color = Test.tone, shape = Test.tone, fill = Test.tone), fun = "median", geom = "point", size = 3, position = position_dodge(width = 0.3)) +
  stat_summary(aes(color = Test.tone), fun.data = "median_hilow", geom = "errorbar", width = 0.2, position = position_dodge(width = 0.3)) +
  labs(title = "True/Predicted Azimuth Error",
       x = "Group", y = "Angle Error") +
  scale_color_manual(values = c("grey25", "firebrick3")) +
  scale_shape_manual(values = c(21, 24)) +
  scale_fill_manual(values = c("grey25", "firebrick3")) +
  theme_minimal() +
  ylim(-25, 25) +
  theme(legend.position = "none") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))



# Now the frequency-dependent trials
data <- dataRaw[dataRaw$Trial == "freq-dep",]
data$Test.tone <- as.factor(data$Test.tone)

setOrder <- c("100", "400", "500", "1000","2000", "4000", "6000", "7000", "pink", "wren")
data$Test.tone <- factor(data$Test.tone, levels = setOrder)


data$error <- as.numeric(data$error)
data$Aliaized.Azimuth <- as.numeric(data$Aliaized.Azimuth)

# get rid of the situations where a signal was not localised (FOR NOW): 
data <- data[!is.na(data$error), ]

ggplot(data = data, aes(x = Test.tone, y = error)) +
  annotate('rect', ymin = -18, ymax = 18, xmin= -Inf, xmax = Inf, fill = "lightgray", alpha = 0.15)+
  geom_hline(yintercept = 0, color = "darkgray") +
  #geom_jitter(aes(shape = Test.tone), position = position_jitterdodge(0.2)  ,fill = "gray", color = "gray", size = 2, alpha = 0.5) +
  stat_summary(aes(color = Test.tone, fill = Test.tone), fun = "median", geom = "point", size = 3) +
  stat_summary(aes(color = Test.tone), fun.data = "median_hilow", geom = "errorbar", width = 0.2) +
  labs(title = "True/Predicted Azimuth Error",
       x = "Group", y = "Angle Difference") +
  theme_minimal() +
  ylim(-20, 20) +
  theme(legend.position = "none") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))


##### RECALL CHARTS #####

data <- dataRaw

#FreqDeps First: 
data <- dataRaw[dataRaw$Trial == "freq-dep",]

# Define the possible localisation? descriptors
possible_labels <- c("y", "d", "n", "m")

# Calculate the count and proportion of each label within each group
proportions <- data %>%
  group_by(Test.tone, localised.) %>%
  summarise(count = n()) %>%
  ungroup() %>%
  complete(Test.tone, localised. = possible_labels, fill = list(count = 0)) %>%
  group_by(Test.tone) %>%
  mutate(proportion = count / sum(count))

# Fill up missing variables: 
proportions <- proportions %>%
  group_by(Test.tone) %>%
  mutate(Test.tone = ifelse(is.na(Test.tone), max(Test.tone, na.rm = TRUE), Test.tone)) %>%
  ungroup()


setOrder <- c("y", "d", "n", "m")
proportions$localised. <- factor(proportions$localised., levels = setOrder)

# Set the order as before
setOrder <- c("100", "400", "500", "1000","2000", "4000", "6000", "7000", "pink", "wren")
proportions$Test.tone <- factor(proportions$Test.tone, levels = setOrder)


# Plot results! 
ggplot(data = proportions, aes(x=Test.tone, y= proportion, fill = localised.))+
  geom_col(alpha = 0.7, position = position_stack(reverse=TRUE))+
  scale_fill_manual(values = c("darkgreen","lightgreen","grey", "grey25"),
                    name = " ",
                    labels = c("Detected", "Nearly Missed","Not Detected", "Missed"))+
  labs(title = "Signal localisation Detection",
       x = "Frequency (Hz) or Test Tone", y = "Proportion") +
  theme_minimal()


# Now the others 

data <- dataRaw

#FreqDeps First: 
data <- dataRaw[dataRaw$Trial != "freq-dep",]

# Define the possible localisation? descriptors
possible_labels <- c("y", "d", "n", "m")


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




# Calculate the count and proportion of each label within each group
proportions <- data %>%
  group_by(label, localised.) %>%
  summarise(count = n()) %>%
  ungroup() %>%
  complete(label, localised. = possible_labels, fill = list(count = 0)) %>%
  group_by(label) %>%
  mutate(proportion = count / sum(count))

# Fill up missing variables: 
proportions <- proportions %>%
  group_by(label) %>%
  mutate(label = ifelse(is.na(label), max(label, na.rm = TRUE), label)) %>%
  ungroup()


setOrder <- c("y", "d", "n", "m")
proportions$localised. <- factor(proportions$localised., levels = setOrder)

# Set the order as before
setOrder <- c("100", "400", "500", "1000","2000", "4000", "6000", "7000", "pink", "wren")
proportions$Test.tone <- factor(proportions$Test.tone, levels = setOrder)


# Plot results! 
ggplot(data = proportions, aes(x=label, y= proportion, fill = localised.))+
  geom_col(alpha = 0.7, position = position_stack(reverse=TRUE))+
  scale_fill_manual(values = c("darkgreen","lightgreen","grey", "grey25"),
                    name = " ",
                    labels = c("Detected", "Nearly Missed","Not Detected", "Missed"))+
  labs(title = "Signal localisation Detection",
       x = "Test Label", y = "Proportion") +
  theme_minimal()+
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))




