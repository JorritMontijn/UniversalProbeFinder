function [sProbeCoords] = PH_ExtractProbeCoords(sProbeCoords)
	%PH_ExtractProbeCoords Transforms coordinate system of input file to ProbeHistology coordinates
	%	sProbeCoords = PH_ExtractProbeCoords(sProbeCoords)
	%
	%Coordinates are [ML=x AP=y DV=z], using the atlas's Bregma in native atlas grid entry indices. For
	%example, the rat SD atlas has bregma [ML=246,AP=653,DV=440]; Note:
	% - probe coordinates are transformed to microns and the origin (x=0,y=0,z=0) is bregma
	% - the location of the "probe" is the location of the _tip_ relative to bregma
	% - low ML (-x) is left of bregma, high ML (+x) is right of bregma
	% - low AP is posterior (i.e., -y in AP coordinates is posterior to bregma)
	% - low DV is ventral (i.e., -z w.r.t. lambda is ventral and inside of the brain, while
	% - Note that this is not the native Allen Brain CCF coordinates, as those do not make any sense.
	% - the probe has two angles: ML and AP where (0;0) degrees is a vertical insertion
	
	%check formats
	if ~isfield(sProbeCoords,'format') || ~strcmpi(sProbeCoords.format,'ML,AP,DV')
		if strcmpi(sProbeCoords.Type,'AP_histology')
			%AP_histology output
			vecSizeABA = [1140 1320 800]; %ML,AP,DV (post-transformed)
			for intProbe=1:numel(sProbeCoords.cellPoints)
				%should be [ML,AP,DV]
				%is [x,DV,y] => [y x 2]  = [3 1 2]?
				sProbeCoords.cellPoints{intProbe} = sProbeCoords.cellPoints{intProbe}(:,[3 1 2]);
				sProbeCoords.cellPoints{intProbe} = [...
					sProbeCoords.cellPoints{intProbe}(:,1) ...
					vecSizeABA(2) - sProbeCoords.cellPoints{intProbe}(:,2)...
					vecSizeABA(3) - sProbeCoords.cellPoints{intProbe}(:,3)...
					];
			end
			sProbeCoords.format = 'ML,AP,DV';
		elseif strcmpi(sProbeCoords.Type,'SHARP-track')
			%sharp track
			error('this might not be correct yet')
			for intProbe=1:numel(sProbeCoords.cellPoints)
				sProbeCoords.cellPoints{intProbe} = sProbeCoords.cellPoints{intProbe}(:,[3 1 2]);%is this correct?
			end
			sProbeCoords.format = 'ML,AP,DV';
		elseif strcmpi(sProbeCoords.Type,'native')
			sProbeCoords.format = 'ML,AP,DV';
		else
			%file not recognized
			error([mfilename ':UnknownFormat'],'Probe location file format is not recognized');
		end
	end
end