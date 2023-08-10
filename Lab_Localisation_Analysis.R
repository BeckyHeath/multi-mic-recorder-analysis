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
library(RColorBrewer)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))


##### Set Functions #####
compute_min_max <- function(y) {
  return(c(ymin = min(y), ymax = max(y), y = median(y)))
}




###### Load in Data ########

# Load in true values: 
# Ignore this one for now, will need to experiment with detections, may need to relable
#data <- read.csv("Data/CompleteLabLocalisation/AllTests_LocalisationData_ALLDETECTIONSTESTS.csv")

# Just use this:
dataRaw <- read.csv("Data/CompleteLabLocalisation/AllTestsJustTrueValues-newCategorisation.csv")

# New Categorisations:
# s = sweep 
# y = detection 
# m = missed (s-m = missed sweep)
# a = aliased 
# d = double (indistinguishable top)
# e = extra (first test had an extra test)




### Distance Tests ####


# get rid of freq-deps and Lab data for now:
data <- dataRaw[dataRaw$Trial != "freq-dep",]
data <- data[data$Trial != "Lab", ]

# Map to example azimuths

map_values <- c(-180, -90, -45, 0, 90)
names(map_values) <- c(30, 120, 165, -150, -60)

dataO <- data
data$True.azimuth <- map_values[as.character(data$True.azimuth)]

data$True.azimuth <- ifelse(is.na(map_values[as.character(df$my_column)]), df$my_column, map_values[as.character(df$my_column)])


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
  mutate(label = paste0(distance.m, "m ", " WP-", WP.))

data$error <- as.numeric(data$error)

dataStore <- data

# get rid of the situations where a signal was not localised: 
data <- data[!is.na(data$error), ]


# Precision Plots

# subset to just y and y-d
data <- data[data$localised. %in% c("y", "y-d"), ]

ED<- ggplot(data = data, aes(x = label, y = error)) +
  #annotate('rect', ymin = -18, ymax = 18, xmin= -Inf, xmax = Inf, fill = "lightgray", alpha = 0.3)+
  geom_hline(yintercept = 0, color = "darkgray") +
  #geom_jitter(aes(shape = Test.tone), position = position_jitterdodge(0.2)  ,fill = "gray", color = "gray", size = 2, alpha = 0.5) +
  stat_summary(aes(color = Test.tone, shape = Test.tone, fill = Test.tone), fun = "median", geom = "point", size = 3, position = position_dodge(width = 0.5)) +
  stat_summary(aes(color = Test.tone), fun.data = compute_min_max, geom = "errorbar", width = 0.3, position = position_dodge(width = 0.5)) +
  labs(x = "Group", y = "Angle Error") +
  scale_color_manual(values = c("grey25", "firebrick3")) +
  scale_shape_manual(values = c(21, 24)) +
  scale_fill_manual(values = c("grey25", "firebrick3")) +
  theme_minimal() +
  ylim(-15, 15) +
  theme(legend.position = "none") +
  theme(axis.title.x = element_blank(), axis.title.y = element_blank())

ED

ggsave(filename = "Figures/NewLocalisationTests/DistanceTests-NL-Summary.png", plot = last_plot(), width = 6, height = 4, dpi = 300)


## Recall Plots 

data <- dataStore


# Set Groupings 
data$localised.[data$localised. == "y-d"] <- "y"
data$localised.[data$localised. == "d"] <- "a"
data$localised.[data$localised. == "e"] <- "y"

# Get rid of the sweeps for now
data <- data[data$localised. != "s", ]
data <- data[data$localised. != "s-m", ]

# Define the possible localisation? descriptors
possible_labels <- c("y", "a", "m")


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


setOrder <- c("y", "a", "m")
proportions$localised. <- factor(proportions$localised., levels = setOrder)



# Set the order as before
setOrder <- c("1m  WP-n","1m  WP-y","2m  WP-n","4m  WP-n","8m  WP-n","8m  WP-y")
proportions$label <- factor(proportions$label, levels = setOrder)


# Plot results! 
RD <- ggplot(data = proportions, aes(x=label, y= proportion, fill = localised.))+
  geom_col(alpha = 0.7, position = position_stack(reverse=TRUE))+
  scale_fill_manual(values = c("darkgreen","grey", "grey25"),
                    name = " ",
                    labels = c("Detected", "Non Primary", "Missed"))+
  labs(x= "", y = "Proportion") +
  theme_minimal()+
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))
RD

ggsave(filename = "Figures/NewLocalisationTests/DistanceRecall-NL-Summary.png", plot = last_plot(), width = 6, height = 4, dpi = 300)


# Heatmaps

# Full Grid: 
all_groups <- c(-180, -90, -45, 0, 90)
all_bins <- 1:18

complete_grid <- expand.grid(True.Azimuth = all_groups, Aliaised.Bins = all_bins)


data <- data[data$localised. == "a", ]

# Put into Bins
data$Aliaized.Bins <- cut(data$Aliaized.Error, breaks = seq(0, 180, 10), include.lowest = TRUE, labels = FALSE)

