function SH_NewTrack(hObject,varargin)
	%get guidata
	sGUI = guidata(hObject);
	
	%get details
	cellTrackNames = {sGUI.sSliceData.Track.name};
	for intNewTrack=1:(numel(cellTrackNames)+1)
		strDefName = sprintf('Track %d',intNewTrack);
		if ~ismember(strDefName,cellTrackNames),break;end
	end
	strTitle = 'New track';
	[strName,strMarker,vecColor] = SH_TrackUI(strDefName,intNewTrack,intNewTrack,strTitle);
	if isempty(strName) || isempty(strMarker) || isempty(vecColor)
		return;
	end
	
	%add track
	intNewTrackIdx = numel(sGUI.sSliceData.Track)+1;
	sGUI.sSliceData.Track(intNewTrackIdx).name = strName;
	sGUI.sSliceData.Track(intNewTrackIdx).marker = strMarker;
	sGUI.sSliceData.Track(intNewTrackIdx).color = vecColor;
	
	%reset saving switch
	sGUI.boolAskSave = true;
	guidata(hObject, sGUI);
	
	%set new track active
	sGUI.handles.ptrListSelectTrack.String = {sGUI.sSliceData.Track.name};
	sGUI.handles.ptrListSelectTrack.Value = intNewTrackIdx;
	
	%update list/text
	SH_SelectTrack(hObject);
	
	
	%reset focus
	figure(sGUI.handles.hMain);
	set(sGUI.handles.ptrButtonNewTrack, 'enable', 'off');
	drawnow;
	set(sGUI.handles.ptrButtonNewTrack, 'enable', 'on');
end