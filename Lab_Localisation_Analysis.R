########################################################################### .
# Localisation Accuracy Scripts
#
# Becky Heath
# r.heath18@imperial.ac.uk
#
# Autumn 2021
#
#

##### Load Packages and set working directory #####
library(stringr)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))


##### Load in sourcelist.csv #####

file_directory = "HARKBird_Localisation_Test_FEB2021/Outputs_1_sound"


# Load in all the files you need: 
for(i in list.dirs(file_directory, recursive = FALSE)){
  path = paste(as.character(i),"sourcelist.csv", sep = "/")
  i_file = read.csv(path, sep = "\t")
  
  # tidy label name: 
  label = str_remove(as.character(i), file_directory)
  label = str_remove(label,"/localized_")
  label = str_remove(label,".wav")
  
  # asign to value: TODO: will need to load and delete these if you end up working on huge numbers of files!!
  assign(label, i_file)
}






