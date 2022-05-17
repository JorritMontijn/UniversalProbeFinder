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
		sAtlasParams(1).loader = 'AL_PrepABA';
		sAtlasParams(1).downsample = 2;
		%'Rat (Sprague-Dawley)'
		sAtlasParams(2).name = 'Rat (Sprague-Dawley)';
		sAtlasParams(2).pathvar = 'strSpragueDawleyPath';
		sAtlasParams(2).loader = 'AL_PrepSDA';
		sAtlasParams(2).downsample = 1;
		%'Macaque (CHARM/SARM)'
		sAtlasParams(3).name = 'Macaque (CHARM/SARM)';
		sAtlasParams(3).pathvar = 'strCharmSarmPath';
		sAtlasParams(3).loader = 'AL_PrepMCS';
		sAtlasParams(3).downsample = 1;
		
		%write ini
		strData=struct2ini(sAtlasParams,'sAtlasParams');
		fFile = fopen(strIni,'wt');
		fprintf(fFile,strData);
		fclose(fFile);
	end
end

