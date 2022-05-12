%align probe to atlas
%change name to NeuroFinder in separate repo

%this program uses several functions from other repositories, including functions from:
%https://github.com/petersaj/AP_histology
%https://github.com/JorritMontijn/Acquipix
%https://github.com/JorritMontijn/GeneralAnalysis 
%https://github.com/kwikteam/npy-matlab
%https://github.com/cortex-lab/spikes
%https://github.com/JorritMontijn/zetatest

%% ask what to load
%clear all;
%Universal Probe Finder Using Neurophysiology
%UPFUN

%Multi Species Probe Aligner
function ProbeFinder
	%% load atlas
	global boolIgnoreNeuroFinderRenderer;
	boolIgnoreNeuroFinderRenderer = false;
	intUseMouseOrRat = 2;
	
	%try using Acquipix variables
	try
		sRP = RP_populateStructure();
	catch
		sRP = struct;
	end
	
	%load atlas
	if intUseMouseOrRat == 1
		%get path
		if isfield(sRP,'strAllenCCFPath')
			strAllenCCFPath = sRP.strAllenCCFPath;
		else
			strAllenCCFPath = PF_getIniVar('strAllenCCFPath');
		end
		
		%load ABA
		if (~exist('tv','var') || isempty(tv)) || (~exist('av','var') || isempty(av)) || (~exist('st','var') || isempty(st))...
				|| ~all(size(av) == [1320 800 1140]) || (~exist('strAtlasType','var') || ~strcmpi(strAtlasType,'Allen-CCF-Mouse'))
			[tv,av,st] = RP_LoadABA(strAllenCCFPath);
			if isempty(tv),return;end
		end
		
		%prep ABA
		sAtlas = RP_PrepABA(tv,av,st);
	else
		%get path
		if isfield(sRP,'strSpragueDawleyPath')
			strSpragueDawleyPath = sRP.strSpragueDawleyPath;
		else
			strSpragueDawleyPath = PF_getIniVar('strSpragueDawleyPath');
		end
		
		%load RATlas
		if (~exist('tv','var') || isempty(tv)) || (~exist('av','var') || isempty(av)) || (~exist('st','var') || isempty(st))...
				|| ~all(size(av) == [512 1024 512]) || (~exist('strAtlasType','var') || ~strcmpi(strAtlasType,'Sprague-Dawley-Rat'))
			[tv,av,st] = RP_LoadSDA(strSpragueDawleyPath);
			if isempty(tv),return;end
		end
		
		%prep SDA
		sAtlas = RP_PrepSDA(tv,av,st);
	end
	%save raw atlas to base workspace so it doesn't need to keep loading it
	assignin('base','tv',tv);
	assignin('base','av',av);
	assignin('base','st',st);
	assignin('base','strAtlasType',sAtlas.Type);
	
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