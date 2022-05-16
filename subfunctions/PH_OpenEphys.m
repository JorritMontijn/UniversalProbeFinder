function sClusters = PH_OpenEphys(strPath)
	
	%get default
	if ~exist('strPath','var') || isempty(strPath) || strPath(1) == 0
		strPath = cd();
	end
	strEphysPath=uigetdir(strPath,'Select ephys data folder');
	sClusters = [];
	if isempty(strEphysPath) || strEphysPath(1) == 0,return;end
	
	%generate dummy sFile with minimal information
	sFile = struct;
	sFile.sClustered.folder = strEphysPath;
	
	%detect ephys type (currently only kilosort)
	intEphysType = 1;
	if intEphysType == 1
		%load data
		hMsg = msgbox('Loading electrophysiological data, please wait...','Loading ephys');
		sEphysData = PF_LoadEphys_KS(sFile);
		
		%prep data
		sClusters = PF_PrepEphys_KS(sFile,sEphysData);
		close(hMsg);
	else
		errordlg('Ephys format not recognized','Unknown format');
	end
end