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
	[dummy1, dummy2,cellGroup]=tsvread(fullpath(strPathEphys, 'cluster_group.tsv'));
	vecClustIdx_KSG = cellfun(@str2double,cellGroup(2:end,1));
	vecKilosortGood = contains(cellGroup(2:end,2),'good');
	
	%load contam
	[dummy, dummy,cellDataContam]=tsvread(fullpath(strPathEphys, 'cluster_ContamPct.tsv'));
	vecClustIdx_KSC = cellfun(@str2double,cellDataContam(2:end,1));
	vecKilosortContaminationSource = cellfun(@str2double,cellDataContam(2:end,2));
	%fill array
	vecKilosortContamination = nan(size(vecKilosortGood));
	for intCluster=1:numel(vecClustIdx_KSG)
		intClustIdx = vecClustIdx_KSG(intCluster);
		intContamEntry = find(vecClustIdx_KSC==intClustIdx);
		if ~isempty(intContamEntry)
			vecKilosortContamination(intCluster) = vecKilosortContaminationSource(intContamEntry);
		end
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
	vecLabels = [0 1 2 3 4];
	cellLabels = {'noise','mua','good','unsorted'};
	vecNormSpikeCounts = mat2gray(log10(accumarray(spike_templates_reidx,1)+1));
	vecContamination = nan(1,numel(vecTemplateIdx));
	vecClusterQuality = nan(1,numel(vecTemplateIdx));
	vecTemplateDepths = nan(1,numel(vecTemplateIdx));
	cellSpikes = cell(1,numel(vecTemplateIdx));
	for intCluster=1:numel(vecTemplateIdx)
		intClustIdx = vecTemplateIdx(intCluster);
		intContamEntry = find(vecClustIdx_KSG==intClustIdx);
		if isempty(intContamEntry)
			dblContamP = nan;
			dblGood = 0;
		else
			dblContamP = vecKilosortContamination(intContamEntry);
			dblGood = vecKilosortGood(intContamEntry);
		end
		vecContamination(intCluster) = dblContamP;
		vecClusterQuality(intCluster) = dblGood;
		vecTemplateDepths(intCluster) = dblProbeLength - sEphysData.templateDepths(vecTemplateIdx==intClustIdx);
		cellSpikes{intCluster} = vecAllSpikeTimes(vecAllSpikeClust==intClustIdx);
	end
	cellClustQualLabel = cellLabels(vecClusterQuality+1);
	
	%get channel mapping
	try
		sEphysData.ChanIdx = readNPY(fullpath(strPathEphys,'channel_map.npy'));
		sEphysData.ChanPos = readNPY(fullpath(strPathEphys,'channel_positions.npy'));
	catch
	end
	
	%% prep ephys
	%check inputs
	sClusters = [];
	if isempty(sEphysData),return;end
	
	%add depth/contam
	vecDepth = vecTemplateDepths;
	vecZeta = vecContamination;
	strZetaTit = 'Contamination (%)';
	
	%check if depth is the same
	dblDepthR = corr(vecDepth(:),vecTemplateDepths(:));
	if dblDepthR > -0.95 && dblDepthR < 0.95
		error([mfilename ':DepthInconsistency'],'Depth information from templates and synthesis data do not match! Pearson r=%.3f',dblDepthR);
	elseif dblDepthR < -0.95
		warndlg('Depth information from templates and synthesis data are mirrored, please check the source data','Depths mirrored');
	end
	
	%add extra data
	sClusters = struct;
	sClusters.dblProbeLength = dblProbeLength;
	sClusters.vecUseClusters = 1:numel(cellSpikes);
	sClusters.vecNormSpikeCounts = vecNormSpikeCounts;
	sClusters.vecDepth = vecDepth;
	sClusters.vecZeta = vecZeta;
	sClusters.strZetaTit = strZetaTit;
	sClusters.cellSpikes = cellSpikes;
	sClusters.ClustQual = vecClusterQuality;
	sClusters.ClustQualLabel = cellClustQualLabel;
	sClusters.ContamP = vecContamination;
	sClusters.OrigIdx = vecTemplateIdx;
	%get channel mapping
	if isfield(sEphysData,'ChanIdx') && isfield(sEphysData,'ChanPos')
		sClusters.ChanIdx = sEphysData.ChanIdx;
		sClusters.ChanPos = sEphysData.ChanPos;
	end
end