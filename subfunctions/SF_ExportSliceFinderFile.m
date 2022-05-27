function SF_ExportSliceFinderFile(hMain,varargin)
	%SF_SaveSliceFinderFile Summary of this function goes here
	
	%get data
	sGUI = guidata(hMain);
	
	% Export the probe trajectory points & save to file
	error to do
	
	%reset focus
	figure(sGUI.handles.hMain);
	set(sGUI.handles.ptrButtonExport, 'enable', 'off');
	drawnow;
	set(sGUI.handles.ptrButtonExport, 'enable', 'on');
end