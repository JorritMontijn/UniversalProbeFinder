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
	
	%get contamination
	strContamFile = fullpath(strPathEphys, 'cluster_ContamPct.tsv');
	sCsv = loadcsv(strContamFile,char(9));
	sEphysData.cluster_id = sCsv.cluster_id;
	sEphysData.ContamP = sCsv.ContamPct;
	
	%labels
	strLabelFile = fullpath(strPathEphys, 'cluster_KSlabel.tsv');
	sCsv2 = loadcsv(strLabelFile,char(9));
	sEphysData.ClustQual = cellfun(@(x) strcmp(x,'mua') + strcmp(x,'good')*2,sCsv2.KSLabel) - 1;
	sEphysData.ClustQualLabel = sCsv2.KSLabel;
	
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
	if ~exist('dblProbeLength','var') || isempty(dblProbeLength)
		dblProbeLength = max(sEphysData.ycoords); %should work, but kilosort might drop channels
	end
	
	%work-around using global in case the probe length is wrong
	global gForceProbeLength_PH_PrepEphys;
	if ~isempty(gForceProbeLength_PH_PrepEphys)
		dblProbeLength = gForceProbeLength_PH_PrepEphys;
	end
	
	%get depths
	[vecTemplateIdx,dummy,spike_templates_reidx] = unique(sEphysData.spikeTemplates);
	vecUseClusters = vecTemplateIdx+1;
	vecNormSpikeCounts = mat2gray(log10(accumarray(spike_templates_reidx,1)+1));
	vecTemplateDepths = dblProbeLength-sEphysData.templateDepths(vecUseClusters);
	vecClusterQuality = sEphysData.ClustQual(vecUseClusters);
	vecContamination = sEphysData.ContamP(vecUseClusters);
	cellClustQualLabel = sEphysData.ClustQualLabel(vecUseClusters);
	
	%retrieve zeta
	try
		%find synthesis file
		error to do
		sLoad = load(fullpath(sFile.sSynthesis.folder,sFile.sSynthesis.name));
		sSynthData = sLoad.sSynthData;
		vecDepth = cell2vec({sSynthData.sCluster.Depth});
		vecZetaP = cellfun(@min,{sSynthData.sCluster.ZetaP});
		vecZeta = norminv(1-(vecZetaP/2));
		strZetaTit = 'Responsiveness ZETA (z-score)';
		cellSpikes = {sSynthData.sCluster.SpikeTimes};
	catch
		vecDepth = vecTemplateDepths;
		vecZeta = sEphysData.ContamP(vecUseClusters);
		strZetaTit = 'Contamination (%)';
		
		%build spikes per cluster
		vecAllSpikeTimes = sEphysData.st;
		vecAllSpikeClust = sEphysData.clu;
		intClustNum = numel(vecUseClusters);
		cellSpikes = cell(1,intClustNum);
		for intCluster=1:intClustNum
			intClustIdx = vecUseClusters(intCluster);
			cellSpikes{intCluster} = vecAllSpikeTimes(vecAllSpikeClust==intClustIdx);
		end
	end
	
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
	sClusters.vecUseClusters = vecUseClusters;
	sClusters.vecNormSpikeCounts = vecNormSpikeCounts;
	sClusters.vecDepth = vecDepth;
	sClusters.vecZeta = vecZeta;
	sClusters.strZetaTit = strZetaTit;
	sClusters.cellSpikes = cellSpikes;
	sClusters.ClustQual = vecClusterQuality;
	sClusters.ClustQualLabel = cellClustQualLabel;
	sClusters.ContamP = vecContamination;
	%get channel mapping
	if isfield(sEphysData,'ChanIdx') && isfield(sEphysData,'ChanPos')
		sClusters.ChanIdx = sEphysData.ChanIdx;
		sClusters.ChanPos = sEphysData.ChanPos;
	end
end