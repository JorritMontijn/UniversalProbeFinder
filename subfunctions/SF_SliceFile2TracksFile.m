function sProbeCoords = SF_SliceFile2TracksFile(sSliceData,sAtlas)
	vecSizeMlApDv = size(sAtlas.av);
	intNumProbes = numel(sSliceData.Track);
	cellNames = {sSliceData.Track.name};
	cellPoints = cellfill(nan(0,3),size(cellNames));
	for intSlice=1:numel(sSliceData.Slice)
		sSlice = sSliceData.Slice(intSlice);
		TrackClick = sSlice.TrackClick;
		for intClick=1:numel(TrackClick)
			intTrack = TrackClick(intClick).Track;
			matVec = TrackClick(intClick).Vec;
			
			%transform
			Xs = matVec(:,1);
			Ys = matVec(:,2);
			[Xa,Ya,Za] = SF_SlicePts2AtlasPts(Xs,Ys,sSlice,vecSizeMlApDv);
			intPoints = size(Xa,1);
			
			%add
			cellPoints{intTrack}((end+1):(end+intPoints),:) = [Xa Ya Za];
		end
	end
	
	%add to probe struct
	sProbeCoords = struct;
	sProbeCoords.cellNames = cellNames;
	sProbeCoords.cellPoints = cellPoints;
	sProbeCoords.sourcepath = sSliceData.path;
	sProbeCoords.sourcedate = sSliceData.editdate;
	sProbeCoords.sourceatlas = sAtlas.Type;
end