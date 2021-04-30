import os 

''' 
Script used to extract relevant data from the HARKBird output files.

See if name == "main", this takes the location of a folder containing
HARKBird outputs. Change if necessary

Becky Heath 
April 2021
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
    path_to_file = filename + "/sourcelist.csv"
    output_file = "HARK_Data/" + filename +".csv" 

    os.system("copy {} {}".format(path_to_file, output_file)) #use cp instead if on unix

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
    iterate("HARKBird_Localisation_test_FEB2021/Outputs")