# UniversalProbeFinder 
 \
Multi-species probe alignment program using neurophysiological markers \
\
To use this program, simply run:\
ProbeFinder\
in the matlab prompt. Please read the manual for more detailed instructions.

# Atlases
The Universal Probe Finder can use multiple atlases and calculates the stimulus responsiveness of your clusters with the zetatest using only an array of event-onset times. Using these neurophysiological markers will allow a more reliable alignment of your probe's contact points to specific brain areas. \
\
At this time, the Universal Probe Finder supports the following atlases out-of-the-box:\
a.	Sprague Dawley rat brain atlas, downloadable at: https://www.nitrc.org/projects/whs-sd-atlas \
b.	Allen CCF mouse brain atlas, downloadable at: http://data.cortexlab.net/allenCCF/ \
c. CHARM/SARM NMT_v2.0_sym macaque brain atlas: https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/nonhuman/macaque_tempatl/atlas_charm.html \
\
It is also possible to add your own Atlas by editing the configAtlas.ini file that is created when you first run the ProbeFinder (see manual).\
\
Please reach out to us if you wish to have a different atlas added with out-of-the-box support. Adding an atlas is very easy, and we're happy to extend the usefulness of our program for all its users.

# Acknowledgements
This work is based on earlier work by people from the cortex lab, most notably Philip Shamash and Andy Peters. See for example this paper: https://www.biorxiv.org/content/10.1101/447995v1\
\
This repository includes various functions that come from other repositories, credit for these functions go to their creators:\
https://github.com/petersaj/AP_histology \
https://github.com/JorritMontijn/Acquipix \
https://github.com/JorritMontijn/GeneralAnalysis \
https://github.com/kwikteam/npy-matlab \
https://github.com/cortex-lab/spikes \
https://github.com/JorritMontijn/zetatest

# License
This repository is licensed under the GNU General Public License v3.0, meaning you are free to use, edit, and redistribute any part of this code, as long as you refer to the source (this repository) and apply the same non-restrictive license to any derivative work (GNU GPL v3).\
\
Created by Jorrit Montijn at the Cortical Structure and Function laboratory (KNAW-NIN).
