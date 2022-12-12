function [vecClustAreaId,cellClustAreaLabel,cellClustAreaFull,vecVoxelDepth] = PF_GetAreaPerCluster(sProbeCoords,vecDepth)
	%PF_GetAreaPerCluster Retrieve areas per cluster by depth in microns from tip of the probe
	%according to channel map file (so uncorrected for probe lengthening/shrinking)
	
	%calculate cluster locations along probe trajectory
	probe_area_ids = sProbeCoords.sProbeAdjusted.probe_area_ids_per_depth;
	probe_area_labels = sProbeCoords.sProbeAdjusted.probe_area_labels_per_depth;
	probe_area_full = sProbeCoords.sProbeAdjusted.probe_area_full_per_depth;
	
	intCurrentProbeLength = floor(sProbeCoords.sProbeAdjusted.probe_vector_sph(end));
	probe_area_ids((end+1):intCurrentProbeLength) = probe_area_ids(end);
	probe_area_labels((end+1):intCurrentProbeLength) = probe_area_labels(end);
	probe_area_full((end+1):intCurrentProbeLength) = probe_area_full(end);
	
	vecVoxelDepth = (vecDepth / sProbeCoords.ProbeLengthMicrons)*intCurrentProbeLength;
	vecVoxelIdx = min(max(round(vecVoxelDepth),1),intCurrentProbeLength);
	
	%get outputs per cluster
	vecClustAreaId = probe_area_ids(vecVoxelIdx);
	cellClustAreaLabel = probe_area_labels(vecVoxelIdx);
	cellClustAreaFull =probe_area_full(vecVoxelIdx);
end
