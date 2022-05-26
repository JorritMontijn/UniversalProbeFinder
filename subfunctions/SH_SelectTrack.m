function SH_SelectTrack(hObject,varargin)
	
	%get guidata
	sGUI = guidata(hObject);
	
	%find active track
	intActiveTrack = sGUI.handles.ptrListSelectTrack.Value;
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