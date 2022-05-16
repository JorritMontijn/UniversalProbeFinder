function sAtlasParams = PF_getAtlasIni()
	%PF_getAtlasIni Reads Atlas parameters from ini file
	%   sAtlasParams = PF_getAtlasIni()
	
	%check for ini file
	strPathFile = mfilename('fullpath');
	cellDirs = strsplit(strPathFile,filesep);
	strPath = strjoin(cellDirs(1:(end-2)),filesep);
	strIni = strcat(strPath,filesep,'configAtlas.ini');
	
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
		% default data; generate if no ini exists
		sAtlasParams = struct;
		%'Mouse (AllenCCF)'
		sAtlasParams(1).name = 'Mouse (AllenCCF)';
		sAtlasParams(1).pathvar = 'strAllenCCFPath';
		sAtlasParams(1).loader = 'RP_LoadABA';
		sAtlasParams(1).prepper = 'RP_PrepABA';
		%'Rat (Sprague-Dawley)'
		sAtlasParams(2).name = 'Rat (Sprague-Dawley)';
		sAtlasParams(2).pathvar = 'strSpragueDawleyPath';
		sAtlasParams(2).loader = 'RP_LoadSDA';
		sAtlasParams(2).prepper = 'RP_PrepSDA';
		
		%write ini
		strData=struct2ini(sAtlasParams,'sAtlasParams');
		fFile = fopen(strIni,'wt');
		fprintf(fFile,strData);
		fclose(fFile);
	end
end

