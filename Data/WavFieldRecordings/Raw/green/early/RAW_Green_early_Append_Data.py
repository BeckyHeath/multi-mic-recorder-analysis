#!/usr/bin/env python3

################################################################################################
#
# Script to add aditional info to filenames 
# 
# Becky Heath 2019 (adapted from)
#
################################################################################################


# Imports
import sys
import time
import os
                    #Move To Folder with Audio Files in 

for f in os.listdir():
    f_name, f_ext = os.path.splitext(f)
    CompLevel = str("RAW")
    RecLength = str("Green")
    Location = str("early")
    
    f_new=  '{}_{}_{}_{}{}'.format(CompLevel, RecLength, Location, f_name, f_ext)

    os.rename(f, f_new)