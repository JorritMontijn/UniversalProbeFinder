function SF_LoadSliceData(hObject,varargin)
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
		SF_SaveSliceFinderFile(hMain);
	end
	
	%load
	sSliceData = SH_LoadSlicePath(sGUI.sSliceData.path);
	if isempty(sSliceData),return;end
	
	%Obtains this pixel information
	vecScreenSize = get(0,'screensize');
	sSliceData = SH_ReadImages(sSliceData,vecScreenSize([4 3]));
	sGUI.sSliceData = sSliceData;
	
	%clear old data
	sGUI.intCurrIm = 1;
	sGUI.CurrCopy = nan;
	sGUI.PrevCopy = nan;
	sGUI.CopyIms = [];
	
	%update messages
	sGUI.handles.ptrTextClipboard.String = sprintf('Curr copy: %d - Prev copy: %d',sGUI.CurrCopy,sGUI.PrevCopy);
	sGUI.handles.ptrTextMessages.String = sprintf('Loaded %s',sGUI.sSliceData.path);
	
	%update list
	sGUI.handles.ptrListSelectTrack.String = {sGUI.sSliceData.Track(:).name};
	sGUI.handles.ptrListSelectTrack.Value = 1;
	
	%update data
	guidata(hMain,sGUI);
	
	%plot header+current slice and update slice in atlas + redraw atlas on slice
	SF_PlotIms(hMain);
	
	%reset focus
	figure(sGUI.handles.hMain);
	set(sGUI.handles.ptrButtonLoad, 'enable', 'off');
	drawnow;
	set(sGUI.handles.ptrButtonLoad, 'enable', 'on');
end