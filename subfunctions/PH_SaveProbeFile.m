function PH_SaveProbeFile(hMain,varargin)
	%PH_SaveProbeFile Save probe file
	%   PH_SaveProbeFile(hMain)
	
	%get data
	sGUI = guidata(hMain);
	
	% Export the probe coordinates in Allen CCF to the workspace
	sProbeCoords = sGUI.sProbeCoords;
	probe_vector_bregma = sGUI.sProbeCoords.sProbeAdjusted.probe_vector_bregma;
	pvb = probe_vector_bregma;
	assignin('base','probe_vector_bregma',probe_vector_bregma)
	assignin('base','sProbeCoords',sProbeCoords)
	uisave('sProbeCoords',['ProbeLocationFile' getDate]);
	fprintf(['\nCurrent probe location in Paxinos coordinates:\n'...
		'  ML: %.1f microns\n'...
		'  AP: %.1f microns\n'...
		'  ML-angle: %.1f degrees\n'...
		'  AP-angle: %.1f degrees\n'...
		'  Depth of tip: %.1f microns\n'...
		'  Probe length: %.1f microns\n'],...
		pvb(1),pvb(2),pvb(3),pvb(4),pvb(5),pvb(6));
end

