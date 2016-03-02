#!/bin/sh

set -e -x

# Assumptions:
# Subject ID is passed on the command line followed by fullpath to dicom directory
# FreeSurfer is loaded and SUBJECTS_DIR is set
# proj_conf.sh has been sourced

if [[ -z "${1// }" ]] || [ ! -e $base/$1 ]; then 
    echo "Help. something is wrong"; exit 1;fi
sub=$1
dicomDir=$2
sd=$SUBJECTS_DIR
mkdir -p $sd/$sub/mri/orig
cd $sd/$sub
load_dicom -i $dicomDir -o $base/$sub/ -s nii


# We need to add a little logic here to 
# a) See if the fsl_anat has already been done. Prob. no reason to do it again.
# b) Check if there is a different struc image we should be using. Each sub should probably have a JSON or YAML file with parameters like this
strucFile=images_004_HIREST1MPRAGE07iso1001.nii.gz

fsl_anat -i nii/$strucFile -o struc

mri_convert $sd/$sub/struc.anat/T1_biascorr.nii.gz $sd/$sub/mri/orig/001.mgz
