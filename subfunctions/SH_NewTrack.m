function SH_NewTrack(hObject,varargin)
	%get guidata
	sGUI = guidata(hObject);
	
	%get details
	intNewTrack = numel(sGUI.sSliceData.Track)+1;
	strDefName = sprintf('Track %d',intNewTrack);
	strTitle = 'New track';
	[strName,strMarker,vecColor] = SH_TrackUI(strDefName,intNewTrack,intNewTrack,strTitle);
	if isempty(strName) || isempty(strMarker) || isempty(vecColor)
		return;
	end
	
	%add track
	sGUI.sSliceData.Track(intNewTrack).name = strName;
	sGUI.sSliceData.Track(intNewTrack).marker = strMarker;
	sGUI.sSliceData.Track(intNewTrack).color = vecColor;
	
	%add guidata
	guidata(hObject,sGUI);
	
	%set new track active
	sGUI.handles.ptrListSelectTrack.String = {sGUI.sSliceData.Track.name};
	sGUI.handles.ptrListSelectTrack.Value = intNewTrack;
	
	%update list/text
	SH_SelectTrack(hObject);
	
	
	%reset focus
	figure(sGUI.handles.hMain);
	set(sGUI.handles.ptrButtonNewTrack, 'enable', 'off');
	drawnow;
	set(sGUI.handles.ptrButtonNewTrack, 'enable', 'on');
end