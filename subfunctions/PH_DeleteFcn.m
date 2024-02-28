function PH_DeleteFcn(hObject,varargin)
	
	%get data
	if isa(hObject,'timer')
		stop(hObject);
		delete(hObject);
		hObject=varargin{2};
	end
	if ~ishandle(hObject)
		return;
	elseif strcmp(hObject.UserData,'close')
		delete(hObject);
		return;
	end
	try
		sGUI = guidata(hObject);
		sGUI = guidata(sGUI.handles.hMain);
		
		%ask to quit
		opts = struct;
		opts.Default = 'Cancel';
		opts.Interpreter = 'none';
		strAns = questdlg('Are you sure you wish to exit?','Confirm exit','Save & Exit','Exit','Cancel',opts);
		switch strAns
			case 'Save & Exit'
				%export probe coord file
				PH_SaveProbeFile(hObject);
				
				%create deletion timer
				hObject.UserData = 'close';
				start(timer('StartDelay',0.2,'TimerFcn',{@PH_DeleteFcn,hObject}));
				if ~isempty(sGUI.handles.hDispHelp) && ishandle(sGUI.handles.hDispHelp),close(sGUI.handles.hDispHelp);end
			case 'Exit'
				hObject.UserData = 'close';
				guidata(hObject,[]);
				start(timer('StartDelay',0.2,'TimerFcn',{@PH_DeleteFcn,hObject}));
				if ~isempty(sGUI.handles.hDispHelp) && ishandle(sGUI.handles.hDispHelp),close(sGUI.handles.hDispHelp);end
			case 'Cancel'
				return;
		end
	catch
		delete(hObject);
	end
end