function sClusters = EL_PrepEphys_AS(strPathEphys,dblProbeLength)
	%EL_PrepEphys_AS Transform Acquipix synthesis ephys data to ProbeFinder format
	%   sClusters = EL_PrepEphys_AS(strPathEphys,dblProbeLength)
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
	
	%load synthesis data
	sDir = dir(fullpath(strPathEphys,'*Synthesis.mat'));
	if numel(sDir) > 1
		%ask which one
		[intFile,boolContinue] = listdlg('ListSize',[200 100],'Name','Load SpikeGLX','PromptString','Select file to load:',...
			'SelectionMode','single','ListString',{sDir.name});
		if ~boolContinue,return;end
	else
		intFile=1;
	end
	sLoad = load(fullpath(strPathEphys,sDir(intFile).name));
	sSynthData = sLoad.sSynthData;
	
	%% prep ephys
	%check inputs
	sClusters = [];
	if ~exist('dblProbeLength','var') || isempty(dblProbeLength)
		dblProbeLength = 3840;
	end
	
	%work-around using global in case the probe length is wrong
	global gForceProbeLength_PH_PrepEphys;
	if ~isempty(gForceProbeLength_PH_PrepEphys)
		dblProbeLength = gForceProbeLength_PH_PrepEphys;
	end
	
	
	%set variables
	cellLabels = {'mua','good'};
	cellSpikes = {sSynthData.sCluster.SpikeTimes};
	vecDepth = cell2vec({sSynthData.sCluster.Depth});
	vecZeta = norminv(1-(cellfun(@min,{sSynthData.sCluster.ZetaP})/2));
	strZetaTit = 'Responsiveness ZETA (z-score)';
	vecClustQual = val2idx(cell2vec({sSynthData.sCluster.KilosortGood}));
	if isfield(sSynthData.sCluster,'KilosortLabel')
		cellClustQualLabel = {sSynthData.sCluster.KilosortLabel};
	else
		cellClustQualLabel = cellLabels(vecClustQual);
	end
	vecContamination = cell2vec({sSynthData.sCluster.Contamination});
	
	%check whether to use left/right or spiking rate
	if isfield(sSynthData.sCluster,'dPrimeLR') && ~all(cellfun(@(x) all(isnan(x)),{sSynthData.sCluster.dPrimeLR}))
		vecNormSpikeCounts = cellfun(@nanmean,{sSynthData.sCluster.dPrimeLR});
		strRateTit = 'dprime LR';
	else
		vecNormSpikeCounts = mat2gray(log10(cellfun(@numel,cellSpikes)+1));
		strRateTit = 'Norm. log(N+1) spikes';
	end
	
	%add extra data
	sClusters = struct;
	sClusters.dblProbeLength = dblProbeLength;
	sClusters.vecUseClusters = 1:numel(sSynthData.sCluster);
	sClusters.vecNormSpikeCounts = vecNormSpikeCounts;
	sClusters.strRateTit = strRateTit;
	sClusters.vecDepth = vecDepth;
	sClusters.vecZeta = vecZeta;
	sClusters.strZetaTit = strZetaTit;
	sClusters.cellSpikes = cellSpikes;
	sClusters.ClustQual =  vecClustQual;
	sClusters.ClustQualLabel = cellClustQualLabel;
	sClusters.ContamP = vecContamination;
	%add aditional cluster data
	cellAllFields = sSynthData.sCluster;
	cellUsedFields = {'KilosortGood','KilosortLabel','Contamination','ZetaP','Depth','SpikeTimes'};
	for intField=1:numel(cellAllFields)
		strField = cellAllFields{intField};
		if ~ismember(strField,cellUsedFields)
			cellData = {sSynthData.sCluster.(strField)};
			if isnumeric(cellData{1})
				cellData = cell2vec(cellData);
			end
			sClusters.(strField) = cellData;
		end
	end
	
	%get channel mapping
	if isfield(sSynthData,'ChanIdx') && isfield(sSynthData,'ChanPos')
		sClusters.ChanIdx = sSynthData.ChanIdx;
		sClusters.ChanPos = sSynthData.ChanPos;
	end
end