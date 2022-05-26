function SliceFinder(varargin)
	%SliceFinder Multi-species histology slice alignment program

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
	
	%% load atlas
	sAtlasParams = PF_getAtlasIni();
	
	%select which atlas to use
	cellAtlases = {sAtlasParams.name};
	[intSelectAtlas,boolContinue] = listdlg('ListSize',[200 100],'Name','Atlas Selection','PromptString','Select Atlas:',...
		'SelectionMode','single','ListString',cellAtlases);
	if ~boolContinue,return;end
	
	%load atlas
	strAtlasName = sAtlasParams(intSelectAtlas).name;
	strPathVar = sAtlasParams(intSelectAtlas).pathvar;
	fLoader = sAtlasParams(intSelectAtlas).loader;
	
	%get path
	if isfield(sRP,strPathVar) && isfolder(sRP.(strPathVar))
		strAtlasPath = sRP.(strPathVar);
	else
		strAtlasPath = PF_getIniVar(strPathVar);
	end
	
	%load & prep atlas
	sAtlas = feval(fLoader,strAtlasPath);
	if isempty(sAtlas),return;end
	if isfield(sAtlasParams(intSelectAtlas),'downsample') && ~isempty(sAtlasParams(intSelectAtlas).downsample)
		sAtlas.Downsample = round(sAtlasParams(intSelectAtlas).downsample);
	else
		sAtlas.Downsample = 1;
	end
	
	%% run slice aligner
	SH_GenSliceFinderGUI(sAtlas,sSliceData);
end