import os 
import csv
import glob

''' 
Script used to extract relevant data from the HARKBird output files.

See if name == "main", this takes the location of a folder containing
HARKBird outputs. Change if necessary

You'll want to put this in the directory up from where your files are. Then edit the dir
in "if name == "main"" and in the "path_to_file = ..." line (sorry!)

Becky Heath 
April 2021, Edited May 2023
'''

def extract_data(sub_dir, all_data):
    '''
    Locates sourcelist.csv, renames to include 
    metadata and xxxx

    ARGS: 
        HARKBird directory
    '''
    filename = str(sub_dir)
    
    # find and make a copy of relevant file 
    path_to_file = "THRESH_28/" + filename + "/sourcelist.csv"

    with open(path_to_file, 'r') as file: 
        reader = csv.reader(file, delimiter = '\t')
        next (reader) # skip header row if there is one
        for row in reader: 
            row.append(filename)
            all_data.append(row)

    # add column with meta data 
    # save file elsewhere in data

def write_combined_csv(data):
    output_file = "HARK_Data/combined_data.csv"

    with open(output_file, "w", newline = '') as file: 
        writer = csv.writer(file)
        writer.writerow(["Sep", "Start.time","Start.azimuth", "End.time", "End.azimuth","filename"])
        writer.writerows(data)

def iterate(directory):
    ''' 
    Iterates through a desired folder and runs the 
    extract_data() function on them
    
    ARGS: 
        directory containing HARKBird output dirs 
    '''

    all_data = [] #Initialise the joined dataframe

    # Index every subfolder in HARKBird folder
    for sub_dir in os.listdir(directory):
        extract_data(sub_dir, all_data)
    

    write_combined_csv(all_data)

if __name__ == "__main__":

    # Iterate through desired files
    # Change to file location if necessary
    iterate("THRESH_28")