function SH_SelectTrack(hObject,varargin)
	
	%get guidata
	sGUI = guidata(hObject);
	
	%find active track
	intActiveTrack = sGUI.handles.ptrListSelectTrack.Value;
	if intActiveTrack == 0
		if numel(sGUI.sSliceData.Track) > 0
			intActiveTrack = 1;
			sGUI.handles.ptrListSelectTrack.String = {sGUI.sSliceData.Track.name};
			sGUI.handles.ptrListSelectTrack.Value = intActiveTrack;
		else
			return;
		end
	end
	strName = sGUI.sSliceData.Track(intActiveTrack).name;
	strMarker = sGUI.sSliceData.Track(intActiveTrack).marker;
	vecColor = sGUI.sSliceData.Track(intActiveTrack).color;
	
	%edit text
	sGUI.handles.ptrTextActiveTrack.String = sprintf('%d: "%s"; Marker: %s',intActiveTrack,strName,strMarker);
	sGUI.handles.ptrTextActiveTrack.ForegroundColor = vecColor;
	
	%reset focus
	figure(sGUI.handles.hMain);
	set(sGUI.handles.ptrListSelectTrack, 'enable', 'off');
	drawnow;
	set(sGUI.handles.ptrListSelectTrack, 'enable', 'on');
end