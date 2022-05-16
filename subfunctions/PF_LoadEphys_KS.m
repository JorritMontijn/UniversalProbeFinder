function sEphysData = PF_LoadEphys_KS(sFile)
	%PF_LoadEphys_KS Load Kilosort ephys data
	
	%get location
	strPathKS = sFile.sClustered.folder;
	if isempty(strPathKS) || strPathKS(1) == 0
		sEphysData = [];
		return;
	end
	
	%load data
	sEphysData = loadKSdir(strPathKS);

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
	strContamFile = fullpath(strPathKS, 'cluster_ContamPct.tsv');
	sCsv = loadcsv(strContamFile,char(9));
	sEphysData.cluster_id = sCsv.cluster_id;
	sEphysData.ContamP = sCsv.ContamPct;
	
	%labels
	strLabelFile = fullpath(strPathKS, 'cluster_KSlabel.tsv');
	sCsv2 = loadcsv(strLabelFile,char(9));
	sEphysData.ClustQual = cellfun(@(x) strcmp(x,'mua') + strcmp(x,'good')*2,sCsv2.KSLabel) - 1;
	sEphysData.ClustQualLabel = sCsv2.KSLabel;
	
	%get channel mapping
	try
		sEphysData.ChanIdx = readNPY(fullpath(sFile.sClustered.folder,'channel_map.npy'));
		sEphysData.ChanPos = readNPY(fullpath(sFile.sClustered.folder,'channel_positions.npy'));
	catch
	end
end