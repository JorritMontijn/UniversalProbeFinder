function PH_SelectPlotProp(hObject,eventdata)
	%PH_SelectPlotProp Callback when selecting a different cluster property to plot
	%   PH_SelectPlotProp(hObject,eventdata)
	
	% Get guidata
	sGUI = guidata(hObject);
	sGUI = guidata(sGUI.handles.hMain);
	hMain=sGUI.handles.hMain;
	
	%update list
	cellCategories = PH_GetClusterCategories(hMain);
	set(sGUI.handles.ptrButtonPlotProp,'Value',1,'String',cellCategories);
	
	%trigger redraw
	PH_PlotProbeEphys(hMain);
end

