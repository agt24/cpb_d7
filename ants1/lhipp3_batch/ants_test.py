
# coding: utf-8

# In[46]:

# Import modules and set experiment-specific parameters
import copy
import os
from os.path import join as opj
from nipype.pipeline.engine import Workflow, Node, MapNode
from nipype.interfaces.io import SelectFiles, DataSink
from nipype.interfaces.utility import IdentityInterface
from nipype.interfaces.ants import Registration

filepath = os.path.dirname( os.path.realpath( '__file__'))
datadir = os.path.realpath(os.path.join(filepath, ''))
os.chdir(datadir)
subject_list_test= ['d701']
#subject_list = ['d701', 'd702', 'd703', 'd704', 'd705', 'd706', 'd707', 
#                'd708', 'd709', 'd710', 'd711', 'd712', 'd713', 'd714', 
#                'd715', 'd716', 'd717', 'd720', 'd722', 'd723', 'd724', 
#                'd726', 'd727', 'd728', 'd729', 'd730', 'd731', 'd732', 
#                'd734']


# In[50]:

# Rigid node



antsreg = Registration()
antsreg.inputs.float = True
antsreg.inputs.collapse_output_transforms=True
antsreg.inputs.fixed_image=['/spin1/users/Hippo_hr/cpb/ants1/lhipp3_batch/lhtemplate0.nii.gz',
                            '/spin1/users/Hippo_hr/cpb/ants1/lhipp3_batch/lhtemplate1.nii.gz',
                            '/spin1/users/Hippo_hr/cpb/ants1/lhipp3_batch/lhtemplate2.nii.gz']
antsreg.inputs.moving_image=['/spin1/users/Hippo_hr/cpb/ants1/lhipp3_batch/d701-lab.nii.gz',
                             '/spin1/users/Hippo_hr/cpb/ants1/lhipp3_batch/d701-t1-mask.nii.gz',
                             '/spin1/users/Hippo_hr/cpb/ants1/lhipp3_batch/d701-t2s-bfc-mask.nii.gz']
antsreg.inputs.initial_moving_transform_com=1
antsreg.inputs.num_threads=1
antsreg.inputs.output_warped_image=True

antsreg.inputs.transforms=['Rigid']
antsreg.inputs.terminal_output='stream'
antsreg.inputs.winsorize_lower_quantile=0.005
antsreg.inputs.winsorize_upper_quantile=0.995
antsreg.inputs.convergence_threshold=[1e-06]
antsreg.inputs.convergence_window_size=[10]
antsreg.inputs.metric=[['MeanSquares','MI','MI']]
antsreg.inputs.metric_weight=[[0.75,0.125,0.125]]
                              
antsreg.inputs.number_of_iterations=[[1000, 500, 250, 0]]
antsreg.inputs.smoothing_sigmas=[[4, 3, 2, 1]]
antsreg.inputs.sigma_units=['vox']
antsreg.inputs.radius_or_number_of_bins=[[0,32,32]]

antsreg.inputs.sampling_strategy=[['None',
                               'Regular',
                               'Regular']]
antsreg.inputs.sampling_percentage=[[0,0.25,0.25]]

antsreg.inputs.shrink_factors=[[12,8,4,2]]

antsreg.inputs.transform_parameters=[[(0.1)]]

antsreg.inputs.use_histogram_matching=True
antsreg.inputs.write_composite_transform=True

test_antsreg_rigid = Node(antsreg,name='test_antsreg_rigid')

antsreg.cmdline


# In[48]:

# Establish input/output stream

infosource = Node(IdentityInterface(fields=['subject_id']), name = "infosource")
infosource.iterables = [('subject_id', subject_list_test)]

lhtemplate_files = opj('lhtemplate*.nii.gz')
label_files = opj('{subject_id}-lab.nii.gz')
t1_files = opj('{subject_id}-t1-mask.nii.gz')
t2_files = opj('{subject_id}-t2s-bfc-mask.nii.gz')

templates = {'lhtemplate': lhtemplate_files,
            'label_files': label_files,
             't1_files': t1_files,
             't2_files': t2_files,}
selectfiles = Node(SelectFiles(templates, base_directory=datadir), name = "selectfiles")


# In[55]:

# Create pipeline and connect nodes
workflow = Workflow(name='normflow')
workflow.base_dir = '.'
workflow.add_nodes([test_antsreg_rigid])
#workflow.connect([(infosource, selectfiles, [('subject_id', 'subject_id')]),
#                (selectfiles, test_antsreg_rigid, [('lhtemplate','moving_image')]),])
workflow.write_graph()
workflow.run()

