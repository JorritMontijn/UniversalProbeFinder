function SF_ExportSliceFinderFile(hMain,varargin)
	%SF_SaveSliceFinderFile Summary of this function goes here
	
	%get data
	sGUI = guidata(hMain);
	vecSizeMlApDv = size(sGUI.sAtlas.av);
	
	%% Export the probe trajectory points & save to file
	sProbeCoords = struct;
	intNumProbes = numel(sGUI.sSliceData.Track);
	cellNames = {sGUI.sSliceData.Track.name};
	cellPoints = cellfill(nan(0,3),size(cellNames));
	for intSlice=1:numel(sGUI.sSliceData.Slice)
		sSlice = sGUI.sSliceData.Slice(intSlice);
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
	
	%% add to probe struct
	sProbeCoords.cellNames = cellNames;
	sProbeCoords.cellPoints = cellPoints;
	sProbeCoords.sourcepath = sGUI.sSliceData.path;
	sProbeCoords.sourcedate = sGUI.sSliceData.editdate;
	sProbeCoords.sourceatlas = sGUI.sAtlas.Type;
	
	%ask where to put to file
	cellPathParts = strsplit(sGUI.sSliceData.path,filesep);
	strDefaultName = ['ProbeTracks' cellPathParts{end} '_' getDate '.mat'];
	try
		strOldPath = cd(sGUI.sSliceData.path);
	catch
		strOldPath = cd();
	end
	[strFile,strPath] = uiputfile('*.mat','Export Tracks',strDefaultName);
	cd(strOldPath);
	
	%save
	if isempty(strPath) || strPath(1) == 0
		%do nothing
	else
		%save
		save(fullpath(strPath,strFile),'sProbeCoords');
		
		%message
		sGUI.handles.ptrTextMessages.String = sprintf('Exported data to %s',strFile);
	end
	
	%reset focus
	figure(sGUI.handles.hMain);
	set(sGUI.handles.ptrButtonExport, 'enable', 'off');
	drawnow;
	set(sGUI.handles.ptrButtonExport, 'enable', 'on');
end