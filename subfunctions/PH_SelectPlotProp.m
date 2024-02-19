function PH_SelectPlotProp(hObject,eventdata)
	%PH_SelectPlotProp Callback when selecting a different cluster property to plot
	%   PH_SelectPlotProp(hObject,eventdata)
	
	% Get guidata
	sGUI = guidata(hObject);
	sGUI = guidata(sGUI.handles.hMain);
	hMain=sGUI.handles.hMain;
	
	%trigger redraw
	PH_PlotProbeEphys(hMain,sGUI.handles.ptrButtonPlotProp);
end