# Create a table of counts for heatmap
heatmap_data <- as.data.frame(table(data$True.azimuth, data$Aliaized.Bins))

colnames(heatmap_data) <- c("True.Azimuth", "Aliaised.Bins", "Count")

# Join the dataframes
heatmap_data$True.Azimuth <- as.numeric(as.character(heatmap_data$True.Azimuth))
heatmap_data$Aliaised.Bins <- as.numeric(as.character(heatmap_data$Aliaised.Bins))

heatmap_data <- complete_grid %>%
  left_join(heatmap_data, by = c("True.Azimuth", "Aliaised.Bins")) %>%
  replace_na(list(Count = 0))

heatmap_data$True.Azimuth <- as.factor(heatmap_data$True.Azimuth)

# Plot the heatmap
AD <- ggplot(heatmap_data, aes(x = True.Azimuth, y = Aliaised.Bins, fill = Count)) +
  geom_tile() +
  scale_fill_gradient(low = "white", high = "turquoise4") + 
  labs(y = "Aliaized Azimuth", x = "True Azimuth", fill = "Count") +
  theme_minimal() +
  theme(axis.title.x = element_blank(), axis.title.y = element_blank())

AD








# Now the frequency-dependent trials
data <- dataRaw[dataRaw$Trial == "freq-dep",]
data$Test.tone <- as.factor(data$Test.tone)

setOrder <- c("100", "400", "500", "1000","2000", "4000", "6000", "7000", "pink", "wren")
data$Test.tone <- factor(data$Test.tone, levels = setOrder)


data$error <- as.numeric(data$error)
data$Aliaized.Azimuth <- as.numeric(data$Aliaized.Azimuth)

# get rid of the situations where a signal was not localised (FOR NOW): 
data <- data[!is.na(data$error), ]

data <- data[!(data$Test.tone %in% c("wren", "pink")), ]
data$Test.tone <- droplevels(data$Test.tone)

# subset to just y and y-d
data <- data[data$localised. %in% c("y", "y-d"), ]

# Set up colour map
colour <- brewer.pal(9, "OrRd")
colour_map <- setNames(colour[c(2,3,4,5,6,7,8,9)], levels(data$Test.tone))

EF <- ggplot(data = data, aes(x = Test.tone, y = error)) +
  #annotate('rect', ymin = -18, ymax = 18, xmin= -Inf, xmax = Inf, fill = "lightgray", alpha = 0.15)+
  geom_hline(yintercept = 0, color = "darkgray") +
  #geom_jitter(aes(shape = Test.tone), position = position_jitterdodge(0.2)  ,fill = "gray", color = "gray", size = 2, alpha = 0.5) +
  scale_color_manual(values=colour_map)+
  stat_summary(aes(color = Test.tone, fill = Test.tone), fun = "median", geom = "point", size = 3) +
  stat_summary(aes(color = Test.tone), fun.data = "median_hilow", geom = "errorbar", width = 0.2) +
  labs(x = "Group", y = "Angle Difference") +
  theme_minimal() +
  ylim(-15, 15) +
  theme(legend.position = "none") +
  scale_x_discrete(labels=c("100" = "100Hz", "400" = "400 Hz", "500" = "500Hz", "1000" = "1000Hz", "2000" = "2000Hz", "4000"= "4000Hz", "6000" = "6000Hz"))+
  theme(axis.title.x = element_blank(), axis.title.y = element_blank())

EF


ggsave(filename = "Figures/NewLocalisationTests/FrequencyTests-NL-Summary.png", plot = last_plot(), width = 6, height = 4, dpi = 300)



# Tone type

data <- dataRaw[dataRaw$Test.tone %in% c("wren", "pink"),]

data$error <- as.numeric(data$error)

ET <- ggplot(data = data, aes(x = Test.tone, y = error)) +
  #annotate('rect', ymin = -18, ymax = 18, xmin= -Inf, xmax = Inf, fill = "lightgray", alpha = 0.3)+
  geom_hline(yintercept = 0, color = "darkgray") +
  #geom_jitter(aes(shape = Test.tone), position = position_jitterdodge(0.2)  ,fill = "gray", color = "gray", size = 2, alpha = 0.5) +
  stat_summary(aes(color = Test.tone, shape = Test.tone, fill = Test.tone), fun = "median", geom = "point", size = 3, position = position_dodge(width = 0.5)) +
  stat_summary(aes(color = Test.tone), fun.data = compute_min_max, geom = "errorbar", width = 0.3, position = position_dodge(width = 0.5)) +
  labs(x = "Group", y = "Angle Error") +
  scale_color_manual(values = c("grey25", "firebrick3")) +
  scale_shape_manual(values = c(21, 24)) +
  scale_fill_manual(values = c("grey25", "firebrick3")) +
  theme_minimal() +
  ylim(-15, 15) +
  theme(legend.position = "none") +
  scale_x_discrete(labels=c("pink" = "Pink noise", "wren" = "Eurasian Wren"))+
  theme(axis.title.x = element_blank(), axis.title.y = element_blank())

