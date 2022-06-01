function SF_ExportSliceFinderFile(hMain,varargin)
	%SF_SaveSliceFinderFile Summary of this function goes here
	
	%get data
	sGUI = guidata(hMain);
	
	%% transform file format
	sSliceData = sGUI.sSliceData;
	sAtlas = sGUI.sAtlas;
	sProbeCoords = SF_SliceFile2TracksFile(sSliceData,sAtlas);
	
	%% save
	%ask where to put to file
	cellPathParts = strsplit(sGUI.sSliceData.path,filesep);
	strDefaultName = ['ProbeTracks' cellPathParts{end} '_' getDate '.mat'];
	try
		strOldPath = cd(sGUI.sSliceData.path);
	catch
		strOldPath = cd();
	end
	[strFile,strPath] = uiputfile('*.mat','Export Tracks',strDefaultName);
	cd(strOldPath);
	
	%save
	if isempty(strPath) || strPath(1) == 0
		%do nothing
	else
		%save
		save(fullpath(strPath,strFile),'sProbeCoords');
		
		%message
		sGUI.handles.ptrTextMessages.String = sprintf('Exported data to %s',strFile);
	end
	
	%reset focus
	figure(sGUI.handles.hMain);
	set(sGUI.handles.ptrButtonExport, 'enable', 'off');
	drawnow;
	set(sGUI.handles.ptrButtonExport, 'enable', 'on');
end