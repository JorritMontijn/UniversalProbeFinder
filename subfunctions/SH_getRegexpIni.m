function sRegExpAssignment = SH_getRegexpIni(sRegExpWrite)
	%SH_getRegexpIni Reads or writes regexp parameters from/to ini file
	%   sRegExpAssignment = SH_getRegexpIni(sRegExpWrite)
	
	%check for ini file
	strIni = strcat(SH_getIniPath(),filesep,'configSliceRegexp.ini');
	boolInputSupplied = exist('sRegExpWrite','var') && ~isempty(sRegExpWrite);
	
	%load ini
	if exist(strIni,'file') && ~boolInputSupplied
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
		%load defaults
		sRegExpAssignment = defaultRegExp();
		
		%overwrite with supplied data
		if boolInputSupplied
			cellFields = fieldnames(sRegExpAssignment);
			for intField=1:numel(cellFields)
				if isfield(sRegExpWrite,cellFields{intField})
					sRegExpAssignment.(cellFields{intField}) = sRegExpWrite.(cellFields{intField});
				end
			end
		end
		
		%write ini
		strData=struct2ini(sRegExpAssignment,'sRegExpAssignment');
		fFile = fopen(strIni,'wt');
		fprintf(fFile,strData);
		fclose(fFile);
	end
end
function sRegExpAssignment = defaultRegExp()
	% default data; generate if no ini exists
	sRegExpAssignment = struct;
	sRegExpAssignment.File = '\w*_S';
	sRegExpAssignment.Image = 'S\d*';
	sRegExpAssignment.Ch1 = 'C0*1';
	sRegExpAssignment.Ch2 = 'C0*2';
	sRegExpAssignment.Ch3 = 'C0*3';
	sRegExpAssignment.X = 'X\d*';
	sRegExpAssignment.Y = 'Y\d*';
	sRegExpAssignment.Z = 'Z\d*';
end
