function sEphysData = PH_LoadEphys(sFile)
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
	sEphysData.ContamP = sCsv.ContamP;
	
end