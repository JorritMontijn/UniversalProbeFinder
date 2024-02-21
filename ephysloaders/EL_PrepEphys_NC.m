function sClusters = EL_PrepEphys_NC(strPathEphys,dblProbeLength)
	%EL_PrepEphys_NC Read Native Cluster format for ProbeFinder
	%   sClusters = EL_PrepEphys_NC(strPathEphys,dblProbeLength)
	%
	%ProbeFinder output format for structure sClusters is:
	%sClusters.ProbeLength: length of probe in microns;
	%sClusters.UseClusters: vector of entries to use
	%sClusters.CoordsS: shank #
	%sClusters.CoordsX: position along width
	%sClusters.CoordsD: depth
	%sClusters.ChanIdx: channel indices;
	%sClusters.ChanPos: channel positions
	%sClusters.ChanMap: full channel map structure
	%sClusters.Clust(i).cluster_id: cluster ID (origin: .tsv)
	%sClusters.Clust(i).OrigIdx: copy of cluster_id (origin: ephys)
	%sClusters.Clust(i).NormSpikeCount: log10(SpikeCount)
	%sClusters.Clust(i).Shank: shank #
	%sClusters.Clust(i).Depth: depth
	%sClusters.Clust(i).Zeta: responsiveness
	%sClusters.Clust(i).SpikeTimes: spike times
	%sClusters.Clust(i).x: any other variable present in a .tsv file
	
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
		sClusters.ProbeLength = dblProbeLength;
	end
	
	%check which version
	cellOldFields = {'dblProbeLength','vecUseClusters','vecNormSpikeCounts','vecDepth','cellSpikes'};
	cellNewFields = {'Clust','ProbeLength'};
	cellLoadFields = fieldnames(sClusters);
	if all(ismember(cellNewFields,cellLoadFields))
		%perfect
	elseif all(ismember(cellOldFields,cellLoadFields))
		error([mfilename ':FileTypeOsolete'],'Input is an obsolete UPF data file of version < 1.1');
	else
		error([mfilename ':FileTypeNotRecognized'],'Input is not a UPF data file');
	end
end