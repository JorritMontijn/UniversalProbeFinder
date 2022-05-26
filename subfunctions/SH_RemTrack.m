function SH_RemTrack(hObject,varargin)
	%get guidata
	sGUI = guidata(hObject);
	
	%get active track
	intActiveTrack = sGUI.handles.ptrListSelectTrack.Value;
	strName = sGUI.sSliceData.Track(intActiveTrack).name;
	
	%ask for confirmation
	strAns = questdlg(sprintf('Are you sure you wish to delete "%s"?',strName),'Confirm deletion','Delete','Cancel','Cancel');
	if strcmp(strAns,'Delete')
		%get new track
		if numel(sGUI.sSliceData.Track) == 1
			intNewTrack = 0;
		else
			intNewTrack = max(intActiveTrack - 1,1);
		end
		%remove track
		sGUI.sSliceData.Track(intActiveTrack) = [];
		
		%update list
		sGUI.handles.ptrListSelectTrack.Value = intNewTrack;
		sGUI.handles.ptrListSelectTrack.String = {sGUI.sSliceData.Track.name};
		
		%update text
		if intNewTrack == 0
			strName = 'none';
			strMarker = 'none';
			vecColor = [0 0 0];
		else
			strName = sGUI.sSliceData.Track(intNewTrack).name;
			strMarker = sGUI.sSliceData.Track(intNewTrack).marker;
			vecColor = sGUI.sSliceData.Track(intNewTrack).color;
		end
		sGUI.handles.ptrTextActiveTrack.String = sprintf('%d: "%s"; Marker: %s',intNewTrack,strName,strMarker);
		sGUI.handles.ptrTextActiveTrack.ForegroundColor = vecColor;
		
		%go through all slices and remove all clicks for this track; and subtract 1 from all tracks
		%with ID higher than this track
		for intIm=1:numel(sGUI.sSliceData.Slice)
			intClickNum = numel(sGUI.sSliceData.Slice(intIm).TrackClick);
			for intClick=1:intClickNum
				indRemClicks = false(1,intClickNum);
				if sGUI.sSliceData.Slice(intIm).TrackClick(intClick).Track == intActiveTrack
					indRemClicks(intClick) = true;
					delete(sGUI.sSliceData.Slice(intIm).TrackClick(intClick).hLine);
					delete(sGUI.sSliceData.Slice(intIm).TrackClick(intClick).hScatter);
				elseif sGUI.sSliceData.Slice(intIm).TrackClick(intClick).Track > intActiveTrack
					sGUI.sSliceData.Slice(intIm).TrackClick(intClick).Track = sGUI.sSliceData.Slice(intIm).TrackClick(intClick).Track - 1;
				end
			end
			if intClickNum>0
				sGUI.sSliceData.Slice(intIm).TrackClick(indRemClicks) = [];
			end
		end
		
		%update data
		guidata(hObject,sGUI);
	else
		return;
	end
	
	%reset focus: doesn't actually work...
	figure(sGUI.handles.hMain);
	set(sGUI.handles.ptrButtonRemTrack, 'enable', 'off');
	drawnow;
	set(sGUI.handles.ptrButtonRemTrack, 'enable', 'on');
end
	