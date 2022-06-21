function strPath = SH_getIniPath()
	
	try
		if isdeployed && ismac
			NameOfDeployedApp = 'UniversalProbeFinder'; % do not include the '.app' extension
			[~, result] = system(['top -n100 -l1 | grep ' NameOfDeployedApp ' | awk ''{print $1}''']);
			result=strtrim(result);
			[status, result] = system(['ps xuwww -p ' result ' | tail -n1 | awk ''{print $NF}''']);
			if status==0
				diridx=strfind(result,[NameOfDeployedApp '.app']);
				strPath=result(1:diridx-2);
			else
				msgbox({'realpwd not set:',result})
			end
		elseif isdeployed && isunix
			[status, result] = system('echo $PATH');
			strPath = char(regexpi(result, '(.*?):', 'tokens', 'once'));
		elseif isdeployed
			[status, result] = system('path');
			strPath = char(regexpi(result, 'Path=(.*?);', 'tokens', 'once'));
		else
			strPathFile = mfilename('fullpath');
			cellDirs = strsplit(strPathFile,filesep);
			strPath = strjoin(cellDirs(1:(end-2)),filesep);
		end
	catch
		strPathFile = mfilename('fullpath');
		cellDirs = strsplit(strPathFile,filesep);
		strPath = strjoin(cellDirs(1:(end-1)),filesep);
	end
end