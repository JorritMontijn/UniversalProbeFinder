function ProbeFinder
	%ProbeFinder Multi-species probe alignment program using neurophysiological markers
	%
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
	%
	%Please reach out to us for example here (https://github.com/JorritMontijn/UniversalProbeFinder)
	%if you wish to use a different atlas. Adding an atlas is very easy, and we're happy to extend
	%the usefulness of our program.
	%
	%Acknowledgements
	%This work is based on earlier work by people from the cortex lab, most notably Philip Shamash
	%and Andy Peters. See for example this paper: https://www.biorxiv.org/content/10.1101/447995v1
	%
	%This repository includes various functions that come from other repositories:
	%https://github.com/petersaj/AP_histology
	%https://github.com/JorritMontijn/Acquipix
	%https://github.com/JorritMontijn/GeneralAnalysis
	%https://github.com/kwikteam/npy-matlab
	%https://github.com/cortex-lab/spikes
	%https://github.com/JorritMontijn/zetatest
	%
	%Created by Jorrit Montijn at the Cortical Structure and Function laboratory (KNAW-NIN)
	%
	%Rev:20220516 - v1.0b
	
	%% add subfolders
	strFullpath = mfilename('fullpath');
	strPath = fileparts(strFullpath);
	sDir=dir([strPath filesep '**' filesep]);
	%remove git folders
	sDir(contains({sDir.folder},[filesep '.git'])) = [];
	cellFolders = unique({sDir.folder});
	for intFolder=1:numel(cellFolders)
		addpath(cellFolders{intFolder});
	end
	
	%% load atlas
	sAtlasParams = PF_getAtlasIni();
	
	%select which atlas to use
	cellAtlases = {sAtlasParams.name};
	[intSelectAtlas,boolContinue] = listdlg('ListSize',[200 100],'Name','Atlas Selection','PromptString','Select Atlas:',...
		'SelectionMode','single','ListString',cellAtlases);
	if ~boolContinue,return;end
	
	%try using Acquipix variables
	try
		sRP = RP_populateStructure();
	catch
		sRP = struct;
	end
	
	%load atlas
	strAtlasName = sAtlasParams(intSelectAtlas).name;
	strPathVar = sAtlasParams(intSelectAtlas).pathvar;
	fLoader = sAtlasParams(intSelectAtlas).loader;
	fPrepper = sAtlasParams(intSelectAtlas).prepper;
	
	%get path
	if isfield(sRP,strPathVar) && isfolder(sRP.(strPathVar))
		strAtlasPath = sRP.(strPathVar);
	else
		strAtlasPath = PF_getIniVar(strPathVar);
	end
	
	%load atlas
	[tv,av,st] = feval(fLoader,strAtlasPath);
	if isempty(tv),return;end
	
	%prep atlas
	sAtlas = feval(fPrepper,tv,av,st);
	
	%% load coords file
	strDefaultPath = sRP.strProbeLocPath;
	sProbeCoords = PH_LoadProbeFile(sAtlas,strDefaultPath);
	
	%% load ephys
	%select file
	try
		strOldPath = cd(sRP.strEphysPath);
		strNewPath = sRP.strEphysPath;
	catch
		strOldPath = cd();
		strNewPath = strOldPath;
	end
	%open ephys data
	sClusters = PH_OpenEphys(strNewPath);
	
	% load or compute zeta if ephys file is not an Acquipix format
	if isempty(sClusters) || strcmp(sClusters.strZetaTit,'Contamination')
		%select
		sZetaResp = PH_OpenZeta(sClusters,strNewPath);
		
		%save
		if ~isempty(sZetaResp) && isfield(sZetaResp,'vecZetaP')
			sClusters.vecDepth = sZetaResp.vecDepth;
			sClusters.vecZeta = norminv(1-(sZetaResp.vecZetaP/2));
			sClusters.strZetaTit = 'ZETA (z-score)';
		end
	end
	
	% close message
	cd(strOldPath);
	
	%% run GUI
	[hMain,hAxAtlas,hAxAreas,hAxAreasPlot,hAxZeta,hAxClusters,hAxMua] = PH_GenGUI(sAtlas,sProbeCoords,sClusters);
end