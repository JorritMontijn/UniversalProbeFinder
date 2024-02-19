function sClusters = EL_PrepEphys_KS(strPathEphys,dblProbeLength)
	%EL_PrepEphys_KS Transform kilosort ephys data to ProbeFinder format
	%   sClusters = EL_PrepEphys_KS(strPathEphys,dblProbeLength)
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
	
	%load labels
	sClustTsv = loadClusterTsvs(strPathEphys);
	vecClustIdx = sClustTsv.cluster_id;
	cellUsedFields = {'cluster_id','KSLabel','ContamPct'};
	%for backward compatibility
	if isfield(sClustTsv,'KSLabel') && isfield(sClustTsv,'ContamPct')
		cellKilosortLabel = {sClustTsv.KSLabel};
		vecKilosortGood = contains(cellKilosortLabel,'good');
		vecKilosortContamination = cellfun(@str2double,{sClustTsv.ContamPct});
	else
		cellKilosortLabel = {};
		vecKilosortGood = [];
		vecKilosortContamination = [];
	end
	
	%get clusters with spikes
	vecAllSpikeTimes = sEphysData.st;
	vecAllSpikeClust = sEphysData.clu;
	[vecTemplateIdx,dummy,spike_templates_reidx] = unique(vecAllSpikeClust);
	
	%get probe length
	if ~exist('dblProbeLength','var') || isempty(dblProbeLength)
		dblProbeLength = max(sEphysData.ycoords); %should work, but kilosort might drop channels
	end
	
	%work-around using global in case the probe length is wrong
	global gForceProbeLength_PH_PrepEphys;
	if ~isempty(gForceProbeLength_PH_PrepEphys)
		dblProbeLength = gForceProbeLength_PH_PrepEphys;
	end
	
	%assign data
	error merge tsvs too! maybe better to mofidy sClusters and add sClust substructure to ensure same # of entries?
	
	%add extra data
	sClusters = struct;
	sClusters.dblProbeLength = dblProbeLength;
	sClusters.vecUseClusters = 1:numel(cellSpikes);
	sClusters.vecNormSpikeCounts = vecNormSpikeCounts;
	sClusters.vecDepth = vecTemplateDepths;
	sClusters.cellSpikes = cellSpikes;
	sClusters.OrigIdx = vecTemplateIdx;
	
	%add aditional cluster data
	sClusters = PH_MergeClusterData(sClusters,sClustTsv); %make sure assignment is to correct id!
	
	cellAllFields = fieldnames(sClustTsv);
	for intField=1:numel(cellAllFields)
		strField = cellAllFields{intField};
		if ~ismember(strField,cellUsedFields)
			cellData = {sClustTsv.(strField)};
			if isnumeric(cellData{1})
				cellData = cell2vec(cellData);
			end
			sClusters.(strField) = cellData;
		end
	end
	
	%assign ks data
	vecNormSpikeCounts = mat2gray(log10(accumarray(spike_templates_reidx,1)+1));
	vecContamination = nan(1,numel(vecTemplateIdx));
	vecClusterQuality = nan(1,numel(vecTemplateIdx));
	vecTemplateDepths = nan(1,numel(vecTemplateIdx));
	cellSpikes = cell(1,numel(vecTemplateIdx));
	for intCluster=1:numel(vecTemplateIdx)
		intClustIdx = vecTemplateIdx(intCluster);
		intTsvEntry = find(vecClustIdx==intClustIdx);
		if isempty(intTsvEntry)
			dblContamP = nan;
			dblGood = 0;
		else
			dblContamP = vecKilosortContamination(intTsvEntry);
			dblGood = vecKilosortGood(intTsvEntry);
		end
		vecContamination(intCluster) = dblContamP;
		vecClusterQuality(intCluster) = dblGood;
		vecTemplateDepths(intCluster) = dblProbeLength - sEphysData.templateDepths(vecTemplateIdx==intClustIdx);
		cellSpikes{intCluster} = vecAllSpikeTimes(vecAllSpikeClust==intClustIdx);
	end
	
	%get channel mapping
	try
		sEphysData.ChanIdx = readNPY(fullpath(strPathEphys,'channel_map.npy'));
		sEphysData.ChanPos = readNPY(fullpath(strPathEphys,'channel_positions.npy'));
		sClusters.ChanIdx = sEphysData.ChanIdx;
		sClusters.ChanPos = sEphysData.ChanPos;
	end
end