function PH_DeleteHelpFcn(hObject,varargin)
	
	%get data
	sGUI = guidata(hObject);
	hMain = sGUI.handles.hMain;
	
	%delete
	delete(hObject);
	
	%reset focus
	if ~ishandle(hMain),return;end
	figure(hMain);drawnow;
	set(sGUI.handles.ptrButtonHelp, 'enable', 'off');
	drawnow;
	set(sGUI.handles.ptrButtonHelp, 'enable', 'on');
		
	
end