function sClusters = EL_PrepEphys_SG(strPathEphys,dblProbeLength)
	%EL_PrepEphys_SG Transform SpikeGLX ephys data to ProbeFinder format
	%   sClusters = EL_PrepEphys_SG(strPathEphys,dblProbeLength)
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
	if ~exist('dblProbeLength','var') || isempty(dblProbeLength)
		dblProbeLength = 3840; %default, for now there is no channel map
	end
	
	%load imec data
	sDir = dir(fullpath(strPathEphys,'*.imec*.ap.meta'));
	if numel(sDir) > 1
		%ask which one
		[intFile,boolContinue] = listdlg('ListSize',[200 100],'Name','Load SpikeGLX','PromptString','Select file to load:',...
			'SelectionMode','single','ListString',{sDir.name});
		if ~boolContinue,return;end
	else
		intFile=1;
	end
	strImecMeta = sDir(intFile).name;
	strImecBin = [strImecMeta(1:(end-4)) 'bin'];
	sImecMeta = DP_ReadMeta(fullpath(strPathEphys,strImecMeta));
	
	%detect spikes
	strFilename = fullpath(strPathEphys,strImecBin);
	[vecSpikeCh,vecSpikeT,intTotT] = DP_DetectSpikesInBinaryFile(strFilename);
	vecSpikeSecs = double(gather(vecSpikeT))/str2double(sImecMeta.imSampRate) + ...
		str2double(sImecMeta.firstSample)/str2double(sImecMeta.imSampRate); %conversion to seconds
	%remove non-AP channels
	vecChansApLfSy = str2double(strsplit(sImecMeta.acqApLfSy,','));
	intChansAp = vecChansApLfSy(1);
	indRemEntries = vecSpikeCh>intChansAp;
	vecSpikeCh(indRemEntries) = [];
	vecSpikeSecs(indRemEntries) = [];
	
	%calculate sCluster variables
	cellSpikes = cell(1,intChansAp);
	for intCh=1:intChansAp
		cellSpikes{intCh} = vecSpikeSecs(vecSpikeCh==intCh);
	end
	vecDepth = dblProbeLength-linspace(0,dblProbeLength,intChansAp);
	vecUseClusters = 1:intChansAp;
	vecNormSpikeCounts = mat2gray(log10(cellfun(@numel,cellSpikes)+1));
	vecContamination = 100*ones(size(vecNormSpikeCounts));
	vecZeta = vecContamination;
	strZetaTit = 'Contamination (%)';
	vecClusterQuality = zeros(size(vecNormSpikeCounts));
	cellClustQualLabel = cellfill('mua',size(vecClusterQuality));

	%% prep ephys
	%work-around using global in case the probe length is wrong
	global gForceProbeLength_PH_PrepEphys;
	if ~isempty(gForceProbeLength_PH_PrepEphys)
		dblProbeLength = gForceProbeLength_PH_PrepEphys;
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

	%save file
	[startIndex,endIndex] = regexp(strImecBin,'[.]imec.*[.]ap[.]bi+n');
	strName = strImecBin(1:(startIndex-1));
	strClusterOut =  fullpath(strPathEphys,strcat(strName,'_UPF_Cluster.mat'));
	save(strClusterOut,'sClusters');
end