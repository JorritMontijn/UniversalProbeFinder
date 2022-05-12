function PH_ResetFcn(hObject,varargin)
	
	%get data
	sGUI = guidata(hObject);
	
	%ask for confirmation
	opts = struct;
	opts.Default = 'Cancel';
	opts.Interpreter = 'none';
	strAns = questdlg('Are you sure you wish to reset the probe position?','Confirm reset','Reset','Cancel',opts);
	if ~strcmp(strAns,'Reset'),return;end
	
	%extract
	sProbeCoords = PH_ExtractProbeCoords(sGUI.sProbeCoords);
	
	%save
	boolReset = true;
	PH_LoadProbeLocation(sGUI.handles.hMain,sProbeCoords,sGUI.sAtlas,boolReset);
end