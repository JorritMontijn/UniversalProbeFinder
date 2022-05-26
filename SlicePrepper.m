function SlicePrepper(varargin)
	%SlicePrepper Multi-species histology alignment program

	%% add subfolders
	strFullpath = mfilename('fullpath');
	strPath = fileparts(strFullpath);
	sDir=dir([strPath filesep '**' filesep]);
	%remove git folders
	sDir(contains({sDir.folder},[filesep '.git'])) = [];
	cellFolders = unique({sDir.folder});
	for intFolder=1:numel(cellFolders)
		addpath(cellFolders{intFolder});
	end
	
	%% try using Acquipix variables
	try
		sRP = RP_populateStructure();
		strDefaultPath = sRP.strProbeLocPath;
	catch
		sRP = struct;
		strDefaultPath=fileparts(mfilename('fullpath'));
	end
	
	%% ask for folder & meta data (if any)
	sSliceData = SH_LoadSlicePath(strDefaultPath);
	if isempty(sSliceData),return;end
	
	%% load slices & pre-process
	SH_GenSlicePrepperGUI(sSliceData);
end