# intracranial_data_analysis

This repository contains scripts to run time-frequency analysis on intracranial recordings (LFP and iEEG) during wakefulness and sleep. It is based on the code I used to analyze and plot the data in https://www.nature.com/articles/s41593-022-01107-4

You first need to fill the function getExperimentHeader with information about your data (e.g folder where the raw data is saved, where you want to save the pre-process data and the results, patient ID, stimuli ID...)

To run the different scripts, you need to have:
- each channel saved in one matlab file called denoised_[channel_number] (for example 'denoised_9' for channel 9) in the folder you defined in the header.denoisedChannelsPath.
- the start and stop time of each stimulus, with a number associated with each type of stimulus (for ex, the first raw of the matrix would be: [1400, 1900, 3] where start_stim=1400sec, stop_stim=1900sec and stimulus number of 3.
- the sleep scoring (at 1Hz)
- two files containing noisy data points for micro and macro channels separately.  Each file contains number_of_channels cells, where each cell is a vector of data length (where 0 means "clean data" and 1 means "noise"). I'll add the code to find noisy data points very soon; in the meantime, you can just create a file with only zeros (no noise)
  
Script:
1) runHilbertTransform: it runs the Hilbert Transform and takes the envelope of every channel of everytype (MICRO and MACRO) for the frequency bands defined and cut the data around each specific stimulus's trials, for wakefulness and sleep separately.
2) AnalyzeHilbertTransform: Check for significant responses during stimulus presentation for wakefulness and sleep. Plot the mean signal across trials for each stimulus (and significant time points, if there are any). If there is a significant increase or decrease of the signal during the stim presentation in one of the two states, the code compares the signal between them and saves the p value

Coming soon: 
- code to pre-process the raw data (from Blackrock and Neuralynx system recordings): downsample, denoise, extracting stimulus time, check synchronization...
- code to analyze spiking activity (after spike sorting)
- code to calculate inter-trial phase coherence (for 40Hz stimulus in our case)
- code to plot the data on a brain map (using iELVIS)
