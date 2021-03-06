# Methods and Materials
## Subjects
COS patients (n=19), unaffected full siblings (n=19), and healthy controls (n=21) were recruited nationwide and matched for age and sex. Patients were diagnosed by two child psychiatrists based on DSM-III-R/DSM-IV criteria (American Psychiatric Association, 2000) after 2-3 months of inpatient observation, including 1-3 weeks of medication washout, and were excluded contingent on medical or neurological illness, substance abuse, or premorbid IQ <70. Further details may be found in previous descriptions (Gochman et al., 2011; Kumra et al., 2000; McKenna et al., 1994). Detailed interviews were conducted by a child psychiatrist about every two years for confirmation of diagnosis and assessment of symptom severity using the Scale for the Assessment of Positive Symptoms (SAPS) and Scale for the Assessment of Negative Symptoms (SANS) (Andreasen, 1983, 1984). At the time of study, all patients were receiving treatment with medication, typically clozapine. Medication doses were converted to chlorpromazine equivalents (Woods, 2003). Unaffected siblings presented no schizophrenia, schizoaffective, or psychosis spectrum symptoms, determined through structured psychiatric assessments. Consanguineous patients (n=5) and siblings (n=11) from 7 families were noted for later statistical control. Healthy controls were recruited from the community and matched for age and sex. They were free of lifetime medical or psychiatric disorders and had no first-degree relatives with psychiatric illness, determined by clinical examination and standardized interviews. Participants performed the California Verbal Learning Test – Second Edition [CVLT-II] (Delis, 2000; Woods et al., 2006) or California Verbal Learning Test – Children’s Version [CVLT-C] (Delis, 1994), a standardized measure of verbal memory and intrusion errors. In this measure, List A (trials 1 to 5) consists of 16 nouns spanning 4 semantic categories spoken by the test administrator at 1-second intervals. Participants are asked to recall as many words as they can in any order. List B is presented, consisting of 16 different nouns with 2 categories shared by list A and 2 new categories. Participants are asked to recall as many words as they can in any order. After 20 minutes performing other tasks, participants are asked to recall as many words as they can from List A. Intrusions errors were measured as the number of words that were recalled from the incorrect list or freestanding of any list. Informed assent and consent were obtained from all participants and/or their parent/guardian in accordance with a National Institutes of Health Institutional Review Board approved protocol. 
## Scan acquisition
We acquired 0.7 mm isotropic MP-RAGE scans and 0.5 mm isotropic T2*-weighted scans using a Siemens 7 Tesla Magnetom MRI scanner with a Magnex 830 magnet, Nova 32-channel 1H head coil, and Syngo MR B17 software. T1-weighted images were acquired with: FOV = 224 x 224 mm2, TR = 2200 ms, TE = 3 ms, TI=1050 ms, FA = 7°, and voxel size = 0.7 x 0.7 x 0.7 mm3; T2*-weighted images were acquired with: FOV = 192 x 162 mm2, TR = 50 ms, TE = 25.7 ms, FA = 10°, and voxel size = 0.5 x 0.5 x 0.5 mm3.
## Preprocessing
COS patients who did not complete scanning were excluded (n=2). Scans were blinded for group assignment and inspected for quality, with exclusion criteria including severe motion or inhomogeneity artifacts (COS patients: n=3; healthy siblings: n=2; controls: n=1). The remaining 51 participants’ (COS patients: n=14; healthy siblings: n=17; controls: n=20) brains were automatically skull-stripped and reconstructed using the 0.7 mm T1-weighted MPRAGE scans with the high-resolution recon-all workflow in FreeSurfer v6.0 (stable release Linux centos6_x86_64-FreeSurfer v6.0.0 2beb96c).
## Hippocampal subfield segmentation and quantification
Hippocampal subfields were automatically segmented at upsampled 0.33 mm isotropic voxels using state-of-the-art multispectral methods in FreeSurfer v6.0, incorporating multimodal information from T1-weighted and T2*-weighted for improved subfield definition and segmentation accuracy, and an ex vivo atlas of 15 postmortem subjects collected at 0.13 mm isotropic and 7 T (Iglesias et al., 2015). Major concerns from previous versions of the segmentation algorithm were addressed, such as agreement with histological characteristics. We measured volumes of seven hippocampal subfields bilaterally: CA1, CA2/3, CA4, the granule cell layer of the dentate gyrus (DG-GCL), molecular layer of the hippocampus (containing the stratum radiatum/lacunosum/moleculare, hippocampal sulcus, and molecular layer of the DG-GCL), hippocampal tail (including parts of CA1-4 and DG-GCL), and subiculum. All segmentations were visually inspected.
## Experiment-specific hippocampal template creation
Template creation using Analysis of Functional NeuroImages (AFNI; version 16.3.06), FMRIB Software Library’s (FSL; version 5.0.10), and Advanced Normalization Tools (ANTs; version 2.1.0) was performed with the parallel processing pipeline, Nipype (version 0.13), and NIH HPC Biowulf cluster computing (hpc.nih.gov) due to large computational demand (Avants et al., 2010; Cox, 1996; Gorgolewski et al., 2011).

