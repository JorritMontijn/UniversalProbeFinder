function sClusters = EL_PrepEphys_KS(strPathEphys,dblProbeLength)
	%EL_PrepEphys_KS Transform kilosort ephys data to ProbeFinder format
	%   sClusters = EL_PrepEphys_KS(strPathEphys,dblProbeLength)
	%
	%ProbeFinder output format for structure sClusters is:
	%sClusters.ProbeLength: length of probe in microns;
	%sClusters.UseClusters: vector of entries to use
	%sClusters.CoordsX: channel positions
	%sClusters.CoordsY: channel positions
	%sClusters.CoordsZ: channel positions
	%sClusters.ChanIdx: channel indices;
	%sClusters.ChanPos: channel positions
	%sClusters.Clust(i).cluster_id: cluster ID
	%sClusters.Clust(i).OrigIdx: copy of cluster_id
	%sClusters.Clust(i).NormSpikeCount: log10(SpikeCount)
	%sClusters.Clust(i).Depth: depth
	%sClusters.Clust(i).Zeta: responsiveness
	%sClusters.Clust(i).SpikeTimes: spike times
	%sClusters.Clust(i).QualLabel: cluster quality name
	%sClusters.Clust(i).ContamP: estimated cluster contamination
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
	if ~exist('dblProbeLength','var') || isempty(dblProbeLength)
		dblProbeLength = max(sEphysData.ycoords); %should work, but kilosort might drop channels
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
		xcoords = zeros(1,intClustNum);
	end
	if isfield(sEphysData,'ycoords')
		ycoords = sEphysData.ycoords;
	else
		ycoords = zeros(1,intClustNum);
	end
	if isfield(sEphysData,'zcoords')
		zcoords = sEphysData.zcoords;
	else
		zcoords = zeros(1,intClustNum);
	end
	
	%add non-cluster based data
	sClusters = struct;
	sClusters.ProbeLength = dblProbeLength;
	sClusters.UseClusters = 1:numel(vecTemplateIdx);
	sClusters.CoordsX = xcoords;
	sClusters.CoordsY = ycoords;
	sClusters.CoordsZ = zcoords;
	sClusters.ChanIdx = sEphysData.ChanIdx;
	sClusters.ChanPos = sEphysData.ChanPos;
	
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
		sClustKS(intCluster).Depth = dblProbeLength - sEphysData.templateDepths(vecTemplateIdx==intClustIdx);
		sClustKS(intCluster).SpikeTimes = vecAllSpikeTimes(vecAllSpikeClust==intClustIdx);
		sClustKS(intCluster).NormSpikeCount = log10(numel(sClustKS(intCluster).SpikeTimes));
	end
	
	%merge cluster data
	sClusters.Clust = PH_MergeClusterData(sClustKS,sClustTsv);
end