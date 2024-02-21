function sClusters = EL_PrepEphys_AS(strPathEphys,dblProbeLength)
	%EL_PrepEphys_AS Transform Acquipix synthesis ephys data to ProbeFinder format
	%   sClusters = EL_PrepEphys_AS(strPathEphys,dblProbeLength)
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
	
	%load synthesis data
	sDir = dir(fullpath(strPathEphys,'*Synthesis.mat'));
	intFile = 1;
	if numel(sDir) > 1
		%ask which one
		[intFile,boolContinue] = listdlg('ListSize',[200 100],'Name','Load Acquipix data','PromptString','Select file to load:',...
			'SelectionMode','single','ListString',{sDir.name});
		if ~boolContinue,return;end
	elseif isempty(sDir)
		sClusters = [];
		return;
	end
	sLoad = load(fullpath(strPathEphys,sDir(intFile).name));
	sSynthData = sLoad.sSynthData;
	
	%% prep ephys
	%get channel map
	sChanMap = DP_GetChanMap(sSynthData.sMetaAP);
	
	%check inputs
	if ~exist('dblProbeLength','var') || isempty(dblProbeLength)
		dblProbeLength = range(sChanMap.D);
	end
	
	%assign
	sClusters = struct;
	sClusters.ProbeLength = dblProbeLength;%length of probe in microns;
	sClusters.UseClusters = 1:numel(sSynthData.sCluster);%vector of entries to use
	sClusters.CoordsS = sChanMap.S;%channel positions
	sClusters.CoordsX = sChanMap.X;%channel positions
	sClusters.CoordsD = sChanMap.D;%channel positions
	sClusters.ChanIdx = 1:numel(sChanMap.D);
	sClusters.ChanPos = cat(2,sClusters.CoordsX,sClusters.CoordsD);
	sClusters.ChanMap = sChanMap;%channel positions
	
	%work-around using global in case the probe length is wrong
	global gForceProbeLength_PH_PrepEphys;
	if ~isempty(gForceProbeLength_PH_PrepEphys)
		sClusters.ProbeLength = gForceProbeLength_PH_PrepEphys;
	end
	
	%add cluster data
	sClusters.Clust = sSynthData.sCluster;
	for i=1:numel(sClusters.Clust)
		sClusters.Clust(i).cluster_id = sClusters.Clust(i).IdxClust;
		sClusters.Clust(i).OrigIdx = sClusters.Clust(i).IdxClust;
		sClusters.Clust(i).NormSpikeCount = log10(numel(sClusters.Clust(i).SpikeTimes));
		%transform p to z
		if isfield(sClusters.Clust,'ZetaP')
			sClusters.Clust(i).Zeta = -norminv(min(sClusters.Clust(i).ZetaP)/2);
		end
		if isfield(sClusters.Clust,'MeanP')
			sClusters.Clust(i).Mean = -norminv(min(sClusters.Clust(i).MeanP)/2);
		end
	end
	
	%remove fields
	cellRemFields = {'Exp','Rec','SubjectType','Subject', 'Date','Cluster','IdxClust','Waveform','ZetaP','MeanP'};
	sClusters.Clust = rmfield(sClusters.Clust,cellRemFields);
	
	%get channel mapping
	if isfield(sSynthData,'ChanIdx') && isfield(sSynthData,'ChanPos')
		sClusters.ChanIdx = sSynthData.ChanIdx;
		sClusters.ChanPos = sSynthData.ChanPos;
	end
	
	%merge cluster data
	ClustDummy = struct;
	ClustDummy.cluster_id = nan;
	ClustDummy(:) = [];
	sClusters.Clust = PH_MergeClusterData(sClusters.Clust,ClustDummy,true);
end