To determine whether there is a significantly disproportionate deformation between groups, all hippocampi in the study were scaled to a common template in order to control for variability in gross morphology. These warps to the common template are used to compute whether there are differences in tensor-based deformation. Specifically, if there were multiple high quality T2*-weighted scans, they were aligned, registered to T1-space, and averaged. T1- and T2* images were bias-field corrected using the N4 algorithm (Tustison et al., 2010). Hippocampal labels generated by the Freesurfer segmentation pipeline were dilated and used as masks of the hippocampus in the whole-brain T1- and partial field-of-view T2*-weighted images. T1-weighted, T2*-weighted, and FreeSurfer segmentation images were averaged by modality to create initial templates. This process results in information from three modalities (the hippocampal label, T1-weighted hippocampus, and T2*-weighted hippocampus) incorporated in subsequent linear and elastic spatial transformations to the common multi-modal templates. For non-linear registration, standard practice entails first estimating the low-order parameters of a transform (i.e. those captured by the 6- and 9-parameter matrices), then adjusting for residual differences using elastic (non-uniform) registration. Individual scans were registered to initial templates using 3 iterations of a 6-parameter (3 translations and 3 rotations) rigid body registration, 3 iterations of a 9-parameter (3 translations, 3 rotations, and 3 scales) affine registration, and finally 4 iterations of a highly accurate, elastic B-Spline SyN registration (Avants et al., 2008). The final output is optimized multimodal common templates. Composite transforms for each subject to the optimized templates were used to compute displacement fields and calculate voxel-wise log-Jacobian determinants.
## Analysis
Analyses were performed using R. Group differences in age, sex, handedness, and race were assessed. Analysis of covariance was used to assess the effect of group on volume using the following model:

Subfield volume ~ intercept + β1(age) + β2(sex) + β3(intracranial volume) + β4(diagnosis)

Age by diagnosis interaction effects were not significant in preliminary models, so were not included. Mixed effects models controlling for shared families were also conducted (see Supplementary Information). Hippocampal subfields with group effects were considered significant following the Benjamini-Hochberg procedure for false discovery rate (alpha=0.05). Within significant subfield groups, pairwise group comparisons were conducted with least-squares/covariate-adjusted means, corrected for family-wise error rate using Tukey’s honest significant difference test (=0.05). Hedge’s g (hereafter referred to as d) is an unbiased variant of Cohen’s d for smaller samples, calculated using unadjusted means and pooled standard deviation. 
## Tensor-based morphometry
Significance maps and corrected P values for group differences in voxel-wise deformation of regions of interest were generated using permutation testing (Winkler et al., 2014) of log-Jacobian images and 5000 permutations in the following model assessing whether log-Jacobian determinants depended on diagnostic group, while controlling for age, sex, and intracranial volume: 

Log⁡(Jacobian) ~ intercept + β1(age) + β2(sex) + β3(intracranial volume) + β4(diagnosis)

Exchangeability blocks were assigned to control for violation of assumptions of independence due to consanguinity (i.e. cases when a healthy sibling is related to another healthy sibling or a patient is related to multiple siblings). When comparing two groups, a two-sample t-test was performed to assess the significance of any differences in tensor-based deformation between groups. Voxels were considered significant following family-wise error correction using threshold-free cluster enhancement (alpha=0.05) (Smith and Nichols, 2009).
## Clinical and cognitive correlations
Correlations between absolute volumes and symptom severity were analyzed in subfields that exhibited significant volume deficits. In patients, the relationships of absolute subfield volumes to short-term verbal episodic memory and intrusions were assessed using Spearman’s rank correlation coefficient rho. Holm-Bonferroni correction for family-wise error rate was carried out (alpha=0.05).

