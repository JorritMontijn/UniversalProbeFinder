function ProbeFinder(sAtlas,sProbeCoords,sClusters)
	%ProbeFinder Multi-species probe alignment program using neurophysiological markers
	
	%To use this program, simply run:
	%ProbeFinder
	%in the matlab prompt. Please read the manual for more detailed instructions.
	%
	%The Universal Probe Finder can use multiple atlases and calculates the stimulus responsiveness
	%of your clusters with the zetatest using only an array of event-onset times. Using these
	%neurophysiological markers will allow a more reliable alignment of your probe's contact points
	%to specific brain areas.
	%
	%At this time, can use the following atlases:
	%a.	Sprague Dawley rat brain atlas, downloadable at: https://www.nitrc.org/projects/whs-sd-atlas
	%b.	Allen CCF mouse brain atlas, downloadable at: http://data.cortexlab.net/allenCCF/
	%c. CHARM/SARM macaque brain atlas: https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/nonhuman/macaque_tempatl/atlas_charm.html
	%It is also possible to add your own Atlas by editing the configAtlas.ini file that is created
	%when you first run the ProbeFinder (see manual).
	%
	%Please reach out to us (for example here: https://github.com/JorritMontijn/UniversalProbeFinder)
	%if you wish to have a different atlas added with out-of-the-box support. Adding an atlas is
	%very easy, and we're happy to extend the usefulness of our program for all its users.
	%
	%Acknowledgements
	%This work is based on earlier work by people from the cortex lab, most notably Philip Shamash
	%and Andy Peters. See for example this paper: https://www.biorxiv.org/content/10.1101/447995v1
	%
	%This repository includes various functions that come from other repositories, credit for these
	%functions go to their creators:
	%https://github.com/petersaj/AP_histology
	%https://github.com/JorritMontijn/Acquipix
	%https://github.com/JorritMontijn/GeneralAnalysis
	%https://github.com/kwikteam/npy-matlab
	%https://github.com/cortex-lab/spikes
	%https://github.com/JorritMontijn/zetatest
	%
	%License
	%This repository is licensed under the GNU General Public License v3.0, meaning you are free to
	%use, edit, and redistribute any part of this code, as long as you refer to the source (this
	%repository) and apply the same non-restrictive license to any derivative work (GNU GPL v3).
	%
	%Created by Jorrit Montijn at the Cortical Structure and Function laboratory (KNAW-NIN)
	
	%% add subfolders
	if ~isdeployed
		%disable buttons
		global sUPF_ChooseGui %#ok<TLEV>
		UPF_DisableButtons(sUPF_ChooseGui);
		
		%add folders
		strFullpath = mfilename('fullpath');
		strPath = fileparts(strFullpath);
		sDir=dir([strPath filesep '**' filesep]);
		%remove git folders
		sDir(contains({sDir.folder},[filesep '.git'])) = [];
		cellFolders = unique({sDir.folder});
		for intFolder=1:numel(cellFolders)
			addpath(cellFolders{intFolder});
		end
		
		%enable buttons
		UPF_EnableButtons(sUPF_ChooseGui);
	end
	
	%% check if zetatest submodule is present
	if ~exist('zetatest','file')
		errordlg('Your repository is corrupt: cannot find zetatest and dependencies. Please download the zetatest repository from https://github.com/JorritMontijn/zetatest and ensure you add the folders to the matlab path','Missing dependencies');
	end
		
	%% load atlas
	%check if input comes from gui
	if exist('sAtlas','var') && isa(sAtlas,'matlab.ui.control.UIControl')
		sAtlas = [];
		sProbeCoords = [];
		sClusters = [];
	end
	if ~exist('sAtlas','var') || isempty(sAtlas)
		sAtlasParams = PF_getAtlasIni();
		
		%select which atlas to use
		cellAtlases = {sAtlasParams.name};
		[intSelectAtlas,boolContinue] = listdlg('ListSize',[200 100],'Name','Atlas Selection','PromptString','Select Atlas:',...
			'SelectionMode','single','ListString',cellAtlases);
		if ~boolContinue,return;end
		
		%try using Acquipix variables
		try
			sRP = RP_populateStructure();
			strDefaultPath = sRP.strProbeLocPath;
		catch
			sRP = struct;
			strDefaultPath=cd();
		end
		
		%load atlas
		strAtlasName = sAtlasParams(intSelectAtlas).name; %#ok<NASGU>
		strPathVar = sAtlasParams(intSelectAtlas).pathvar;
		fLoader = sAtlasParams(intSelectAtlas).loader;
		
		%get path
		strAtlasPath = PF_getIniVar(strPathVar);
		
		%load & prep atlas
		sAtlas = feval(fLoader,strAtlasPath);
		if isempty(sAtlas),return;end
		if isfield(sAtlasParams(intSelectAtlas),'downsample') && ~isempty(sAtlasParams(intSelectAtlas).downsample)
			sAtlas.Downsample = round(sAtlasParams(intSelectAtlas).downsample);
		else
			sAtlas.Downsample = 1;
		end
	end
	
	%% load coords file
	if ~exist('sProbeCoords','var') || isempty(sProbeCoords)
		sProbeCoords = PH_LoadProbeFile(sAtlas,strDefaultPath);
	end
	
	%% load ephys
	%select file
	try
		strOldPath = cd(sRP.strEphysPath);
		strNewPath = sRP.strEphysPath;
	catch
		strOldPath = cd();
		strNewPath = strOldPath;
	end
	if ~exist('sClusters','var') || isempty(sClusters)
		%open ephys data
		sClusters = PH_OpenEphys(strNewPath);
	end
	
	% load or compute zeta if ephys file is not an Acquipix format
	if isempty(sClusters) || contains(sClusters.strZetaTit,'Contamination')
		%select
		sZetaResp = PH_OpenZeta(sClusters,strNewPath);
		
		%save
		if ~isempty(sZetaResp) && isfield(sZetaResp,'vecZetaP') && ~isempty(sZetaResp.vecZetaP)
			sClusters.vecDepth = sZetaResp.vecDepth;
			sClusters.vecZeta = norminv(1-(sZetaResp.vecZetaP/2));
			sClusters.strZetaTit = 'ZETA (z-score)';
		end
	end
	
	% close message
	cd(strOldPath);
	
	%% run GUI
	PH_GenGUI(sAtlas,sProbeCoords,sClusters);
end