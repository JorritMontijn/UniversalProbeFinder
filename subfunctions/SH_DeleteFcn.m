function SH_DeleteFcn(hObject,varargin)
	
	%get data
	if strcmp(hObject.UserData,'close')
		delete(hObject);
		return;
	end
	
	%ask to quit
	opts = struct;
	opts.Default = 'Cancel';
	opts.Interpreter = 'none';
	strAns = questdlg('Are you sure you wish to exit?','Confirm exit','Save & Exit','Exit & Discard data','Cancel',opts);
	switch strAns
		case 'Save & Exit'
			%export probe coord file
			SH_SaveSlicePrepperFile(hObject);
			
			%update gui &close
			hObject.UserData = 'close';
			SH_DeleteFcn(hObject);
		case 'Exit & Discard data'
			hObject.UserData = 'close';
			SH_DeleteFcn(hObject);
		case 'Cancel'
			return;
	end
end