function intOutFlag = assertBioFormats(strPath)
	%assertBioFormats Assert bioformats toolbox
	%   intOutFlag = assertBioFormats(strPath)
	
	intOutFlag = -1;
	status = 0;
	try
		%check if path to bioformats has been set
		strBioformatsFolder = PF_getIniVar('BioformatsFolder');
		if ~isempty(strBioformatsFolder) && exist(strBioformatsFolder,'dir')
			addpath(strBioformatsFolder);
		end
		[status,v] = bfCheckJavaPath();
	catch
		%check if user said to ignore bioformats
		boolNeverBioformats = PF_getIniVar('NeverBioformats')~=0;
		
		if ~boolNeverBioformats
			%ask if user wants to select the path
			strAns = questdlg('Set bioformats path for files like .czi?'...
				,'bioformats API','Yes','No','Never','Yes');
			if strcmp(strAns,'Yes')
				if ~exist('strPath','var') || isempty(strPath)
					strPath = uigetdir('','Please select the folder for the bioformats MATLAB API (bfmatlab)');
					if isempty(strPath) || strPath(1) == 0 || ~exist(strPath,'dir')
						%cancel
						error([mfilename ':bioformatserror'],'Invalid bioformats path\n');
					else
						%add path
						addpath(strPath);
						try
							[status,v] = bfCheckJavaPath();
							savepath();
							%save location to ini
							PF_getIniVar('BioformatsFolder',true,strPath);
						catch
							error([mfilename ':bioformatserror'],'The bioformats API is not working; please check your installation\n');
						end
					end
				end
			elseif strcmp(strAns,'Never')
				PF_getIniVar('NeverBioformats',true,1);
			end
		end
	end
	if status
		try
			loci.common.DebugTools.enableLogging('WARN');
			bfInitLogging('WARN');
			r = loci.formats.Memoizer(bfGetReader(), 0);
			r.close();
			intOutFlag = 0;
		catch
			%do nothing
		end
	end
end
