function SH_LoadSliceData(hObject,varargin)
	%get gui data
	sGUI = guidata(hObject);
	hMain = sGUI.handles.hMain;
	
	%save old data
	opts = struct;
	opts.Default = 'Cancel';
	opts.Interpreter = 'none';
	strAns = questdlg('Do you want to save your data first?','Confirm loading','Save first','Discard data','Cancel',opts);
	if strcmpi(strAns,'Cancel')
		return;
	elseif strcmpi(strAns,'Save first')
		SH_SaveSlicePrepperFile(hMain);
	end
	
	%load
	sSliceData = SH_LoadSlicePath(sGUI.sSliceData.path);
	if isempty(sSliceData),return;end
	
	%Obtains this pixel information
	vecScreenSize = get(0,'screensize');
	sSliceData = SH_ReadImages(sSliceData,vecScreenSize([4 3]));
	sGUI.sSliceData = sSliceData;
	
	%clear old data
	SH_ClearClick(hObject);
	sGUI.intCurrIm = 1;
	
	%update list
	sGUI.handles.ptrListSelectTrack.String = {''};
	sGUI.handles.ptrListSelectTrack.Value = 0;
	sGUI.handles.ptrTextActiveTrack.String = '';
	
	%reset saving switch
	sGUI.boolAskSave = false;
	
	%update data
	guidata(hMain,sGUI);
	
	%plot images
	SH_PlotPrepIms(hMain);
	
	%reset focus
	figure(sGUI.handles.hMain);
	set(sGUI.handles.ptrButtonLoad, 'enable', 'off');
	drawnow;
	set(sGUI.handles.ptrButtonLoad, 'enable', 'on');
end