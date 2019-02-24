#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# II. Set up environment
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
source /usr/local/freesurfer/nmr-stable60-env

# Local Directory
setenv DIR /autofs/space/lilli_

# Subjects Directory
setenv SUBJECTS_DIR ${DIR}001/users/DARPA-Recons

# Analysis Directory
setenv ANALYSES_DIR ${DIR}001/users/DARPA-Scripts/tutorials/darpa_pipelines_EH/darpa_newARC_scripts

# Project Directory
setenv newARC_DIR ${DIR}001/users/DARPA-newARC

# Parameters Directory
setenv PARAMS_DIR $MSIT_DIR/behavior

## https://surfer.nmr.mgh.harvard.edu/fswiki/FsFastParametricModulation

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# I. Define parameters.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
set FWHM = 6 
set TR = 1.75
set FD = (1.0)
set fsd = newARC_001
set subdir = 001
set subjects = ($PARAMS_DIR/params/subjects.txt)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# III. INDIVIDUAL ANALYSES
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

cd $MSIT_DIR

foreach SUBJECT ( `cat $subjects` )

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# IV. Create paradigm file
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#


cp $PARAMS_DIR/indiv_par_files/${SUBJECT}_allruns.par \
$newARC_DIR/$SUBJECT/$fsd/$subdir/


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# V. Configure analyses 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

foreach cortices ( lh rh )

mkanalysis-sess \
-fsd $fsd \
-surface fsaverage $cortices \
-fwhm $FWHM \
-event-related \
-paradigm ${SUBJECT}_allruns.par \
-nconditions 2 \
-spmhrf 0 \
-TR $TR \
-refeventdur 1.75 \
-nskip 4 \
-hpf 0.02 \
-analysis PM.analyses/msit_I-C.analysis.$cortices \
-per-run \
-nuisreg PM.mc.par \
-1 -tpexclude PM.censor.$FD.par \
-force

end


foreach subcortices ( mni305 )

mkanalysis-sess \
-fsd $fsd \
-$subcortices 2 \
-fwhm $FWHM \
-event-related \
-paradigm ${SUBJECT}_allruns.par \
-nconditions 2 \
-spmhrf 0 \
-TR $TR \
-refeventdur 1.75 \
-nskip 4 \
-hpf 0.02  \
-analysis PM.analyses/PM.$subcortices \
-per-run \
-nuisreg PM.mc.par \
-1 -tpexclude PM.censor.$FD.par \
-force

end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# VI. Specify contrasts 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

## Check 1,2,3 conditions in par file

foreach cortices (lh rh mni305)

mkcontrast-sess \
-analysis PM.analysis/PM.analysis.$cortices \
-contrast ParamMod \
-a 3 \
-a 2 \
-c 1 \
-overwrite

end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# VII. Run analysis
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

foreach cortices (lh rh mni305)

selxavg3-sess \
-s $SUBJECT \
-analysis PM.analysis/PM.analysis.$cortices

end

# end subjects loop
end


cd $ANALYSES_DIR

