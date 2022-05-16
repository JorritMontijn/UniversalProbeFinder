function [vecClustAreaId,cellClustAreaLabel,cellClustAreaFull] = PF_GetAreaPerCluster(sProbeCoords,vecDepth)
	%PF_GetAreaPerCluster Retrieve areas per cluster by depth
	
	%calculate cluster locations along probe trajectory
	probe_area_ids = sProbeCoords.sProbeAdjusted.probe_area_ids_per_depth;
	intCurrentProbeLength = floor(sProbeCoords.sProbeAdjusted.probe_vector_sph(end));
	vecVoxelDepth = (vecDepth / sProbeCoords.ProbeLengthMicrons)*intCurrentProbeLength;
	vecVoxelIdx = min(max(round(vecVoxelDepth),1),intCurrentProbeLength);
	
	%get outputs per cluster
	vecClustAreaId = probe_area_ids(vecVoxelIdx);
	cellClustAreaLabel = sProbeCoords.sProbeAdjusted.probe_area_labels_per_depth(vecVoxelIdx);
	cellClustAreaFull = sProbeCoords.sProbeAdjusted.probe_area_full_per_depth(vecVoxelIdx);
end
