function PH_SelectClustProp(hObject,eventdata)
	%PH_SelectClustProp Callback when selecting a different cluster property
	%   PH_SelectClustProp(hObject,eventdata)
	
	% Get guidata
	sGUI = guidata(hObject);
	sGUI = guidata(sGUI.handles.hMain);
	hMain=sGUI.handles.hMain;
	
	%update list
	cellCategories = PH_GetClusterCategories(hMain);
	set(sGUI.handles.ptrButtonShowClusters,'Value',1,'String',cellCategories);
	
	%trigger redraw
	PH_PlotProbeEphys(hMain);
end

