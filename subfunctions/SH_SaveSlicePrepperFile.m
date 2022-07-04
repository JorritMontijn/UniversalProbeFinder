function SH_SaveSlicePrepperFile(hMain,varargin)
	%SH_SaveSlicePrepperFile Summary of this function goes here
	
	%get data
	sGUI = guidata(hMain);
	
	% Export the probe coordinates to the workspace & save to file
	h1=msgbox('Saving data...','Saving data');
	sSliceData = sGUI.sSliceData;
	assignin('base','sSliceData',sSliceData)
	strFile = ['SliceFile_' getDate '_UniversalProbeFinder.mat'];
	save(fullpath(sSliceData.path,strFile),'sSliceData');
	if ishandle(h1),delete(h1);end
	h2=msgbox(sprintf('Saved data to:\n  File: %s\n  Path: %s\n',strFile,sSliceData.path),'Saved data');
	
	%reset focus
	figure(sGUI.handles.hMain);
	set(sGUI.handles.ptrButtonSave, 'enable', 'off');
	drawnow;
	set(sGUI.handles.ptrButtonSave, 'enable', 'on');
end

