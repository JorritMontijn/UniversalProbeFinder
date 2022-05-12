function sProbeCoords = PH_OpenCoordsFile(strDefaultPath,strName)
	%open a histology coordinates file and adds the file type to the sProbeCoords field .Type
	
	%% pre-allocate output
	sProbeCoords = [];
	if ~exist('strName','var') || isempty(strName)
		strPrompt = 'Select probe coordinate file';
	else
		strPrompt = ['Select probe coordinate file for ' strName];
	end
	
	%% select file
	try
		strOldPath = cd(strDefaultPath);
	catch
		strOldPath = cd();
	end
	[strFile,strPath]=uigetfile('probe_ccf.mat',strPrompt);
	cd(strOldPath);
	if isempty(strFile) || (numel(strFile)==1 && strFile==0)
		return;
	end
	
	%% load
	sLoad = load(fullpath(strPath,strFile));
	if isfield(sLoad,'sProbeCoords') && isstruct(sLoad.sProbeCoords)
		sProbeCoords = sLoad.sProbeCoords;
		sProbeCoords.Type = 'native';
	elseif isfield(sLoad,'probe_ccf') && isstruct(sLoad.probe_ccf) && isfield(sLoad.probe_ccf,'points')
		%AP_histology
		sProbeCoords.cellPoints = {sLoad.probe_ccf.points};
		sProbeCoords.Type = 'AP_histology';
	elseif isfield(sLoad,'pointList') && isstruct(sLoad.pointList) && isfield(sLoad.pointList,'pointList')
		%sharp track
		sProbeCoords.cellPoints = sLoad.pointList.pointList(:,1);
		sProbeCoords.Type = 'SHARP-track';
	else
		try
			error([mfilename ':FileTypeNotRecognized'],'File is of unknown format');
		catch ME
			strStack = sprintf('Error in %s (Line %d)',ME.stack(1).name,ME.stack(1).line);
			errordlg(sprintf('%s\n%s',ME.message,strStack),'Probe coord error')
			return;
		end
	end
	
	%add source
	sProbeCoords.folder = strPath;
	sProbeCoords.name = strFile;
end