ET 


# Test for difference? 
y <- data[data$Test.tone == "wren", ]$error
n <- data[data$T == "pink", ]$error

result <- wilcox.test(y, n)
print(result)


# Weatherproofing 
data <- dataRaw

data$error <- as.numeric(data$error)
data$WP. <- as.factor(data$WP.)

levels(data$WP.)

EWP <- ggplot(data = data, aes(x = WP., y = error)) +
  #annotate('rect', ymin = -18, ymax = 18, xmin= -Inf, xmax = Inf, fill = "lightgray", alpha = 0.3)+
  geom_hline(yintercept = 0, color = "darkgray") +
  #geom_jitter(aes(shape = Test.tone), position = position_jitterdodge(0.2)  ,fill = "gray", color = "gray", size = 2, alpha = 0.5) +
  stat_summary(aes(color = WP., shape = WP., fill = WP.), fun = "median", geom = "point", size = 3, position = position_dodge(width = 0.5)) +
  stat_summary(aes(color = WP.), fun.data = compute_min_max, geom = "errorbar", width = 0.3, position = position_dodge(width = 0.5)) +
  labs(x = "Group", y = "Angle Error") +
  scale_color_manual(values = c("#09BA4F", "#0963BA")) +
  scale_shape_manual(values = c(22, 23)) +
  scale_fill_manual(values = c("#09BA4F", "#0963BA")) +
  theme_minimal() +
  ylim(-15, 15) +
  theme(legend.position = "none", ) +
  theme(axis.title.x = element_blank())+
  scale_x_discrete(labels=c("n" = "No WP", "y" = "WP"))+
  theme(axis.title.x = element_blank(), axis.title.y = element_blank())

EWP



# Test for difference? 
y <- data[data$WP. == "y", ]$error
n <- data[data$WP. == "n", ]$error

result <- wilcox.test(y, n)
print(result)



##### RECALL CHARTS #####

data <- dataRaw

#FreqDeps First: 
data <- dataRaw[dataRaw$Trial == "freq-dep",]

data <- data[!(data$Test.tone %in% c("wren", "pink")), ]

# group labels for this part 

# s = sweep 
# y = detection 
# m = missed (s-m = missed sweep)
# a = aliased 
# d = double (indistinguishable top)
# e = extra (first test had an extra test)

data$localised.[data$localised. == "y-d"] <- "y"
data$localised.[data$localised. == "d"] <- "a"

# Get rid of the sweeps for now
data <- data[data$localised. != "s", ]


# Define the possible localisation? descriptors
possible_labels <- c("y", "a", "m")

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


setOrder <- c("y", "a", "m")
proportions$localised. <- factor(proportions$localised., levels = setOrder)

# Set the order as before
setOrder <- c("100", "400", "500", "1000","2000", "4000", "6000", "7000", "pink", "wren")
proportions$Test.tone <- factor(proportions$Test.tone, levels = setOrder)


# Plot results! 
RF <- ggplot(data = proportions, aes(x=Test.tone, y= proportion, fill = localised.))+
  geom_col(alpha = 0.7, position = position_stack(reverse=TRUE))+
  scale_fill_manual(values = c("darkgreen","grey", "grey25"),
                    name = " ",
                    labels = c("Detected","Non Primary", "Missed"))+
  labs(x = "Frequency (Hz) or Test Tone", y = "Proportion") +
  theme_minimal()+
  theme(axis.title.x = element_blank(), axis.title.y = element_blank())+
  theme(legend.position = "none", ) +
  scale_x_discrete(labels=c("100" = "100Hz", "400" = "400 Hz", "500" = "500Hz", "1000" = "1000Hz", "2000" = "2000Hz", "4000"= "4000Hz", "6000" = "6000Hz", "7000" = "7000Hz"))

RF


ggsave(filename = "Figures/NewLocalisationTests/FrequencyRecall-NL-Summary(noLegend).png", plot = last_plot(), width = 6, height = 4, dpi = 300)



# Now the others 



## Trial: Heatmaps

data <- dataRaw

data <- data[!is.na(data$Aliaized.Error),]

data$Aliaized.Error <- as.numeric(data$Aliaized.Error)

# Put into Bins
data$Aliaized.Bins <- cut(data$Aliaized.Error, breaks = seq(0, 180, 10), include.lowest = TRUE, labels = FALSE)

# Create a table of counts for heatmap
heatmap_data <- as.data.frame(table(data$True.azimuth, data$Aliaized.Bins))

colnames(heatmap_data) <- c("True.Azimuth", "Aliaised.Bins", "Count")

# Plot the heatmap
ggplot(heatmap_data, aes(x = True.Azimuth, y = Aliaised.Bins, fill = Count)) +
  geom_tile() +
  scale_fill_gradient(low = "white", high = "turquoise4") + 
  labs(y = "Aliaized Azimuth", x = "True Azimuth", fill = "Count") +
  theme_minimal()


