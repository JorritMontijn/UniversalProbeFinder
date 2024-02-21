function sClusters = EL_PrepEphys_KS(strPathEphys,dblProbeLength)
	%EL_PrepEphys_KS Transform kilosort ephys data to ProbeFinder format
	%   sClusters = EL_PrepEphys_KS(strPathEphys,dblProbeLength)
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
	
	%load tsv labels
	sClustTsv = loadClusterTsvs(strPathEphys);
	
	%load data
	sEphysData = loadKSdir(strPathEphys);

	%get cluster data
	[spikeAmps, spikeDepths, templateDepths, tempAmps, tempsUnW, templateDuration, waveforms] = templatePositionsAmplitudes(sEphysData.temps, sEphysData.winv, sEphysData.ycoords, sEphysData.spikeTemplates, sEphysData.tempScalingAmps);
	sEphysData.spikeAmps = spikeAmps;
	sEphysData.spikeDepths = spikeDepths;
	sEphysData.templateDepths = templateDepths;
	sEphysData.tempAmps = tempAmps;
	sEphysData.tempsUnW = tempsUnW;
	sEphysData.templateDuration = templateDuration;
	sEphysData.waveforms = waveforms;
	
	%get probe length
	sChanMap = [];
	if ~exist('dblProbeLength','var') || isempty(dblProbeLength)
		%try to find the imec meta file
		dblProbeLength = [];
		sMetaFiles = dir(fullpath(strPathEphys,'*ap.meta'));
		if isempty(sMetaFiles)
			cellPath = strsplit(strPathEphys,filesep);
			if numel(cellPath) > 1
				strRoot = strjoin(cellPath(1:(end-1)),filesep);
				sMetaFiles = dir(fullpath(strRoot,'*ap.meta'));
			end
		end
		if numel(sMetaFiles) > 0
			[intFile,boolContinue] = listdlg('ListSize',[300 100],'Name','Select file',...
				'PromptString','Select meta file belonging to this recording (or cancel if none)',...
				'SelectionMode','single','ListString',{sMetaFiles.name});
			
			if boolContinue && ~isempty(intFile)
				strMetaFile = fullpath(sMetaFiles(intFile).folder,sMetaFiles(intFile).name);
				sChanMap = DP_GetChanMap(strMetaFile);
				dblProbeLength = range(sChanMap.D);
			end
		end
		if isempty(dblProbeLength)
			dblProbeLength = range(sEphysData.ycoords); %should work, but kilosort might drop channels
		end
	end
	
	%work-around using global in case the probe length is wrong
	global gForceProbeLength_PH_PrepEphys;
	if ~isempty(gForceProbeLength_PH_PrepEphys)
		dblProbeLength = gForceProbeLength_PH_PrepEphys;
	end
	
	%get clusters with spikes
	vecAllSpikeTimes = sEphysData.st;
	vecAllSpikeClust = sEphysData.clu;
	[vecTemplateIdx,dummy,spike_templates_reidx] = unique(vecAllSpikeClust);
	intClustNum = numel(vecTemplateIdx);
	
	%get channel mapping
	try
		sEphysData.ChanIdx = readNPY(fullpath(strPathEphys,'channel_map.npy'));
		sEphysData.ChanPos = readNPY(fullpath(strPathEphys,'channel_positions.npy'));
	catch
		sEphysData.ChanIdx = [];
		sEphysData.ChanPos = [];
	end
	if isfield(sEphysData,'xcoords')
		xcoords = sEphysData.xcoords;
	else
		xcoords = [];
	end
	if isfield(sEphysData,'ycoords')
		ycoords = sEphysData.ycoords;
	else
		ycoords = [];
	end
	if isfield(sChanMap,'S')
		scoords = sChanMap.S(sChanMap.U==1);
	else
		scoords = [];
	end
	
	%add non-cluster based data
	sClusters = struct;
	sClusters.ProbeLength = dblProbeLength;
	sClusters.UseClusters = 1:numel(vecTemplateIdx);
	sClusters.CoordsS = scoords;
	sClusters.CoordsX = xcoords;
	sClusters.CoordsD = ycoords;
	sClusters.ChanIdx = sEphysData.ChanIdx;
	sClusters.ChanPos = sEphysData.ChanPos;
	sClusters.ChanMap = sChanMap;
	
	%assign KS data
	sClustKS = struct;
	sClustKS(intClustNum).OrigIdx = [];
	sClustKS(intClustNum).Depth = [];
	sClustKS(intClustNum).SpikeTimes = [];
	sClustKS(intClustNum).NormSpikeCount = [];
	for intCluster=1:numel(vecTemplateIdx)
		intClustIdx = vecTemplateIdx(intCluster);
		
		%assign
		sClustKS(intCluster).OrigIdx = intClustIdx;
		sClustKS(intCluster).Shank = 0; %kilosort throws away shank info
		sClustKS(intCluster).Depth = dblProbeLength - sEphysData.templateDepths(vecTemplateIdx==intClustIdx);
		sClustKS(intCluster).SpikeTimes = vecAllSpikeTimes(vecAllSpikeClust==intClustIdx);
		sClustKS(intCluster).NormSpikeCount = log10(numel(sClustKS(intCluster).SpikeTimes));
	end
	
	%merge cluster data
	sClusters.Clust = PH_MergeClusterData(sClustKS,sClustTsv);
end