function varOut = PF_getIniVar(strVarName,boolSetValue)
	%PF_populateStructure Prepares parameters by loading ini file, or creates one with default values
	
	%default
	if ~exist('boolSetValue','var') || isempty(boolSetValue)
		boolSetValue = false;
	end
	
	%check for ini file
	strIni = strcat(SH_getIniPath(),filesep,'configPF.ini');
	
	%load ini
	if exist(strIni,'file')
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
	else
		%empty placeholder
		sPF=struct;
	end
	
	%retrieve or set variable
	if ~boolSetValue && isfield(sPF,strVarName) && ~isempty(sPF.(strVarName)) && ~(numel(strVarName) > 7 && strcmpi(strVarName(1:3),'str') && strcmpi(strVarName((end-3):end),'Path') && sPF.(strVarName)(1) == 0)
		varOut = sPF.(strVarName);
	else
		%fill if empty
		
		%default vars
		sDefaultIni = struct;
		sDefaultIni.IgnoreRender = 0;
		
		%path vars
		if ~boolSetValue && isfield(sDefaultIni,strVarName)
			varOut = sDefaultIni.(strVarName);
		elseif numel(strVarName) > 7 && strcmpi(strVarName(1:3),'str') && strcmpi(strVarName((end-3):end),'Path')
			%alter name
			strAtlasName = strVarName;
			if strcmp(strAtlasName(1:3),'str')
				strAtlasName = strAtlasName(4:end);
			end
			if strcmpi(strAtlasName((end-3):end),'Path')
				strAtlasName = strAtlasName(1:(end-4));
			end
			
			if isfield(sPF,strVarName) && exist(sPF.(strVarName),'dir')
				strDefPath = sPF.(strVarName);
			else
				strDefPath = '';
			end
			
			%open path finding dialog
			varOut = uigetdir(strDefPath,sprintf('Select path for %s',strAtlasName));
			if isempty(varOut) || varOut(1)==0,return;end
		else
			%open text entry dialog
			if isfield(sPF,strVarName)
				if isnumeric(sPF.(strVarName))
					sPF.(strVarName) = num2str(sPF.(strVarName));
				end
				strDefInput={sPF.(strVarName)};
			else
				strDefInput={''};
			end
			cellPrompt = {'Value:'};
			strTitle = sprintf('Set %s',strVarName);
			vecDims = [5 50];
			varOut = inputdlg(cellPrompt,strTitle,vecDims,strDefInput);
			if numel(varOut) == 1
				varOut = varOut{1};
			end
			if ~iscell(varOut) && ~isnan(str2double(varOut))
				varOut = str2double(varOut);
			end
			if isempty(varOut),return;end
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
