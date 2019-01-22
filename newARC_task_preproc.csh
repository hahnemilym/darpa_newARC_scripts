#This script does the following preprocessing steps for the ARC, MSIT, ECR, WAR, Learning tasks: 
#	- Rename slice-time corrected functional file to f.nii for given subjects and tasks
#	- Perform beta-zero correction (epidewarp.fsl)
#	- Perform preprocessing step (preproc_sess)
#
#Note that prior to running this script, you will have to: 
#	- Run the transfer_dicoms.py script that copies over raw data from darpa transfer into the corresponding fsfast project directory
#	- Perform slice-time correction in SPM
#
#For documenation on the above steps see the DARPA fMRI manual. 

#!/bin/csh -f

## Source Freesufer.
source /usr/local/freesurfer/nmr-stable53-env

## Specify DARPA Freesurfer reconstruction directory
setenv SUBJECTS_DIR /autofs/space/lilli_001/users/DARPA-Recons/

###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~###
## ONLY CHANGE THE FOLLOWING FIELDS ##
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~###

set SUBJECTS = (ep017)    ## Specify subjects
set FWHM = 6 		  ## Specify smoothing 
set TASKS = (msit)	  ## Specify task
set RUN = 001		  ## Specify run number

###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~###

###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~###
## DO NOT CHANGE ANYTHING BELOW THIS LINE.
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~###

## Specify surface. 
set SURFACE = fsaverage

## Iterate through above specified tasks
foreach TASK ($TASKS)

    ## Iterate through above specified subjects
    foreach SUBJECT ($SUBJECTS)
       

	###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~###
        ## Set Project Directory and TR for each task.  
        ###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~###
	switch ($TASK)
    	    case 'arc':
        	set TR = 1750 
		set ROOT_DIR = /autofs/space/lilli_002/users/DARPA-ARC/
                breaksw
	    case 'arc_rer':
                set TR = 1750  
                set ROOT_DIR = ''
		breaksw
            case 'msit':
                set TR = 1750 
                set ROOT_DIR = /autofs/space/lilli_004/users/DARPA-MSIT/
		breaksw
            case 'ecr':
                set TR = 2000
                set ROOT_DIR = /autofs/space/lilli_004/users/DARPA-ECR/
                breaksw
            case 'war':
                set TR = 2000 
                set ROOT_DIR = /autofs/space/lilli_002/users/DARPA-WAR/
                breaksw
            case 'learning':
                set TR = 2200
                set ROOT_DIR = /autofs/space/lilli_004/users/DARPA-Learning/
                breaksw
            case 'cond':
                set TR = 2560 
                set ROOT_DIR = ''
                breaksw
            case 'ext':
                set TR = 2560 
                set ROOT_DIR = ''
                breaksw
            case 'rcl':
                set TR = 2560
                set ROOT_DIR = ''
                breaksw
	    default:
		echo 'Invalid Task'
		breaksw
	endsw

	###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~###
        ## Rename slice-time correction volume.
        ###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~###

	cd $ROOT_DIR
        set SUB_NAME = `echo $SUBJECT | tr '[:lower:]' '[:upper:]'`
	set TASK_NAME = `echo $TASK | tr '[:lower:]' '[:upper:]'`
	echo $TASK_NAME	
	if ($TASK == learning) then 
	    set TASK_NAME = Learning
	else if ( $TASK == arc_rer ) then 
	    set TASK_NAME = ARC
	endif 
        
	if !(-f $ROOT_DIR/$SUBJECT/{$TASK}_{$RUN}/001/a{$SUB_NAME}_{$TASK_NAME}.nii) then
            if (-f $ROOT_DIR/$SUBJECT/{$TASK}_{$RUN}/001/f.nii) then
                echo 'Source file already renamed to f.nii.'
            else
                echo $ROOT_DIR/$SUBJECT/{$TASK}_{$RUN}/001/a{$SUB_NAME}_{$TASK_NAME}.nii
		echo 'Source file not found.'
            endif
        else
            set SRC = $ROOT_DIR/$SUBJECT/{$TASK}_{$RUN}/001/a{$SUB_NAME}_{$TASK_NAME}.nii
            set DST = $ROOT_DIR/$SUBJECT/{$TASK}_{$RUN}/001/f.nii
            echo 'Renaming File.'
            mv $SRC $DST
        endif

	###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~###
	## Reinforce TR. (SPM removes TR info from header during STC)
        ###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~###
	
	if ( $TASK == arc || $TASK == arc_rer || $TASK == msit ) then 
	    set TR = 1750
	else if ( $TASK == ecr || $TASK == war ) then 
	    set TR = 2000
	else if ( $TASK == cond || $TASK == rcl || $TASK == ext ) then 
	    set TR = 2560
	else if ( $TASK == learning ) then 
	    set TR = 2200
	else
	    echo 'ERROR: Entered invalid task condition: ' $TASK
	endif 

	## Convert f.niii
        if (-f $ROOT_DIR/$SUBJECT/{$TASK}_{$RUN}/001/f.nii) then
            set FN = f.nii
        endif
        set FN = f.nii
        set INFO = `mri_info $ROOT_DIR/$SUBJECT/{$TASK}_{$RUN}/001/$FN --tr`
        if !($INFO == $TR) then
            mri_convert $ROOT_DIR/$SUBJECT/{$TASK}_{$RUN}/001/$FN $ROOT_DIR/$SUBJECT/{$TASK}_{$RUN}/001/$FN -tr $TR
            #sleep 30
        else
            echo 'TR matches for ' $FN
        endif

        ###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~###
	## Beta-zero correction. 
        ###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~###

	if ( -f $ROOT_DIR/$SUBJECT/{$TASK}_{$RUN}/b0dcmap.nii.gz ) then 
	    echo 'Beta-zero corrected.'
	else
            ## Source FSL 4.1.10.
            source /usr/local/freesurfer/nmr-stable53-env
            set FSL_DIR = /usr/pubsw/packages/fsl/4.1.10/
            source /usr/local/freesurfer/nmr-stable53-env
        
	    epidewarp.fsl --mag $ROOT_DIR/$SUBJECT/{$TASK}_{$RUN}/001/mag.nii --dph $ROOT_DIR/$SUBJECT/{$TASK}_{$RUN}/001/phase.nii --epi $ROOT_DIR/$SUBJECT/{$TASK}_{$RUN}/001/f.nii --tediff 2.46 --esp 0.69 --vsm $ROOT_DIR/$SUBJECT/{$TASK}_{$RUN}/b0dcmap.nii.gz
	endif

        ###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~###
	## Preprocess. 
        ###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~###
	
	## Source current version of FSL. 
	set FSL_DIR = /usr/pubsw/packages/fsl/current
	source /usr/local/freesurfer/nmr-stable53-env
	preproc-sess -s $SUBJECT -surface $SURFACE lhrh -mni305 -fwhm $FWHM -per-run -fsd {$TASK}_{$RUN} -nostc -b0dc -force

	# Make Motion Plots
	plot-twf-sess -s $SUBJECT -fsd {$TASK}_{$RUN} -mc
    end
end

## Return to scripts directory.
cd $ROOT_DIR/scripts/preproc
