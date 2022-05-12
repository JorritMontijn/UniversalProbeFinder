function PH_DeleteFcn(hObject,varargin)
	
	%get data
	if strcmp(hObject.UserData,'close')
		delete(hObject);
		return;
	end
	sGUI = guidata(hObject);
	
	%ask to quit
	opts = struct;
	opts.Default = 'Cancel';
	opts.Interpreter = 'none';
	strAns = questdlg('Are you sure you wish to exit?','Confirm exit','Save & Exit','Exit & Discard data','Cancel',opts);
	switch strAns
		case 'Save & Exit'
			%retrieve original data
			sProbeCoords = sGUI.sProbeCoords;
			
			%name
			if isfield(sProbeCoords,'name')
				strDefName = sProbeCoords.name;
			else
				strDefName = 'RecXXX_ProbeCoords.mat';
			end
			%export probe coord file
			PH_SaveProbeFile(hObject);
			
			%update gui &close
			hObject.UserData = 'close';
			sGUI.sProbeCoords = sProbeCoords;
			guidata(hObject,sGUI);
			PH_DeleteFcn(hObject);
		case 'Exit & Discard data'
			hObject.UserData = 'close';
			guidata(hObject,sGUI);
			PH_DeleteFcn(hObject);
		case 'Cancel'
			return;
	end
end