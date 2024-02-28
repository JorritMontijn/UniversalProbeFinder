function SF_DeleteFcn(hObject,varargin)
	
	%get data
	if strcmp(hObject.UserData,'close')
		delete(hObject);
		return;
	end
	sGUI = guidata(hObject);
	sGUI = guidata(sGUI.handles.hMain);
	
	%check if data has been changed
	if isfield(sGUI,'boolAskSave') && ~sGUI.boolAskSave
		%ask to quit
		opts = struct;
		opts.Default = 'Cancel';
		opts.Interpreter = 'none';
		strAns = questdlg('Are you sure you wish to exit?','Confirm exit','Exit','Cancel',opts);
		switch strAns
			case 'Exit'
				hObject.UserData = 'close';
				SF_DeleteFcn(hObject);
				if ~isempty(sGUI.handles.hDispHelp) && ishandle(sGUI.handles.hDispHelp),close(sGUI.handles.hDispHelp);end
			case 'Cancel'
				return;
		end
	else
		%ask to quit
		opts = struct;
		opts.Default = 'Cancel';
		opts.Interpreter = 'none';
		strAns = questdlg('Are you sure you wish to exit?','Confirm exit','Save & Exit','Exit','Cancel',opts);
		switch strAns
			case 'Save & Exit'
				%export probe coord file
				SF_SaveSliceFinderFile(hObject);
				
				%update gui &close
				hObject.UserData = 'close';
				SF_DeleteFcn(hObject);
				if ~isempty(sGUI.handles.hDispHelp) && ishandle(sGUI.handles.hDispHelp),close(sGUI.handles.hDispHelp);end
			case 'Exit'
				hObject.UserData = 'close';
				SF_DeleteFcn(hObject);
				if ~isempty(sGUI.handles.hDispHelp) && ishandle(sGUI.handles.hDispHelp),close(sGUI.handles.hDispHelp);end
			case 'Cancel'
				return;
		end
	end
end