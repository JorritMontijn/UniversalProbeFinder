function PH_SelectCategProp(hObject,eventdata)
	%PH_SelectCategProp Callback when selecting a different cluster property
	%   PH_SelectCategProp(hObject,eventdata)
	
	% Get guidata
	sGUI = guidata(hObject);
	sGUI = guidata(sGUI.handles.hMain);
	hMain=sGUI.handles.hMain;
	
	%update list
	cellCategories = PH_GetClusterCategories(hMain);
	set(sGUI.handles.ptrButtonShowCateg,'Value',1,'String',cellCategories);
	
	%trigger redraw
	PH_PlotProbeEphys(hMain,sGUI.handles.ptrButtonShowCateg);
end

