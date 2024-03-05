function sClusters = EL_PrepEphys_SG(strPathEphys,dblProbeLength)
	%EL_PrepEphys_SG Transform SpikeGLX ephys data to ProbeFinder format
	%   sClusters = EL_PrepEphys_SG(strPathEphys,dblProbeLength)
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
	
	%check which files are actually in this folder
	sDirAp = dir(fullpath(strPathEphys,'*.imec*.ap.meta'));
	if numel(sDirAp) == 0
		%is it nidq? then ap is in subfolders
		sDirNidq = dir(fullpath(strPathEphys,'*.nidq*'));
		if numel(sDirNidq) > 0
			%check subfolders
			sDirAp = dir(fullpath(strPathEphys,'**\*.imec*.ap.meta'));
		end
	end
	
	%load imec data
	if numel(sDirAp) == 0
		%none found
		errordlg('Did not find any SpikeGLX AP files. Make sure you selected the correct folder and that it contains files named *.imec*.ap.meta and *.imec*.ap.bin','File not found');
		sClusters = [];
		return;
	elseif numel(sDirAp) > 1
		%ask which one
		[intFile,boolContinue] = listdlg('ListSize',[200 100],'Name','Load SpikeGLX','PromptString','Select file to load:',...
			'SelectionMode','single','ListString',{sDirAp.name});
		if ~boolContinue,return;end
	else
		%there can be only one!
		intFile=1;
	end
	strImecMeta = sDirAp(intFile).name;
	strImecBin = [strImecMeta(1:(end-4)) 'bin'];
	sImecMeta = DP_ReadMeta(fullpath(strPathEphys,strImecMeta));
	sChanMap = DP_GetChanMap(sImecMeta);
	
	%update probe length using channel map
	if ~exist('dblProbeLength','var') || isempty(dblProbeLength)
		dblProbeLength = range(sChanMap.D); %default
	end
	
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
	vecDepth = dblProbeLength-sChanMap.D;
	vecUseClusters = sChanMap.U;
	vecNormSpikeCounts = mat2gray(log10(cellfun(@numel,cellSpikes)+1));
	cellClustQualLabel = cellfill('mua',size(vecNormSpikeCounts));

	%% prep ephys
	%work-around using global in case the probe length is wrong
	global gForceProbeLength_PH_PrepEphys;
	if ~isempty(gForceProbeLength_PH_PrepEphys)
		dblProbeLength = gForceProbeLength_PH_PrepEphys;
	end
	
	%add data
	sClusters = struct;
	sClusters.ProbeLength = dblProbeLength;
	sClusters.UseClusters = vecUseClusters;
	sClusters.CoordsS = sChanMap.S;
	sClusters.CoordsX = sChanMap.X;
	sClusters.CoordsD = sChanMap.D;
	sClusters.ChanIdx = 1:intChansAp;
	sClusters.ChanPos = cat(2,sClusters.CoordsX,sClusters.CoordsD);
	sClusters.ChanMap = sChanMap;
	
	%add clusters
	sClusters.Clust(intChansAp).cluster_id = intChansAp; %pre-allocate
	for i=1:intChansAp
		sClusters.Clust(i).cluster_id = i;
		sClusters.Clust(i).OrigIdx = i;
		sClusters.Clust(i).NormSpikeCount = vecNormSpikeCounts(i);
		sClusters.Clust(i).Shank = sChanMap.S(i);
		sClusters.Clust(i).Depth = vecDepth(i);
		sClusters.Clust(i).SpikeTimes = vecNormSpikeCounts(i);
		sClusters.Clust(i).ClustLabel = cellClustQualLabel{i};
	end
	
	%save file
	[startIndex,endIndex] = regexp(strImecBin,'[.]imec.*[.]ap[.]bi+n');
	strName = strImecBin(1:(startIndex-1));
	strClusterOut =  fullpath(strPathEphys,strcat(strName,'_UPF_Cluster.mat'));
	save(strClusterOut,'sClusters');
end