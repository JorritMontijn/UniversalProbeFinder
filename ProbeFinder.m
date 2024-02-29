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
		%check version
		PF_AssertVersion();
		
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
		%load coords
		[sProbeCoords,strFile,strPath] = PH_LoadProbeFile(sAtlas,strDefaultPath);
		
		% check if selected file is a native probe finder file with ephys data
		strClusterFile = fullpath(strPath,strFile);
		[strPath,strShortFile,strExt]=fileparts(strClusterFile);
		if (~exist('sClusters','var') || isempty(sClusters))...
				&& exist(strClusterFile,'file') == 2 && length(strExt) > 3 && strcmp(strExt,'.mat')
			%load
			sLoad = load(strClusterFile);
			if isfield(sLoad,'sClusters')
				% check if format is correct
				sClusters = sLoad.sClusters;
				cellNewFields = {'Clust','ProbeLength'};
				cellLoadFields = fieldnames(sClusters);
				if all(ismember(cellNewFields,cellLoadFields))
					%perfect
				else
					%delete data
					sClusters = [];
				end
			else
				sClusters = [];
			end
		end
	end
	
	%% load ephys
	%select file
	try
		strOldPath = cd(sRP.strEphysPath);
		strNewPath = sRP.strEphysPath;
	catch
		
		if exist('strPath','var') && exist(strPath,'dir')
			strOldPath = cd(strPath);
			strNewPath = strPath;
		else
			strOldPath = cd();
			strNewPath = strOldPath;
		end
	end
	if ~exist('sClusters','var') || isempty(sClusters)
		%open ephys data
		sClusters = PH_OpenEphys(strNewPath);
	end
	
	% load or compute zeta if ephys file is not an Acquipix format
	if isempty(sClusters) ...
			|| (~isempty(sClusters) && isfield(sClusters,'Clust') && ...
			(~isfield(sClusters.Clust,'Zeta') && ~isfield(sClusters.Clust,'ZetaP')))
		%select
		sClusters = PH_OpenZeta(sClusters,strNewPath);
	end
	
	%transform p-value to z-score if ZetaP is present
	if isfield(sClusters,'Clust') && isfield(sClusters.Clust,'ZetaP')
		for i=1:numel(sClusters.Clust)
			sClusters.Clust(i).Zeta = -norminv(min(sClusters.Clust(i).ZetaP)/2);
		end
		sClusters.Clust = rmfield(sClusters.Clust,'ZetaP');
	end
	
	% close message
	cd(strOldPath);
	
	%% run GUI
	PH_GenGUI(sAtlas,sProbeCoords,sClusters);
end