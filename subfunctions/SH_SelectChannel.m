function SH_SelectChannel(hObject,eventdata)
	
	%get data
	sGUI = guidata(hObject);
	
	%reset focus
	set(sGUI.handles.ptrListChannels, 'enable', 'off');
	drawnow;
	set(sGUI.handles.ptrListChannels, 'enable', 'on');
	
	%plot
	SH_PlotPrepIms(sGUI.handles.hMain);
end