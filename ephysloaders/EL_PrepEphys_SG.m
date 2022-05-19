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
	
	%load data
	
	
	%% prep ephys
	%check inputs
	sClusters = [];
	if ~exist('dblProbeLength','var') || isempty(dblProbeLength)
		dblProbeLength = max(sEphysData.ycoords); %should work, but kilosort might drop channels
	end
	
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
	%get channel mapping
	if isfield(sEphysData,'ChanIdx') && isfield(sEphysData,'ChanPos')
		sClusters.ChanIdx = sEphysData.ChanIdx;
		sClusters.ChanPos = sEphysData.ChanPos;
	end
end