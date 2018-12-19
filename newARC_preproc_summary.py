''' 
This script creates a summary csv file to track preprocessing steps for subjects in a given FSFAST project directory. 
The script iteratively checks to see if the subject's task raw data has been copies over, whether it's been slice-time corrected, beta-zero corrected and preprocessed. The results are saved in a summary csv. 
''' 

import os, subprocess, re

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
## Set up directories.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
root_dir = '/autofs/space/lilli_004/users/DARPA-ECR/'
os.chdir(root_dir)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
## Search for subjects
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
matches = []
for folder in os.listdir(root_dir):
    if os.path.isfile( os.path.join( root_dir, folder, 'subjectname' ) ): 
        matches.append(os.path.join(root_dir,folder))

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
## List tasks and files created during preproc.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

# Specify name of task directory. 
runs = ['ecr_001']

# Specify which preprocessing files to look for when checking if task has been preprocessed. 
preproc_files = ['fmcpr.sm6.fsaverage.lh.b0dc', 'fmcpr.sm6.fsaverage.rh.b0dc', 'fmcpr.sm6.mni305.2mm.b0dc']
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
## Main loop.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
info = ''
with open(os.path.join(root_dir, 'scripts', 'preproc', 'preproc_summary.csv'), 'w') as f:
    f.write(' '.join(['subjid','task','STC','B0','preproc'])+'\n')     
    
    # Iterate through subjects
    for match in sorted(matches):
	subjid = os.path.basename(match)
        
	# Iterate through each above specified task 
	for run in runs:
	    
	    lh, rh, mni = False, False, False
            
	    # If run directory for that task and subject doesn't exist, write DNE
	    if not os.path.isdir(os.path.join(root_dir, subjid, run, '001')):
                f.write(' '.join([subjid, run, 'DNE', '\n']))
	    else:
                
                # Iterate through files in run folder to check if all cortical and subcortical preprocessed files exist
                for fn in os.listdir( os.path.join( root_dir, subjid, run, '001')):
                    if fn.startswith(preproc_files[0]):
                        lh = True
                    if fn.startswith(preproc_files[1]):
                        rh = True
                    if fn.startswith(preproc_files[2]):
                        mni = True
 
            # If all of the above cortical and subcortical files exist, write complete. 
	    if (lh and rh and mni):
		f.write(' '.join([subjid, run, 'complete', 'complete', 'complete', 'complete', '\n']))
	    else:
		# If not preprocessed, check if files have been slice-time corrected
		stc = (os.path.isfile(os.path.join(root_dir, subjid, run, '001', 'f.nii')) or os.path.isfile(os.path.join(root_dir, subjid, run, '001', 'a%s_ECR.nii' %subjid.upper())))
		# Check if files have been beta-zero corrected
		beta_zero = os.path.isfile(os.path.join(root_dir, subjid, run,  'b0dcmap.nii.gz'))
		files = [s.lower() for s in os.listdir(os.path.join(root_dir, subjid, run, '001'))]
		
	        # check if files have been copied over from the transfer folder. 
		for s in files:
		    if (s.startswith(subjid) and s.endswith('.nii')) or s.startswith('f.nii'):
			transfer = True
		
	        # Write to csv. 
		if (stc and beta_zero):
		    f.write(' '.join([subjid, run, 'complete', 'complete', 'complete', '\n']))
		elif ( stc and (not beta_zero) ):
		    f.write(' '.join([subjid, run, 'complete', 'complete', '\n']))
                elif ( transfer and (not stc) and (not beta_zero) ):
		    f.write(' '.join([subjid, run, 'complete', '\n']))
