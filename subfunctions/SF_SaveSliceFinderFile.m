function SF_SaveSliceFinderFile(hMain,varargin)
	%SF_SaveSliceFinderFile Summary of this function goes here
	
	%get data
	sGUI = guidata(hMain);
	
	% Export the probe coordinates to the workspace & save to file
	h1=msgbox('Saving data...','Saved data');
	sSliceData = sGUI.sSliceData;
	assignin('base','sSliceData',sSliceData)
	strFile = ['Aligned' getDate '_UniversalProbeFinder_SliceFile.mat'];
	save(fullpath(sSliceData.path,strFile),'sSliceData');
	if ishandle(h1),delete(h1);end
	h2=msgbox(sprintf('Saved data to:\n  File: %s\n  Path: %s\n',strFile,sSliceData.path),'Saved data');
	
	%message
	sGUI.handles.ptrTextMessages.String = sprintf('Saved to %s',sSliceData.path);drawnow;
	
	%reset focus
	figure(sGUI.handles.hMain);
	set(sGUI.handles.ptrButtonSave, 'enable', 'off');
	drawnow;
	set(sGUI.handles.ptrButtonSave, 'enable', 'on');
end

