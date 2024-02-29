function [sProbeCoords,strFile,strPath] = PH_LoadProbeFile(sAtlas,strPath,strName)
	%PH_LoadProbeFile Load probe file with file selection window and extract coords
	%   [sProbeCoords,strFile,strPath] = PH_LoadProbeFile(sAtlas,strPath)
	
	if ~exist('strPath','var') || isempty(strPath) || strPath(1) == 0
		strPath = cd();
	end
	if ~exist('strName','var') || isempty(strName)
		strName = '';
	end
	
	%open file
	[sProbeCoords,strFile,strPath] = PH_OpenCoordsFile(strPath,strName,sAtlas);
	if ~isfield(sProbeCoords,'ProbeLength')
		%in microns (hardcode, sometimes kilosort2 drops channels)
		sProbeCoords.ProbeLength = 3840 ./ sAtlas.VoxelSize(end); %in native atlas size
	end
	if ~isfield(sProbeCoords,'ProbeLengthOriginal')
		sProbeCoords.ProbeLengthOriginal = sProbeCoords.ProbeLength; %initial size
	end
	if ~isfield(sProbeCoords,'ProbeLengthMicrons')
		sProbeCoords.ProbeLengthMicrons = sProbeCoords.ProbeLength * sAtlas.VoxelSize(end); %in microns
	end
	
	%select probe nr
	if isempty(sProbeCoords)
		sProbeCoords.folder = '';
		sProbeCoords.name = ['default'];
		sProbeCoords.cellPoints{1} = [sAtlas.Bregma; sAtlas.Bregma - [0 0 sProbeCoords.ProbeLengthMicrons]./sAtlas.VoxelSize];
		sProbeCoords.intProbeIdx = 1;
		sProbeCoords.Type = ['native'];
	else
		%transform probe coordinates
		sProbeCoords = PH_ExtractProbeCoords(sProbeCoords);
		
		%select probe
		if ~isfield(sProbeCoords,'intProbeIdx') || isempty(sProbeCoords.intProbeIdx)
			sProbeCoords.intProbeIdx = PH_SelectProbeNr(sProbeCoords,sAtlas);
		end
	end
	
end

