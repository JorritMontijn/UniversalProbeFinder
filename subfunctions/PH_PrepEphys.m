function sClusters = PH_PrepEphys(sFile,sEphysData,dblProbeLength)
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
	
	%retrieve zeta
	try
		sLoad = load(fullpath(sFile.sSynthesis.folder,sFile.sSynthesis.name));
		sSynthData = sLoad.sSynthData;
		vecDepth = cell2vec({sSynthData.sCluster.Depth});
		vecZetaP = cellfun(@min,{sSynthData.sCluster.ZetaP});
		vecZeta = norminv(1-(vecZetaP/2));
		strZetaTit = 'ZETA (z-score)';
		cellSpikes = {sSynthData.sCluster.SpikeTimes};
	catch
		vecDepth = vecTemplateDepths;
		vecZeta = sEphysData.ContamP(vecUseClusters);
		strZetaTit = 'Contamination';
		
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
end