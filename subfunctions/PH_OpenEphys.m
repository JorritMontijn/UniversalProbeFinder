function sClusters = PH_OpenEphys(strPath)
	
	%get default
	if ~exist('strPath','var') || isempty(strPath) || strPath(1) == 0
		strPath = cd();
	end
	strEphysPath=uigetdir(strPath,'Select kilosort data folder');
	
	%generate dummy sFile with minimal information
	sFile = struct;
	sFile.sClustered.folder = strEphysPath;
	
	%load data
	hMsg = msgbox('Loading electrophysiological data, please wait...','Loading ephys');
	sEphysData = PH_LoadEphys(sFile);
	
	%prep data
	sClusters = PH_PrepEphys(sFile,sEphysData);
	close(hMsg);
	
end