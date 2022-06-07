function SF_DeleteFcn(hObject,varargin)
	
	%get data
	if strcmp(hObject.UserData,'close')
		delete(hObject);
		return;
	end
	sGUI = guidata(hObject);
	sGUI = guidata(sGUI.handles.hMain);
	
	%ask to quit
	opts = struct;
	opts.Default = 'Cancel';
	opts.Interpreter = 'none';
	strAns = questdlg('Are you sure you wish to exit?','Confirm exit','Save & Exit','Exit & Discard data','Cancel',opts);
	switch strAns
		case 'Save & Exit'
			%export probe coord file
			SF_SaveSliceFinderFile(hObject);
			
			%update gui &close
			hObject.UserData = 'close';
			SF_DeleteFcn(hObject);
			if ~isempty(sGUI.handles.hDispHelp) && ishandle(sGUI.handles.hDispHelp),close(sGUI.handles.hDispHelp);end
		case 'Exit & Discard data'
			hObject.UserData = 'close';
			SF_DeleteFcn(hObject);
			if ~isempty(sGUI.handles.hDispHelp) && ishandle(sGUI.handles.hDispHelp),close(sGUI.handles.hDispHelp);end
		case 'Cancel'
			return;
	end
end