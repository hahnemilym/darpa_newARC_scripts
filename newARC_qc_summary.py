''' 
This script creates a summary csv file for qc parameters for subjects in a given FSFAST project directory. 
The script iteratively calculates the functional to anatomical registration values from FSFAST preprocessing step. 
To interpret the values check Freesurfer documentation or refer to the DARPA fMRI manual. 
The results of the script are saved in a summary csv. 
''' 

import os, subprocess, re

# Specify root directory. This is the project directory that follows FSFAST directory convention. 
root_dir = '/autofs/space/lilli_004/users/DARPA-ECR/'
os.chdir(root_dir)

# Initialize list of subjects. 
matches = []

# Go through each subject folder and populate list of subjects based on subjectname file.
for folder in os.listdir(root_dir):
    if os.path.isfile( os.path.join( root_dir, folder, 'subjectname' ) ): 
        matches.append(os.path.join(root_dir,folder))

# Specify name of task folder.
runs = ['ecr_001']

info = ''

# Open summary csv file with write permission 
with open(os.path.join(root_dir, 'scripts', 'preproc', 'qc_values.csv'), 'w') as f:
    
    # Write column headers in csv 
    f.write(' '.join(['subjid','task','reg_qc'])+'\n')

    # Iterate through each subject
    for match in sorted(matches):

	# Iterate through each task folder for each subject
        for run in runs:

	    subjid = os.path.basename(match)

	    # Run Freesurfer command to extract coregistration cost value. 
	    cmd = 'tkregister-sess -s %s -fsd %s -per-run -bbr-sum -b0dc' %(subjid,run)
	    proc = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, )
	    output, _ = proc.communicate()
	
	    # Parse output from above command. 
	    output = re.sub(' +', ' ',output)
	    if output.startswith('ERROR'):
		output = ' '.join([subjid, '001']) + ' \n'
	    output = output.split(' ')
	    output.insert(1, run)
	    output.pop(2)
	    info = ' '.join([s for s in output])
            	
	    # Write output to csv. 
	    f.write(info)
