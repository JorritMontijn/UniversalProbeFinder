function sClusters = PH_OpenEphys(strPath)
	
	%% prepare
	%get default
	if ~exist('strPath','var') || isempty(strPath) || strPath(1) == 0
		strPath = cd();
	end
	strEphysPath=uigetdir(strPath,'Select ephys data folder');
	sClusters = [];
	if isempty(strEphysPath) || strEphysPath(1) == 0,return;end
	
	%load ephys parameters
	sEphysParams = PF_getEphysIni();
	
	%% run detectors
	indCanLoadTypes = false(1,numel(sEphysParams));
	
	for intType=1:numel(sEphysParams)
		%get files
		sDir=dir(strEphysPath);
		
		%get params
		cellReqFiles = sEphysParams(intType).reqfiles;
		boolUseRegExp = sEphysParams(intType).reqisregexp;
		
		%detect
		if boolUseRegExp
			%loop
			indIsPresent = false(size(cellReqFiles));
			for intFile=1:numel(indIsPresent)
				indIsPresent(intFile) = ~isempty(cell2vec(regexp({sDir.name},cellReqFiles{intFile}, 'once')));
			end
			indCanLoadTypes(intType) = all(indIsPresent);
		else
			%can do in one go
			indCanLoadTypes(intType) = all(any(cell2mat(cellfun(@(x) strcmpi(cellReqFiles,x),{sDir.name},'UniformOutput',false)'),1));
		end
	end
	
	%% ask user which to load if multiple are present
	if sum(indCanLoadTypes) == 0
		%no loadable data found
		errordlg('Ephys format not recognized','Unknown format');
		return;
	elseif sum(indCanLoadTypes) == 1
		%found one loadable type
		fLoader = sEphysParams(find(indCanLoadTypes,1)).loader;
		strName = sEphysParams(find(indCanLoadTypes,1)).name;
	elseif sum(indCanLoadTypes) > 1
		%could be multiple; request user input
		
		%remove non-eligible formats
		cellEphysNames = {sEphysParams.name};
		cellEphysNames = cellEphysNames(indCanLoadTypes);
		cellEphysLoaders = {sEphysParams.loader};
		cellEphysLoaders = cellEphysLoaders(indCanLoadTypes);
		[intLoader,boolContinue] = listdlg('ListSize',[200 100],'Name','Load Ephys','PromptString','Select Ephys format to load:',...
			'SelectionMode','single','ListString',cellEphysNames);
		if ~boolContinue,return;end
		fLoader = cellEphysLoaders{intLoader};
		strName = cellEphysNames{intLoader};
	end
	
	%% run loader
	%msg
	hMsg = msgbox(['Loading ' strName ' data, please wait...'],'Loading ephys');
	
	%run
	try
		sClusters = feval(fLoader,strEphysPath);
	catch
		sClusters = [];
	end
	try	
		%close msg
		close(hMsg);
	catch
	end
	
	%set show mask to all true
	try
		for i=1:numel(sClusters.Clust)
			sClusters.Clust(i).ShowMaskPF = true;
		end
	catch
	end
end