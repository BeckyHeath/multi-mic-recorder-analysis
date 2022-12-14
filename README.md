## Exploring MAARU Localisation Accuracy and Persistance in the Field

### General Audio Tools

These scripts are for general audio editing, with adjustments for 6 channel audio. 

#### Scripts written for this repo: 

FLAC_to_wav.py => just changes FLAC files back to wav



#### Scripts used in this work but taken from elsewhere:

getfn.m => from Thorsten.Hansesn@psychol.uni-giessen.de, gets filenames from directories and subdirectories
tight_subplot.m => from Pekka Kumpulainen, allows you to customise subplotes easier 
patchline.m => from MathWorks, data visualisation tool


### Signal Quality 

#### Visualisation
spectraDevComparisonrerejigm.m => Channel Specific Spectra from all 4 Devices, this is the big spectra figure that shows dignal degredation. 
spectaBatch.m => generates spectral figures, channel specifically, from ALL of the field recording files plots them per period, per channel 
degredationBatch.m => I think this was trying to plot power spectrum per channel (not working any more ... delete?) 
test_signal_comparisson.m => comapre two spectra, not sure it's still working (..delete?) 
plot_all.m => Plots spectra from a list of files, looks like it has some issues but still good. 
Sweep_Analysis_single_degredation.m => Compares channel-wise spectra of two recordings
Sweep_Analysis_degredation.m => Compares spectra of multiple recordings, not sure if it works (maybe delete?)
Sweep_Spectrograms.m => just plots spectrograms (two) - delete?


#### Checking and ammending problems
deadSigDetection.m => Determine signal strength of each channel compared to eachother
addGain.m => Takes output files from deadSigDetection.m and adjusts the channel specific gain accordingly
IndexExtraction.R => Extracts acoustics indices - for anomoly detection (delete?) 
AnomolyDetection.m => Trying to look for values indicative of a dead signal (delete?) 
metaDesc.m => Looks like a function for attributing qualiatative values to channel powers(idk if anything else uses it delete?)

##### Mixed Power Recordings (Detection and Fixing): 
use the "deadsigdetection.m" script to generate the raw mean(abs) data + the corresponding text descriptions, 
then used gainAdjust.m to bump the gain?

### Localisation Accuracy 

Angle_Dif_LocalisationPre.R => Analysing Pre Deployment Localisations (just angle differences now!)
Angle_Dif_LocalisationPost.R => Analysing Post Deployment Localisations (just angle differences now!)
Lab_Localisation_Analysis.R => generates the first localisation figures 
localisation_data_extraction.py => pulls out important info from HARKBird outputs 

### Recording Hours

MetadataGrapher.r => Consolidates upload information, files generated manually/ from a file generated by MetadataFromBoxADD_OWN_DETAILS.m. Generates hours of daily upload figure. 
MetadataFromBoxADD_OWN_DETAILS.m => This downloads all your file info from github but requires you putting in password etc
NotForGithub.m => NOT VISIBLE, just ftp info for Matlab
NotForGithub.r => ftp settings but for R 

### Power Consumption Info
Power_stats.r => Stats and Figures on the power consumption data 
