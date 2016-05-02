#!/bin/sh

set -e -x
# Assumptions:
# Subject ID is passed on the command line followed by fullpath to dicom directory
# FreeSurfer is loaded and SUBJECTS_DIR is set
# cpb/proj_conf.sh has been sourced

if [[ -z "${1// }" ]] || [ ! -e $base/$1 ]; then 
    echo "Help. something is wrong"; exit 1;fi
sub=$1
sd=$SUBJECTS_DIR
wd=/$sd/$sub

cd $wd/

# Register the T2WB to the T1
if [ ! -e $wd/struc.anat/t2wb_to_t1.nii.gz ];then
epi_reg --epi=$wd/hipp/t2wb \
    --t1=$wd/struc.anat/T1_biascorr \
    --t1brain=$wd/struc.anat/T1_biascorr_brain \
    --wmseg=$wd/struc.anat/T1_fast_pve_2 \
    --out=$wd/struc.anat/t2wb_to_t1
fi
subs_w_bad_qform=""

# Register the high res hipp T2 to the T2 WB
if [[ $subs_w_bad_qfrom == *$sub* ]];then 
    flirt -in $wd/hipp/hip_algn_avg \
	-ref $wd/hipp/t2wb -nosearch \
	-omat  $wd/hipp/hip_avg_to_t2wb.mat \
	-out $wd/hipp/hip_avg_to_t2wb
else
    flirt -in $wd/hipp/hip_algn_avg \
	-ref $wd/hipp/t2wb -usesqform -nosearch \
	-omat $wd/hipp/hip_avg_to_t2wb.mat \
	-out $wd/hipp/hip_avg_to_t2wb
fi

# Combine those two transforms together

concat_xfm.sh $wd/hipp/hip_avg_to_t2wb.mat \
    $wd/struc.anat/t2wb_to_t1.mat \
    $wd/hipp/hipp_to_t1.mat

$FSLDIR/bin/applywarp -i  $wd/hipp/hip_algn_avg \
    -r $wd/struc.anat/T1_biascorr -o $wd/hipp/hip_to_t1 \
    --premat=$wd/hipp/hipp_to_t1.mat --interp=spline

# Convert them to ITK
c3d_affine_tool -ref $wd/struc.anat/T1_biascorr_brain.nii.gz  \
    -src $wd/hipp/hip_algn_avg.nii.gz  \
     $wd/hipp/hipp_to_t1.mat \
    -fsl2ras -oitk $wd/hipp/hipp_to_t1_itkxfm.txt
HIP_TO_T1=$wd/hipp/hipp_to_t1_itkxfm.txt
# Sometimes this doesn't work (d704)
# You can try to directly register the hip_algn_avg to the T1 with this:

if [ "$sub" -eq "d704" ]; then
    fslmaths $wd/hipp/hip_algn_avg -thr 200 -bin -ero -dilF -bin $wd/hipp/hip_algn_avg_mask
    fslmaths $wd/struc.anat/T1_biascorr_bet_mask -dilF -dilF -dilF -dilF -dilF $wd/struc.anat/T1_biascorr_bigmask5
#    cp $wd/struc.anat/T1_biascorr_bet_mask.nii.gz $wd/struc.anat/T1_biascorr_bigmask0.nii.gz
#    for i in `seq 0 4`;do 
#	fslmaths $wd/struc.anat/T1_biascorr_bigmask$i -dilF $wd/struc.anat/T1_biascorr_bigmask`echo $i+1|bc`
#    done
    
    # For d704 this took a lot of trial and error
    # It finally worked when I stop using the hipp_to_t1.mat to initialize the reg.
    # Apparently caught in some kind of local minimum

    $ANTSPATH/antsRegistration \
	-d 3 --float 1 --verbose 1 -u 1 -z 1 \
	-x [$wd/struc.anat/T1_biascorr_bigmask5.nii.gz,$wd/hipp/hip_algn_avg_mask.nii.gz] \
	-t Rigid[0.1]  \
	-m MI[$wd/struc.anat/T1_biascorr.nii.gz,$wd/hipp/hip_algn_avg.nii.gz,.8,32,Regular,0.25] \
	-c [1000x500x250x0,1e-6,10] -f 6x4x2x1 -s 4x2x1x0 \
	-t Affine[0.1]  \
	-m MI[$wd/struc.anat/T1_biascorr.nii.gz,$wd/hipp/hip_algn_avg.nii.gz,.8,32,Regular,0.25] \
	-c [1000x500x250x0,1e-6,10] -f 6x4x2x1 -s 4x2x1x0 \
	-o $wd/hipp/hip_to_t1_direct_ANTS

    $ANTSPATH/antsApplyTransforms \
	-d 3 --float 1 --verbose 1 \
	-i $wd/hipp/hip_algn_avg.nii.gz \
	-o $wd/hipp/hip_to_t1_direct_ANTS.nii.gz \
	-r $wd/struc.anat/T1_biascorr.nii.gz \
	-t $wd/hipp/hip_to_t1_direct_ANTS0GenericAffine.mat
    mv $wd/hipp/hipp_to_t1.mat $wd/hipp/hipp_to_t1_fail.mat
    HIP_TO_T1=$wd/hipp/hip_to_t1_direct_ANTS0GenericAffine.mat 
fi


for s in r l; do
    # Convert the hipp label from mgz to nii
    mri_convert $wd/mri/${s}h.hippoSfLabels-T1.v10.mgz \
	$wd/hipp/${s}h.hippoSfLabels-T1.v10.nii.gz

    # Get the T1 in hipp space
    $ANTSPATH/antsApplyTransforms -d 3 \
	--float 1 -v 1 \
	-i $wd/struc.anat/T1_biascorr.nii.gz  \
	-o $wd/hipp/${s}hipp_t1.nii.gz \
	-r $wd/hipp/${s}h.hippoSfLabels-T1.v10.nii.gz
    
    # Apply the new one to the highres hippo (ANTS)
    $ANTSPATH/antsApplyTransforms -d 3 \
	--float 1 -v 1 \
	-i $wd/hipp/hip_algn_avg.nii.gz  \
	-o $wd/hipp/${s}hipp_t2s.nii.gz \
	-r $wd/hipp/${s}h.hippoSfLabels-T1.v10.nii.gz \
	-t $HIP_TO_T1
done

