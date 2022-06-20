function sClusters = EL_PrepEphys_NC(strPathEphys,dblProbeLength)
	%EL_PrepEphys_NC Read Native Cluster format for ProbeFinder
	%   sClusters = EL_PrepEphys_NC(strPathEphys,dblProbeLength)
	%
	%ProbeFinder output format for structure sClusters is:
	%sClusters.dblProbeLength: length of probe in microns;
	%sClusters.vecNormSpikeCounts: log10(spikeCount)
	%sClusters.vecDepth: depth of cluster in microns from top recording channel
	%sClusters.vecZeta: responsiveness z-score
	%sClusters.strZetaTit: title for responsiveness plot
	%sClusters.cellSpikes: cell array with spike times per cluster
	%sClusters.ClustQual: vector of cluster quality values
	%sClusters.ClustQualLabel: cell array of cluster quality names
	%sClusters.ContamP: estimated cluster contamination
	
	%% load ephys
	%get location
	if isempty(strPathEphys) || strPathEphys(1) == 0
		sClusters = [];
		return;
	end
	
	%load native sCluster data
	sDir = dir(fullpath(strPathEphys,'*UPF_Cluster.mat'));
	if numel(sDir) > 1
		%ask which one
		[intFile,boolContinue] = listdlg('ListSize',[200 100],'Name','Load native sCluster data','PromptString','Select file to load:',...
			'SelectionMode','single','ListString',{sDir.name});
		if ~boolContinue,return;end
	else
		intFile=1;
	end
	strClusterFile = fullpath(strPathEphys,sDir(intFile).name);
	sLoad = load(strClusterFile);
	sClusters = sLoad.sClusters;
		
	%% prep ephys
	if exist('dblProbeLength','var') && ~isempty(dblProbeLength)
		sClusters.dblProbeLength = dblProbeLength;
	end
	%check all fields actually exist
	sClusters.dblProbeLength = sClusters.dblProbeLength;
	sClusters.vecUseClusters = sClusters.vecUseClusters;
	sClusters.vecNormSpikeCounts = sClusters.vecNormSpikeCounts;
	sClusters.vecDepth = sClusters.vecDepth;
	sClusters.vecZeta = sClusters.vecZeta;
	sClusters.strZetaTit = sClusters.strZetaTit;
	sClusters.cellSpikes = sClusters.cellSpikes;
	sClusters.ClustQual = sClusters.ClustQual;
	sClusters.ClustQualLabel = sClusters.ClustQualLabel;
	if numel(sClusters.ClustQualLabel) == 1
		sClusters.ClustQualLabel = cellfill(sClusters.ClustQualLabel{1},size(sClusters.vecDepth));
	end
	sClusters.ContamP = sClusters.ContamP;
	%get channel mapping
	if isfield(sClusters,'ChanIdx') && isfield(sClusters,'ChanPos')
		sClusters.ChanIdx = sClusters.ChanIdx;
		sClusters.ChanPos = sClusters.ChanPos;
	end
end