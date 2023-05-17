import os 

''' 
Script used to extract relevant data from the HARKBird output files.

See if name == "main", this takes the location of a folder containing
HARKBird outputs. Change if necessary

You'll want to put this in the directory up from where your files are. Then edit the dir
in "if name == "main"" and in the "path_to_file = ..." line (sorry!)

Becky Heath 
April 2021, Edited May 2023
'''

def extract_data(sub_dir):
    '''
    Locates sourcelist.csv, renames to include 
    metadata and xxxx

    ARGS: 
        HARKBird directory
    '''
    filename = str(sub_dir)
    
    # find and make a copy of relevant file 
    path_to_file = "THRESH_28/" + filename + "/sourcelist.csv"
    output_file = "HARK_Data/" + filename +".csv" 

    os.system("cp {} {}".format(path_to_file, output_file)) #use cp instead if on unix

    # add column with meta data 
    # save file elsewhere in data


def iterate(directory):
    ''' 
    Iterates through a desired folder and runs the 
    extract_data() function on them
    
    ARGS: 
        directory containing HARKBird output dirs 
    '''
    # Index every subfolder in HARKBird folder
    for sub_dir in os.listdir(directory):
        extract_data(sub_dir)
    
    # TODO Congregate data

if __name__ == "__main__":

    # Iterate through desired files
    # Change to file location if necessary
    iterate("THRESH_28")