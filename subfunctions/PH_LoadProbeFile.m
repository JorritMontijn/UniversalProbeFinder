function sProbeCoords = PH_LoadProbeFile(sAtlas,strPath)
	%PH_LoadProbeFile Load probe file with file selection window and extract coords
	%   sProbeCoords = PH_LoadProbeFile(sAtlas,strPath)
	
	if ~exist('strPath','var') || isempty(strPath) || strPath(1) == 0
		strPath = cd();
	end
	
	%open file
	sProbeCoords = PH_OpenCoordsFile(strPath);
	dblProbeLength = 3840;%in microns (hardcode, sometimes kilosort2 drops channels)
	
	%select probe nr
	if isempty(sProbeCoords)
		sProbeCoords.folder = '';
		sProbeCoords.name = ['default'];
		sProbeCoords.cellPoints{1} = [sAtlas.Bregma; sAtlas.Bregma - [0 0 dblProbeLength]./sAtlas.VoxelSize];
		sProbeCoords.intProbeIdx = 1;
		sProbeCoords.Type = ['native'];
	else
		%transform probe coordinates
		sProbeCoords = PH_ExtractProbeCoords(sProbeCoords);
		
		%select probe
		intProbeIdx = PH_SelectProbeNr(sProbeCoords,sAtlas);
		sProbeCoords.intProbeIdx = intProbeIdx;
	end
	sProbeCoords.ProbeLength = dblProbeLength ./ sAtlas.VoxelSize(end); %in native atlas size
	sProbeCoords.ProbeLengthMicrons = dblProbeLength; %in microns
end

