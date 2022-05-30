function sGUI = SH_AddTrajectory(sGUI,intIm,intClick,intTrack,matVec)
	
	%delete previous if overwriting
	if numel(ishandle(sGUI.sSliceData.Slice(intIm).TrackClick)) >= intClick ...
			&& ishandle(sGUI.sSliceData.Slice(intIm).TrackClick(intClick).hLine)
		delete(sGUI.sSliceData.Slice(intIm).TrackClick(intClick).hLine);
	end
	if numel(ishandle(sGUI.sSliceData.Slice(intIm).TrackClick)) >= intClick ...
			&& ishandle(sGUI.sSliceData.Slice(intIm).TrackClick(intClick).hScatter)
		delete(sGUI.sSliceData.Slice(intIm).TrackClick(intClick).hScatter);
	end
	
	%add
	vecColor = sGUI.sSliceData.Track(intTrack).color;
	strMarker = sGUI.sSliceData.Track(intTrack).marker;
	sGUI.sSliceData.Slice(intIm).TrackClick(intClick).Vec = matVec; %[x1 y1; x2 y2] => normalized location in [0 1] range
	sGUI.sSliceData.Slice(intIm).TrackClick(intClick).Track = intTrack; %track #k
	sGUI.sSliceData.Slice(intIm).TrackClick(intClick).hLine = ...
		line(sGUI.handles.hAxSlice,[matVec(1,1) matVec(2,1)],[matVec(1,2) matVec(2,2)],...
		'color',vecColor,'LineWidth',1.5); %track #k
	sGUI.sSliceData.Slice(intIm).TrackClick(intClick).hScatter = ...
		scatter(sGUI.handles.hAxSlice,[matVec(1,1) matVec(2,1)],[matVec(1,2) matVec(2,2)],...
		20,vecColor,'LineWidth',1.5,'Marker',strMarker); %track #k
	
	%add deletion context menu
	hMenu = uicontextmenu;
	m1 = uimenu(hMenu,'Label','Delete','Callback',{@SH_DeleteTrackVector,sGUI.sSliceData.Slice(intIm).TrackClick(intClick).hLine});
	sGUI.sSliceData.Slice(intIm).TrackClick(intClick).hLine.UIContextMenu = hMenu;
	sGUI.sSliceData.Slice(intIm).TrackClick(intClick).hScatter.UIContextMenu = hMenu;
end