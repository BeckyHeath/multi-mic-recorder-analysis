################################################################################################
#
# Script to Convert FLAC files to WAV files for use with HARKBird
# 
# Becky Heath 2021
#
################################################################################################

# Imports
import os
import subprocess
                    #Move To Folder with Audio Files in 

pre_comp_dir = "Test-tones/"
post_comp_dir ="Test-tones/"

for wfile in os.listdir(pre_comp_dir):
    wfile = pre_comp_dir + wfile
    ofile= wfile.replace(pre_comp_dir, post_comp_dir)
    ofile = ofile.replace(".wav", ".flac")
    cmd = ('ffmpeg -i {} {}') 
    subprocess.call(cmd.format(wfile, ofile), shell=True)
    #os.remove(wfile)