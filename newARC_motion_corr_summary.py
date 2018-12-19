''' 
This script creates a summary csv file for motion parameters for subjects in a given FSFAST project directory. 
The script iteratively calculates the absolute mean, absolute max, relative mean and relative max displacement due to translational motion. The results are saved in a summary csv. 
''' 

import fnmatch, os, sys
from mne.io import Raw
from numpy import abs, diff
from pandas import read_csv

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
### Find all motion files.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

# Specify root directory. This is the project directory that follows FSFAST directory convention. 
root_dir = '/autofs/space/lilli_004/users/DARPA-ECR/'

# Initialize list of subjects. 
matches = []

# Go through each subject folder and populate list of subjects based on subjectname file.
for folder in os.listdir(root_dir):
    if os.path.isfile( os.path.join( root_dir, folder, 'subjectname' ) ): 
        matches.append(os.path.join(root_dir,folder))

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
### Iteratively Calculate stats.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

# Specify name of task folder.
tasks = ['ecr_001']
 
# Open summary csv file with write permission 
with open(os.path.join(root_dir, 'scripts', 'preproc', 'motion.csv'),'w') as f:
    
    # Write column headers in csv 
    f.write(' '.join(['subjid','task','abs_mean','abs_max','rel_mean','rel_max'])+'\n')
    
    # Iterate through each subject
    for match in sorted(matches):
        
	# Iterate through each task folder for each subject
	for task in tasks:
	    
	    # Check if task directory exists for subject
	    if os.path.isdir(os.path.join(match, task)):
	        
	        # Iterate through each run of the task 
	        for run in [d for d in os.listdir(os.path.join(match,task)) if os.path.isdir(d)]:
		    
		    ## Load motion data created during FSFAST preprocessing steps. 
            	    subjid = match.split(os.sep)[-1]
            	    motion_file = os.path.join(match,task,'%03d' %run,'fmcpr.mcdat')
            	    
            	    # Check if motion file exists
            	    if os.path.isfile(motion_file):
                        
			## Load data from motion file.
                        motion = read_csv(motion_file, sep=' *', header=None, engine='python')

                        ## Compute statistics.
                        abs_mean = motion[9].mean()
                        abs_max  = motion[9].max()
                        rel_mean = abs(diff(motion[9])).mean()
                        rel_max = abs(diff(motion[9])).max()
                        
                        # Write above computed statistics to summary csv
                        f.write('%s %s %03d %0.3f %0.3f %0.3f %0.3f\n' %(subjid,task, run, abs_mean,abs_max,rel_mean,rel_max))
                    else:

                        # If motion file doesn't exist, leave the stats columns blank. 
                        f.write('%s %s %03d\n' %(subjid,task, run))
                
