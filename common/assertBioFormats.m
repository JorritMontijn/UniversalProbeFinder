function intOutFlag = assertBioFormats(strPath)
	%assertBioFormats Assert bioformats toolbox
	%   intOutFlag = assertBioFormats(strPath)
	
	intOutFlag = -1;
	try
		[status,v] = bfCheckJavaPath();
	catch
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
				catch
					error([mfilename ':bioformatserror'],'The bioformats API is not working; please check your installation\n');
				end
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
