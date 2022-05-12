function PH_LoadProbeFcn(hObject,varargin)
	
	%get data
	sGUI = guidata(hObject);
	
	%extract
	sProbeCoords = PH_LoadProbeFile(sGUI.sAtlas);
	if strcmp(sProbeCoords.folder,'') && strcmp(sProbeCoords.name,'default'),return;end
	
	%set new location
	PH_LoadProbeLocation(sGUI.handles.hMain,sProbeCoords,sGUI.sAtlas);
end