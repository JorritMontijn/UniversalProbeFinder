function PH_DeleteHelpFcn(hObject,varargin)
	
	%get data
	sGUI = guidata(hObject);
	sGUI = guidata(sGUI.handles.hMain);
	hMain = sGUI.handles.hMain;
	
	%delete
	close(hObject);
	
	%reset focus
	figure(hMain);drawnow;
	set(sGUI.handles.ptrButtonHelp, 'enable', 'off');
	drawnow;
	set(sGUI.handles.ptrButtonHelp, 'enable', 'on');
		
	
end