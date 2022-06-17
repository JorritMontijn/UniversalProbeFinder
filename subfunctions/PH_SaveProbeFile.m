function PH_SaveProbeFile(hMain,varargin)
	%PH_SaveProbeFile Save probe file
	%   PH_SaveProbeFile(hMain)
	
	%get data
	sGUI = guidata(hMain);
	
	% Export the probe coordinates to the workspace & save to file
	sProbeCoords = sGUI.sProbeCoords;
	
	%add depth
	intCurrentProbeLength = floor(sProbeCoords.sProbeAdjusted.probe_vector_sph(end));
	if isfield(sGUI.sClusters,'vecDepth')
		sProbeCoords.sProbeAdjusted.depth_per_cluster = (sGUI.sClusters.vecDepth ./ sProbeCoords.ProbeLengthMicrons)*intCurrentProbeLength;
	else
		sProbeCoords.sProbeAdjusted.depth_per_cluster = [];
	end
	
	%save
	sGUI.sProbeCoords = sProbeCoords;
	guidata(hMain,sGUI);
	
	%get other data
	probe_vector_bregma = sGUI.sProbeCoords.sProbeAdjusted.probe_vector_bregma;
	pvb = probe_vector_bregma;
	assignin('base','probe_vector_bregma',probe_vector_bregma)
	assignin('base','sProbeCoords',sProbeCoords)
	if ~(sGUI.runtype == 2 && nargin == 1)
		uisave('sProbeCoords',['ProbeLocationFile' getDate]);
	end
	fprintf(['\nCurrent probe location in Paxinos coordinates:\n'...
		'  ML: %.1f microns\n'...
		'  AP: %.1f microns\n'...
		'  ML-angle: %.1f degrees\n'...
		'  AP-angle: %.1f degrees\n'...
		'  Depth of tip: %.1f microns\n'...
		'  Probe length: %.1f microns\n'],...
		pvb(1),pvb(2),pvb(3),pvb(4),pvb(5),pvb(6));
end

