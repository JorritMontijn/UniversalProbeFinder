function SetVariablesUPF(varargin)
	
	%check for ini file
	strPathFile = mfilename('fullpath');
	cellDirs = strsplit(strPathFile,filesep);
	strPath = strjoin(cellDirs(1:(end-1)),filesep);
	strIni = strcat(strPath,filesep,'configPF.ini');
	%load data
	fFile = fopen(strIni,'rt');
	vecData = fread(fFile);
	fclose(fFile);
	
	%convert
	strData = cast(vecData','char');
	[cellStructs,cellStructNames] = ini2struct(strData);
	for intIdx=1:numel(cellStructs)
		eval([cellStructNames{intIdx} '= cellStructs{' num2str(intIdx) '};']);
	end
	
	%get variables
	cellVarNames = fieldnames(sPF);
	[indx,tf] = listdlg('ListSize',[200 200],'Name','Edit variable','ListString',cellVarNames,'PromptString','Select a variable to edit',...
		'SelectionMode','single');
	
	%edit
	if tf == 0,return;end
	PF_getIniVar(cellVarNames{indx},true);
end