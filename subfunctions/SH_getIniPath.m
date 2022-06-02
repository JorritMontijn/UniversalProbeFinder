function strPath = SH_getIniPath()
	if isdeployed
		strPath = ctfroot;
	else
		strPathFile = mfilename('fullpath');
		cellDirs = strsplit(strPathFile,filesep);
		strPath = strjoin(cellDirs(1:(end-2)),filesep);
	end
end