# References

American Psychiatric Association, T.F.o.D.-I., 2000. Diagnostic and statistical manual of mental disorders
DSM-IV-TR, 4th ed. American Psychiatric Association, Washington, DC, pp. xxxvii, 943 p.

Andreasen, A., 1983. Scale for the assessment of negative symptoms. University of Iowa, Iowa City.

Andreasen, A., 1984. Scale for the assessment of positive symptoms. University of Iowa, Iowa City.

Avants, B.B., Epstein, C.L., Grossman, M., Gee, J.C., 2008. Symmetric diffeomorphic image registration with cross-correlation: evaluating automated labeling of elderly and neurodegenerative brain. Med Image Anal 12(1), 26-41.

Avants, B.B., Yushkevich, P., Pluta, J., Minkoff, D., Korczykowski, M., Detre, J., Gee, J.C., 2010. The optimal template effect in hippocampus studies of diseased populations. Neuroimage 49(3), 2457-2466.

Cox, R.W., 1996. AFNI: Software for analysis and visualization of functional magnetic resonance neuroimages. Comput Biomed Res 29(3), 162-173.

Delis, D.C., Kramer, J. H., Kaplan, E., & Ober, B. A., 1994. Manual for the California Verbal Learning Test for Children. Psychological Corporation, New York.

Delis, D.C., Kramer, J. H., Kaplan, E., & Ober, B. A. , 2000. CVLT-II: California verbal learning test: adult version. Psychological Corporation, New York.

Gochman, P., Miller, R., Rapoport, J.L., 2011. Childhood-onset schizophrenia: the challenge of diagnosis. Curr Psychiatry Rep 13(5), 321-322.

Gorgolewski, K., Burns, C.D., Madison, C., Clark, D., Halchenko, Y.O., Waskom, M.L., Ghosh, S.S., 2011. Nipype: a flexible, lightweight and extensible neuroimaging data processing framework in python. Front Neuroinform 5, 13.

Iglesias, J.E., Augustinack, J.C., Nguyen, K., Player, C.M., Player, A., Wright, M., Roy, N., Frosch, M.P., McKee, A.C., Wald, L.L., Fischl, B., Van Leemput, K., Alzheimer's Disease Neuroimaging, I., 2015. A computational atlas of the hippocampal formation using ex vivo, ultra-high resolution MRI: Application to adaptive segmentation of in vivo MRI. Neuroimage 115, 117-137.

Kumra, S., Wiggs, E., Bedwell, J., Smith, A.K., Arling, E., Albus, K., Hamburger, S.D., McKenna, K., Jacobsen, L.K., Rapoport, J.L., Asarnow, R.F., 2000. Neuropsychological deficits in pediatric patients with childhood-onset schizophrenia and psychotic disorder not otherwise specified. Schizophr Res 42(2), 135-144.

McKenna, K., Gordon, C.T., Lenane, M., Kaysen, D., Fahey, K., Rapoport, J.L., 1994. Looking for childhood-onset schizophrenia: the first 71 cases screened. J Am Acad Child Adolesc Psychiatry 33(5), 636-644.

Smith, S.M., Nichols, T.E., 2009. Threshold-free cluster enhancement: addressing problems of smoothing, threshold dependence and localisation in cluster inference. Neuroimage 44(1), 83-98.

Tustison, N.J., Avants, B.B., Cook, P.A., Zheng, Y., Egan, A., Yushkevich, P.A., Gee, J.C., 2010. N4ITK: improved N3 bias correction. IEEE Trans Med Imaging 29(6), 1310-1320.

Winkler, A.M., Ridgway, G.R., Webster, M.A., Smith, S.M., Nichols, T.E., 2014. Permutation inference for the general linear model. Neuroimage 92, 381-397.

Woods, S.P., Delis, D.C., Scott, J.C., Kramer, J.H., Holdnack, J.A., 2006. The California Verbal Learning Test--second edition: test-retest reliability, practice effects, and reliable change indices for the standard and alternate forms. Arch Clin Neuropsychol 21(5), 413-420.

Woods, S.W., 2003. Chlorpromazine equivalent doses for the newer atypical antipsychotics. J Clin Psychiatry 64(6), 663-667.
