function varOut = PF_getIniVar(strVarName)
	%PF_populateStructure Prepares parameters by loading ini file, or creates one with default values
	
	%check for ini file
	strPathFile = mfilename('fullpath');
	cellDirs = strsplit(strPathFile,filesep);
	strPath = strjoin(cellDirs(1:(end-2)),filesep);
	strIni = strcat(strPath,filesep,'configPF.ini');
	
	%load ini
	if exist(strIni,'file')
		%load data
		fFile = fopen(strIni,'rt');
		vecData = fread(fFile);
		fclose(fFile);
		%convert
		strData = cast(vecData','char');
		[cellStructs,cellStructNames] = ini2struct(strData);
		eval([cellStructNames{1} '= cellStructs{1};']);
	else
		%empty placeholder
		sPF=struct;
	end
	
	%retrieve or set variable
	if isfield(sPF,strVarName)
		varOut = sPF.(strVarName);
	else
		%fill if empty
		cellPathVars = {'strAllenCCFPath','strSpragueDawleyPath'};
		if ismember(strVarName,cellPathVars)
			%alter name
			strAtlasName = strVarName;
			if strcmp(strAtlasName(1:3),'str')
				strAtlasName = strAtlasName(4:end);
			end
			if strcmpi(strAtlasName((end-3):end),'Path')
				strAtlasName = strAtlasName(1:(end-4));
			end
			
			%open path finding dialog
			varOut = uigetdir('',sprintf('Select path for %s Atlas',strAtlasName)); 
		else
			%open text entry dialog
			cellPrompt = {'Value:'};
			strTitle = sprintf('Set %s',strVarName);
			vecDims = [5 50];
			varOut = inputdlg(cellPrompt,strTitle,vecDims);
			if numel(varOut) == 1
				varOut = varOut{1};
			end
		end
		
		%add var to structure
		sPF.(strVarName) = varOut;
		
		%save settings to ini
		strData = struct2ini(sPF,'sPF');
		fFile = fopen(strIni,'wt');
		fprintf(fFile,strData);
		fclose(fFile);
	end
end
