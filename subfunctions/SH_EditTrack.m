function SH_EditTrack(hObject,varargin)
	%get guidata
	sGUI = guidata(hObject);
	
	%ask for new name/marker/color
	intTrack = sGUI.handles.ptrListSelectTrack.Value;
	if intTrack==0,return;end
	strDefName = sGUI.sSliceData.Track(intTrack).name;
	strDefMarker = sGUI.sSliceData.Track(intTrack).marker;
	vecDefColor = sGUI.sSliceData.Track(intTrack).color;
	strTitle = 'Edit track';
	[strName,strMarker,vecColor] = SH_TrackUI(strDefName,strDefMarker,vecDefColor,strTitle);
	if isempty(strName) || isempty(strMarker) || isempty(vecColor)
		return;
	end
	
	%add track
	sGUI.sSliceData.Track(intTrack).name = strName;
	sGUI.sSliceData.Track(intTrack).marker = strMarker;
	sGUI.sSliceData.Track(intTrack).color = vecColor;
	
	%regenerate list
	sGUI.handles.ptrListSelectTrack.String = {sGUI.sSliceData.Track.name};
	sGUI.handles.ptrListSelectTrack.Value = intTrack;
	
	%reset saving switch
	sGUI.boolAskSave = true;
	guidata(hObject, sGUI);
	
	%redraw
	SH_PlotPrepIms(hObject);
	
	%reset focus
	figure(sGUI.handles.hMain);
	set(sGUI.handles.ptrButtonEditTrack, 'enable', 'off');
	drawnow;
	set(sGUI.handles.ptrButtonEditTrack, 'enable', 'on');
end